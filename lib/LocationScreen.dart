import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'safe_zone_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  LatLng? _currentP = childLocationNotifier.value;
  final MapController _mapController = MapController();
  bool _isFirstLocationLoad = true;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    childLocationNotifier.addListener(_syncChildLocationFromSensor);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await loadSafeZones();
    await _initializeNotifications();
    _syncChildLocationFromSensor();
  }

  void _syncChildLocationFromSensor() {
    if (!mounted) return;

    final sensorLocation = childLocationNotifier.value;
    setState(() => _currentP = sensorLocation);

    if (_isFirstLocationLoad) {
      _mapController.move(sensorLocation, 15);
      _isFirstLocationLoad = false;
    }

    _checkGeofence(sensorLocation);
  }

  void _checkGeofence(LatLng currentPos) {
    bool hasActiveZones = globalSafeZones.any((z) => z.active);

    if (!hasActiveZones) {
      // If parent didn't set any active safe zones, don't trigger alerts
      isChildSafeNotifier.value = true;
      currentZoneNameNotifier.value = 'No zones configured';
      _wasOutside = false;
      return;
    }

    bool isSafe = false;
    String? currentZoneName;

    for (var zone in globalSafeZones) {
      if (!zone.active) continue;

      final Distance distance = const Distance();
      final double meterDist = distance.as(
        LengthUnit.Meter,
        LatLng(zone.latitude, zone.longitude),
        currentPos,
      );

      if (meterDist <= zone.radius) {
        isSafe = true;
        currentZoneName = zone.name;
        break;
      }
    }

    isChildSafeNotifier.value = isSafe;
    currentZoneNameNotifier.value = currentZoneName;

    if (!isSafe) {
      if (!_wasOutside) {
        _showSnackBar('ALERT: Child is outside safe zones!');
        _showNotification(
          'Safe Zone Alert 🚨',
          'Attention: Your child has left the specified safe zone!',
        );
        _wasOutside = true;
      }
    } else {
      _wasOutside = false;
    }
  }

  Future<void> _initializeNotifications() async {
    // Request permissions using permission_handler to ensure it's awaited properly
    var status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification_alert');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'safe_zone_alerts',
          'Safe Zone Alerts',
          channelDescription: 'Notifications for safe zone breaches',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    try {
      final int notificationId = title.hashCode;
      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint('Notification Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification failed: $e. Try full restart.')),
        );
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isPickingLocation = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  int? _editingIndex;
  SafeZone? _editingZone;

  String? _tempName;
  String? _tempRadius;
  bool? _tempNotify;

  bool _wasOutside = false;

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });
    final url = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '5',
    });
    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'StepUpApp/1.0'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _searchResults = data is List ? data : [];
            _isSearching = false;
          });
          if (_searchResults.isEmpty) _showSnackBar('No locations found');
        }
      } else {
        if (mounted) {
          setState(() => _isSearching = false);
          _showSnackBar('Error searching location');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        _showSnackBar('Search failed: $e');
      }
    }
  }

  void _moveToLocation(double lat, double lon, String displayName) {
    final LatLng newPos = LatLng(lat, lon);
    setState(() {
      _mapController.move(newPos, 15);
      _searchResults = [];
      _searchController.text = displayName;
    });
    _showSnackBar('Location selected: $displayName');
  }

  @override
  void dispose() {
    childLocationNotifier.removeListener(_syncChildLocationFromSensor);
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showZoneDialog({SafeZone? zone, int? index, LatLng? pickedLocation}) {
    final nameController = TextEditingController(
      text: _tempName ?? zone?.name ?? '',
    );
    final radiusController = TextEditingController(
      text: _tempRadius ?? zone?.radius.toString() ?? '',
    );
    bool sendNotifications = _tempNotify ?? zone?.sendNotifications ?? false;

    LatLng dialogLocation;
    if (pickedLocation != null) {
      dialogLocation = pickedLocation;
    } else if (zone != null) {
      dialogLocation = LatLng(zone.latitude, zone.longitude);
    } else if (_currentP != null) {
      dialogLocation = _currentP!;
    } else {
      dialogLocation = const LatLng(30.0444, 31.2357);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                zone == null && _editingZone == null
                    ? 'Add Safe Zone'
                    : 'Edit Safe Zone',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: dialogLocation.latitude.toString()),
                            decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            onChanged: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed != null) dialogLocation = LatLng(parsed, dialogLocation.longitude);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: dialogLocation.longitude.toString()),
                            decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            onChanged: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed != null) dialogLocation = LatLng(dialogLocation.latitude, parsed);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        _tempName = nameController.text;
                        _tempRadius = radiusController.text;
                        _tempNotify = sendNotifications;
                        Navigator.pop(context);
                        setState(() {
                          _isPickingLocation = true;
                          _editingIndex = index;
                          _editingZone = zone;
                        });
                        _showSnackBar('Tap on the map to select location');
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('Pick on Map'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Zone Name'),
                    ),
                    TextField(
                      controller: radiusController,
                      decoration: const InputDecoration(
                        labelText: 'Radius (meters)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Send Notifications',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: sendNotifications,
                      onChanged: (value) {
                        setStateDialog(() => sendNotifications = value);
                      },
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _editingIndex = null;
                    _editingZone = null;
                    _tempName = null;
                    _tempRadius = null;
                    _tempNotify = null;
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final radius =
                        int.tryParse(radiusController.text.trim()) ?? 100;
                    final targetIndex = index ?? _editingIndex;
                    final targetZone = zone ?? _editingZone;

                    if (targetIndex == null) {
                      setState(() {
                        globalSafeZones.add(
                          SafeZone(
                            name: name,
                            latitude: dialogLocation.latitude,
                            longitude: dialogLocation.longitude,
                            radius: radius,
                            sendNotifications: sendNotifications,
                          ),
                        );
                      });
                      saveSafeZones();
                    } else {
                      setState(() {
                        globalSafeZones[targetIndex] = SafeZone(
                          name: name,
                          latitude: dialogLocation.latitude,
                          longitude: dialogLocation.longitude,
                          radius: radius,
                          active: targetZone?.active ?? true,
                          sendNotifications: sendNotifications,
                        );
                      });
                      saveSafeZones();
                    }
                    if (_currentP != null) _checkGeofence(_currentP!);
                    _mapController.move(dialogLocation, 16);
                    _editingIndex = null;
                    _editingZone = null;
                    _tempName = null;
                    _tempRadius = null;
                    _tempNotify = null;
                    Navigator.pop(context);
                  },
                  child: Text(
                    (zone == null && _editingZone == null) ? 'Add' : 'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Safe Zones',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              'Get alerts when your child leaves',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        );

        final button = ElevatedButton.icon(
          onPressed: () => _showZoneDialog(),
          icon: const Icon(Icons.add),
          label: const Text(
            'Add Zone',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        if (constraints.maxWidth < 340) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [title, const SizedBox(height: 12), button],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            button,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Safe Zones', style: TextStyle(color: Colors.black)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(30.0444, 31.2357),
                        initialZoom: 15,
                        maxZoom: 18,
                        minZoom: 3,
                        onTap: (_, point) {
                          if (_isPickingLocation) {
                            setState(() => _isPickingLocation = false);
                            _showZoneDialog(
                              pickedLocation: point,
                              zone: _editingZone,
                              index: _editingIndex,
                            );
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.step_up',
                          subdomains: ['a', 'b', 'c', 'd'],
                        ),
                        CircleLayer(
                          circles: globalSafeZones.isEmpty 
                              ? <CircleMarker>[] 
                              : globalSafeZones
                                  .where((zone) => zone.active)
                                  .map(
                                    (zone) => CircleMarker(
                                      point: LatLng(zone.latitude, zone.longitude),
                                      color: Colors.green.withValues(alpha: 0.3),
                                      borderStrokeWidth: 2,
                                      borderColor: Colors.green,
                                      useRadiusInMeter: true,
                                      radius: zone.radius.toDouble(),
                                    ),
                                  )
                                  .toList(),
                        ),
                        MarkerLayer(
                          markers: _currentP == null ? <Marker>[] : [
                            Marker(
                              point: _currentP!,
                              width: 150,
                              height: 90,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                      border: Border.all(color: Colors.blue, width: 1.5),
                                    ),
                                    child: FittedBox(
                                      child: Text(
                                        'Child\n${_currentP!.latitude.toStringAsFixed(4)}, ${_currentP!.longitude.toStringAsFixed(4)}',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.person_pin_circle,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_isPickingLocation)
                      Positioned(
                        top: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [AppColors.softShadow],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.search,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextField(
                                            controller: _searchController,
                                            decoration: InputDecoration(
                                              hintText: 'Search location...',
                                              border: InputBorder.none,
                                              suffixIcon:
                                                  _searchController
                                                      .text
                                                      .isNotEmpty
                                                  ? IconButton(
                                                      icon: const Icon(
                                                        Icons.clear,
                                                        size: 20,
                                                      ),
                                                      onPressed: () =>
                                                          setState(() {
                                                            _searchController
                                                                .clear();
                                                            _searchResults = [];
                                                          }),
                                                    )
                                                  : null,
                                            ),
                                            onSubmitted: (value) =>
                                                _searchLocation(value),
                                          ),
                                        ),
                                        if (_isSearching)
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (_isSearching)
                                    const LinearProgressIndicator(minHeight: 2),
                                  if (_searchResults.isNotEmpty)
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 250,
                                      ),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        itemCount: _searchResults.length,
                                        separatorBuilder: (context, index) =>
                                            const Divider(height: 1),
                                        itemBuilder: (context, index) {
                                          final result = _searchResults[index];
                                          return ListTile(
                                            leading: const Icon(
                                              Icons.location_on_outlined,
                                              size: 20,
                                            ),
                                            title: Text(
                                              result['display_name'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            onTap: () {
                                              final lat = double.tryParse(
                                                result['lat']?.toString() ?? '',
                                              );
                                              final lon = double.tryParse(
                                                result['lon']?.toString() ?? '',
                                              );
                                              if (lat != null && lon != null) {
                                                _moveToLocation(
                                                  lat,
                                                  lon,
                                                  result['display_name'] ?? '',
                                                );
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.touch_app,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Tap map to select exact point',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      setState(
                                        () => _isPickingLocation = false,
                                      );
                                      _showZoneDialog(
                                        zone: _editingZone,
                                        index: _editingIndex,
                                      );
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_currentP != null && !_isPickingLocation)
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.white,
                          elevation: 4,
                          onPressed: () {
                            _mapController.move(_currentP!, 15);
                          },
                          child: const Icon(Icons.my_location, color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: globalSafeZones.length,
                itemBuilder: (context, index) {
                  final zone = globalSafeZones[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [AppColors.softShadow],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: zone.active
                                    ? AppColors.primary
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  zone.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: zone.active,
                                onChanged: (value) {
                                  setState(() => zone.active = value);
                                  saveSafeZones();
                                  if (_currentP != null) {
                                    _checkGeofence(_currentP!);
                                  }
                                },
                                activeThumbColor: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Radius: ${zone.radius}m'),
                          const SizedBox(height: 4),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 8,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Send notifications',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Switch(
                                    value: zone.sendNotifications,
                                    onChanged: (value) {
                                      setState(
                                        () => zone.sendNotifications = value,
                                      );
                                      saveSafeZones();
                                    },
                                    activeThumbColor: AppColors.primary,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _showZoneDialog(zone: zone, index: index);
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        globalSafeZones.removeAt(index);
                                      });
                                      saveSafeZones();
                                      if (_currentP != null) {
                                        _checkGeofence(_currentP!);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
