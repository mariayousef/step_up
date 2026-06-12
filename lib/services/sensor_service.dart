import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../models/sensor_reading_model.dart';
import '../safe_zone_model.dart';
import 'api_service.dart';

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

  void start() {
    if (_timer != null) return;

    fetchLatest();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchLatest();
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
      _syncLocation(reading);
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

  void _syncLocation(SensorReading reading) {
    if (!reading.hasLocation) return;

    final location = LatLng(reading.latitude!, reading.longitude!);
    childLocationNotifier.value = location;
    _updateSafeZoneStatus(location);
  }

  void _updateSafeZoneStatus(LatLng location) {
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
  }
}
