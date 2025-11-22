import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'safe_zone_model.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<SafeZone> safeZones = [
    SafeZone(name: 'Home', radius: 100, active: true),
    SafeZone(name: 'School', radius: 150, active: true),
    SafeZone(name: 'Grandma\'s House', radius: 80, active: false),
  ];

  // -----------------------------
  // 🔵 Dialog for Add / Edit Zone
  // -----------------------------
  void _showZoneDialog({SafeZone? zone, int? index}) {
    final nameController = TextEditingController(text: zone?.name ?? '');
    final radiusController =
    TextEditingController(text: zone?.radius.toString() ?? '');

    bool sendNotifications = zone?.sendNotifications ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(zone == null ? 'Add Safe Zone' : 'Edit Safe Zone'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Zone Name'),
                  ),
                  TextField(
                    controller: radiusController,
                    decoration: const InputDecoration(labelText: 'Radius (meters)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Send Notifications'),
                      Switch(
                        value: sendNotifications,
                        onChanged: (value) {
                          setStateDialog(() {
                            sendNotifications = value;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final radius = int.tryParse(radiusController.text.trim()) ?? 100;

                    if (zone == null) {
                      // Add new zone
                      setState(() {
                        safeZones.add(
                          SafeZone(
                            name: name,
                            radius: radius,
                            sendNotifications: sendNotifications,
                          ),
                        );
                      });
                    } else {
                      // Edit existing zone
                      setState(() {
                        safeZones[index!] = SafeZone(
                          name: name,
                          radius: radius,
                          active: zone.active,
                          sendNotifications: sendNotifications,
                        );
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: Text(zone == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------
  //                🔵 UI SCREEN BUILD
  // ---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Safe Zones',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header + Add Zone Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Safe Zones\nGet alerts when your child leaves',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showZoneDialog(); // ADD NEW ZONE
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Zone'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            // Map Placeholder
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.green.shade50],
                ),
              ),
              child: const Center(
                child: Text(
                  'Map Placeholder (Google Maps later)',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Safe Zones List
            Expanded(
              child: ListView.builder(
                itemCount: safeZones.length,
                itemBuilder: (context, index) {
                  final zone = safeZones[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name + Switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  Text(
                                    zone.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Switch(
                                value: zone.active,
                                onChanged: (value) {
                                  setState(() {
                                    zone.active = value;
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),
                          Text('Radius: ${zone.radius}m'),
                          const SizedBox(height: 4),

                          // Notification + Edit + Delete
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text('Send notifications'),
                                  Switch(
                                    value: zone.sendNotifications,
                                    onChanged: (value) {
                                      setState(() {
                                        zone.sendNotifications = value;
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _showZoneDialog(
                                        zone: zone,
                                        index: index,
                                      );
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        safeZones.removeAt(index);
                                      });
                                    },
                                    icon: const Icon(Icons.delete),
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

