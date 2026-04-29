import 'package:flutter/material.dart';
import 'package:step_up/health_overview_card.dart';
import 'package:step_up/development_progress_card.dart';
import 'package:step_up/bottom_nav_bar.dart';
import 'package:step_up/LocationScreen.dart';
import 'package:step_up/ProgressScreen.dart';
import 'ProfileScreen.dart';
import 'package:step_up/NotificationScreen.dart';
import 'package:step_up/safe_zone_model.dart';
import 'package:step_up/app_colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'doctors_list_screen.dart';
import 'package:animate_do/animate_do.dart';

class ChildLocationCard extends StatelessWidget {
  final LatLng childLocation;
  final bool isInsideZone;
  final String? currentZoneName;
  final VoidCallback onOpenLocation;

  const ChildLocationCard({
    super.key,
    required this.childLocation,
    required this.isInsideZone,
    required this.currentZoneName,
    required this.onOpenLocation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenLocation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isInsideZone ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isInsideZone ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [AppColors.softShadow],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isInsideZone ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isInsideZone ? Icons.check_circle : Icons.warning_rounded,
                color: isInsideZone ? Colors.green : Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isInsideZone
                        ? "Located at: ${currentZoneName ?? 'Unknown Zone'}"
                        : "Attention needed! Outside safe areas.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isInsideZone ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isInsideZone
                        ? "Located at: ${currentZoneName ?? 'Safe Zone'}"
                        : "Attention needed! Outside safe areas.",
                    style: TextStyle(
                      fontSize: 14,
                      color: isInsideZone ? Colors.green.shade600 : Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Coordinates: ${childLocation.latitude.toStringAsFixed(4)}, ${childLocation.longitude.toStringAsFixed(4)}",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Tracking is handled in LocationScreen
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      final newLocation = LatLng(pos.latitude, pos.longitude);
      childLocationNotifier.value = newLocation;

      _recheckSafeZones(newLocation);

    } catch (e) {
      debugPrint('Refresh Error: $e');
    }
  }
  void _recheckSafeZones(LatLng location) {
    bool isSafe = false;
    String? zoneName;

    for (var zone in globalSafeZones) {
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


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        setState(() {
          _selectedIndex = 0;
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            ValueListenableBuilder<LatLng>(
              valueListenable: childLocationNotifier,
              builder: (context, location, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: isChildSafeNotifier,
                  builder: (context, isSafe, _) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: currentZoneNameNotifier,
                      builder: (context, zoneName, _) {
                        return HomeContentScreen(
                          childLocation: location,
                          isChildInsideZone: isSafe,
                          currentZoneName: zoneName,
                          onRefresh: _onRefresh,
                          onOpenLocation: () {
                            setState(() {
                              _selectedIndex = 1;
                            });
                          },
                          onOpenProgress: () {
                            setState(() {
                              _selectedIndex = 2;
                            });
                          },
                          onOpenDoctors: () {
                            setState(() {
                              _selectedIndex = 3;
                            });
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
            const LocationScreen(),
            const ProgressScreen(),
            const DoctorsListScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class HomeContentScreen extends StatelessWidget {
  final LatLng childLocation;
  final bool isChildInsideZone;
  final String? currentZoneName;
  final VoidCallback onOpenLocation;
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenDoctors;
  final RefreshCallback onRefresh;

  const HomeContentScreen({
    super.key,
    required this.childLocation,
    required this.isChildInsideZone,
    required this.currentZoneName,
    required this.onOpenLocation,
    required this.onOpenProgress,
    required this.onOpenDoctors,
    required this.onRefresh,
  });

  void _openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Header ----------------
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Welcome back 👋",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Let's achieve your goals today!",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openNotifications(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ----------- Location Widget -----------
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: ChildLocationCard(
                childLocation: childLocation,
                isInsideZone: isChildInsideZone,
                currentZoneName: currentZoneName,
                onOpenLocation: onOpenLocation,
              ),
            ),
            const SizedBox(height: 30),

            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: const HealthOverviewCard(),
            ),
            const SizedBox(height: 30),

            // ----------- Development Progress Widget -----------
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: onOpenProgress,
                child: const DevelopmentProgressCard(),
              ),
            ),
            const SizedBox(height: 30),

            // ----------- Doctors Widget -----------
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: GestureDetector(
                onTap: onOpenDoctors,
                child: const DoctorsSectionCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorsSectionCard extends StatelessWidget {
  const DoctorsSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.softShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Consult a Doctor",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Book an appointment with specialized doctors",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }
}
