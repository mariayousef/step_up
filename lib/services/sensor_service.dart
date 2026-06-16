import 'dart:async';


import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../models/sensor_reading_model.dart';
import '../safe_zone_model.dart';
import 'api_service.dart';
import 'notification_service.dart';

class SensorService {
  static Future<SensorReading> fetchLatestReading() async {
    final response = await ApiService.getJson(
      '/api/readings/latest',
      authorized: true,
    );

    return SensorReading.fromJson(_extractMap(response));
  }

  static Future<void> sendDeviceReading(SensorReading reading) async {
    await ApiService.postJson('/api/device/readings', reading.toJson());
  }

  static Map<String, dynamic> _extractMap(dynamic response) {
    if (response is Map) {
      for (final key in const ['reading', 'data', 'latest']) {
        final value = response[key];
        if (value is Map) return Map<String, dynamic>.from(value);
      }
      return Map<String, dynamic>.from(response);
    }

    return const {};
  }
}

class SensorReadingsController {
  SensorReadingsController._();

  static final SensorReadingsController instance = SensorReadingsController._();

  final ValueNotifier<SensorReading?> latestReading =
      ValueNotifier<SensorReading?>(null);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  Timer? _timer;

  // Track the last time an alert was sent to prevent spam (5 min cooldown)
  DateTime? _lastFallAlert;
  DateTime? _lastHighHrAlert;
  DateTime? _lastLowHrAlert;
  DateTime? _lastHighTempAlert;
  DateTime? _lastLowTempAlert;
  bool _wasOutside = false;

  void start() {
    if (_timer != null) return;

    loadSafeZones().then((_) {
      fetchLatest();
      _timer = Timer.periodic(const Duration(seconds: 30), (_) {
        fetchLatest();
      });
    });
  }

  Future<SensorReading?> fetchLatest() async {
    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) {
      print("SENSOR: No token found. Polling skipped.");
      errorMessage.value = 'Login required to read sensor data';
      return null;
    }

    try {
      print("SENSOR: Fetching latest reading...");
      final reading = await SensorService.fetchLatestReading();
      print("SENSOR: Success! HR: ${reading.heartRate}, Temp: ${reading.temperature}");
      latestReading.value = reading;
      errorMessage.value = null;
      await _syncLocation(reading);
      _evaluateHealthAlerts(reading);
      return reading;
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      print('SENSOR: API error: ${error.message} (Code: ${error.statusCode})');
    } catch (error) {
      errorMessage.value = error.toString();
      print('SENSOR: Refresh error: $error');
    }

    return null;
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _evaluateHealthAlerts(SensorReading reading) {
    final now = DateTime.now();

    // 1. Fall Detection
    if (reading.fallDetected) {
      if (_lastFallAlert == null || now.difference(_lastFallAlert!).inMinutes >= 5) {
        NotificationService.instance.showNotification(
          title: '🚨 Fall Detected!',
          body: 'Attention: A fall has been detected. Please check on the child immediately.',
        );
        _lastFallAlert = now;
      }
    }

    // 2. Heart Rate Alerts
    final hr = reading.heartRate;
    if (hr == null || hr == 0) {
      if (_lastLowHrAlert == null || now.difference(_lastLowHrAlert!).inMinutes >= 5) {
        NotificationService.instance.showNotification(
          title: '⚠️ Sensor Error',
          body: 'Heart rate reading is 0 or missing. Please check if the sensor is worn correctly.',
        );
        _lastLowHrAlert = now; // reuse low hr tracker for 0
      }
    } else if (hr > 120) {
      if (_lastHighHrAlert == null || now.difference(_lastHighHrAlert!).inMinutes >= 5) {
        NotificationService.instance.showNotification(
          title: '⚠️ High Heart Rate',
          body: 'Heart rate is elevated ($hr bpm). Please monitor the child.',
        );
        _lastHighHrAlert = now;
      }
    } else if (hr < 50) {
      if (_lastLowHrAlert == null || now.difference(_lastLowHrAlert!).inMinutes >= 5) {
        NotificationService.instance.showNotification(
          title: '⚠️ Low Heart Rate',
          body: 'Heart rate is unusually low ($hr bpm). Please check immediately.',
        );
        _lastLowHrAlert = now;
      }
    }

    // 3. Temperature Alerts
    if (reading.temperature != null && reading.temperature! > 0) {
      if (reading.temperature! > 38.0) {
        if (_lastHighTempAlert == null || now.difference(_lastHighTempAlert!).inMinutes >= 5) {
          NotificationService.instance.showNotification(
            title: '🤒 High Temperature',
            body: 'Temperature is high (${reading.temperature} °C). The child may have a fever.',
          );
          _lastHighTempAlert = now;
        }
      } else if (reading.temperature! < 36.0) {
        if (_lastLowTempAlert == null || now.difference(_lastLowTempAlert!).inMinutes >= 5) {
          NotificationService.instance.showNotification(
            title: '❄️ Low Temperature',
            body: 'Temperature is low (${reading.temperature} °C). Please ensure the child is warm.',
          );
          _lastLowTempAlert = now;
        }
      }
    }
  }

  Future<void> _syncLocation(SensorReading reading) async {
    if (!reading.hasLocation) return;

    final location = LatLng(reading.latitude!, reading.longitude!);
    childLocationNotifier.value = location;
    _updateSafeZoneStatus(location);
  }



  void _updateSafeZoneStatus(LatLng location) {
    bool hasActiveZones = globalSafeZones.any((z) => z.active);

    if (!hasActiveZones) {
      isChildSafeNotifier.value = true;
      currentZoneNameNotifier.value = 'No zones configured';
      _wasOutside = false;
      return;
    }

    bool isSafe = false;
    String? zoneName;

    for (final zone in globalSafeZones) {
      if (!zone.active) continue;

      final distance = const Distance().as(
        LengthUnit.Meter,
        location,
        LatLng(zone.latitude, zone.longitude),
      );

      if (distance <= zone.radius) {
        isSafe = true;
        zoneName = zone.name;
        break;
      }
    }

    isChildSafeNotifier.value = isSafe;
    currentZoneNameNotifier.value = zoneName;

    if (!isSafe) {
      if (!_wasOutside) {
        NotificationService.instance.showNotification(
          title: 'Safe Zone Alert 🚨',
          body: 'Attention: Your child has left the specified safe zone!',
        );
        _wasOutside = true;
      }
    } else {
      _wasOutside = false;
    }
  }
}
