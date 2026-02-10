import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

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
}

// Global Notifier for Safe Zone Status
final ValueNotifier<bool> isChildSafeNotifier = ValueNotifier<bool>(true);

// Global Notifier for Child Current Location
final ValueNotifier<LatLng> childLocationNotifier = ValueNotifier<LatLng>(LatLng(30.0444, 31.2357));

// Global Notifier for current Safe Zone name (if any)
final ValueNotifier<String?> currentZoneNameNotifier = ValueNotifier<String?>(null);

// Global list of safe zones
final List<SafeZone> globalSafeZones = [
  SafeZone(
      name: 'Home',
      latitude: 30.0444,
      longitude: 31.2357,
      radius: 100,
      active: true),
  SafeZone(
      name: 'School',
      latitude: 30.0450,
      longitude: 31.2360,
      radius: 150,
      active: true),
  SafeZone(
      name: 'Grandma\'s House',
      latitude: 30.0460,
      longitude: 31.2350,
      radius: 80,
      active: false),
];

