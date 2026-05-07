import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SafeZone {
  String name;
  double latitude;
  double longitude;
  int radius;
  bool active;
  bool sendNotifications;

  SafeZone({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.active = true,
    this.sendNotifications = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'active': active,
        'sendNotifications': sendNotifications,
      };

  factory SafeZone.fromJson(Map<String, dynamic> json) => SafeZone(
        name: json['name'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        radius: json['radius'],
        active: json['active'] ?? true,
        sendNotifications: json['sendNotifications'] ?? false,
      );
}

// Global Notifier for Safe Zone Status
final ValueNotifier<bool> isChildSafeNotifier = ValueNotifier<bool>(true);

// Global Notifier for Child Current Location
final ValueNotifier<LatLng> childLocationNotifier = ValueNotifier<LatLng>(LatLng(30.0444, 31.2357));

// Global Notifier for current Safe Zone name (if any)
final ValueNotifier<String?> currentZoneNameNotifier = ValueNotifier<String?>(null);

// Global list of safe zones
List<SafeZone> globalSafeZones = [];

// Persistence functions
Future<void> saveSafeZones() async {
  final prefs = await SharedPreferences.getInstance();
  final String encodedData = jsonEncode(globalSafeZones.map((z) => z.toJson()).toList());
  await prefs.setString('safe_zones_list', encodedData);
}

Future<void> loadSafeZones() async {
  final prefs = await SharedPreferences.getInstance();
  final String? encodedData = prefs.getString('safe_zones_list');
  if (encodedData != null) {
    final List<dynamic> decodedData = jsonDecode(encodedData);
    globalSafeZones = decodedData.map((e) => SafeZone.fromJson(Map<String, dynamic>.from(e))).toList();
  } else {
    // Default dummy data if empty
    globalSafeZones = [
      SafeZone(name: 'Home', latitude: 30.0444, longitude: 31.2357, radius: 100, active: true),
    ];
  }
}

