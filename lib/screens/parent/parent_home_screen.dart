import 'package:flutter/material.dart';
import 'package:step_up/health_overview_card.dart';
import 'package:step_up/development_progress_card.dart';
import 'package:step_up/bottom_nav_bar.dart';
import 'package:step_up/LocationScreen.dart';
import 'package:step_up/ProgressScreen.dart';
import 'package:step_up/screens/parent/parent_profile_screen.dart';
import 'package:step_up/child_dashboard_screen.dart';
import 'package:step_up/pin_storage.dart';
import 'package:step_up/safe_zone_model.dart';
import 'package:step_up/app_colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:step_up/services/sensor_service.dart';
import 'package:step_up/screens/parent/doctors_list_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:step_up/services/api_service.dart';
import 'package:step_up/services/chat_service.dart';

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
            color: isInsideZone
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.red.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [AppColors.softShadow],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isInsideZone
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isInsideZone
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isInsideZone
                        ? "Located at: ${currentZoneName ?? 'Safe Zone'}"
                        : "Attention needed! Outside safe areas.",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: isInsideZone
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Coordinates: ${childLocation.latitude.toStringAsFixed(4)}, ${childLocation.longitude.toStringAsFixed(4)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int _selectedIndex = 0;

  bool _hasUnreadMessages = false;
  Map<String, int> _unreadCounts = {};
  String _currentParentId = '';
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  StreamSubscription? _chatSub;

  @override
  void initState() {
    super.initState();
    SensorReadingsController.instance.start();
    _setupChatListener();
  }

  Future<void> _setupChatListener() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);

    final user = await ApiService.getUser();
    String? foundId = user?['id']?.toString() ?? user?['phone_number']?.toString();
    
    if (foundId == null || foundId == 'unknown_parent' || foundId.isEmpty) {
      try {
        final response = await ApiService.getJson('/api/appointments', authorized: true);
        if (response['data'] is List && (response['data'] as List).isNotEmpty) {
          final first = response['data'][0];
          foundId = first['parent_id']?.toString() ?? 
                    (first['parent'] is Map ? first['parent']['id']?.toString() : null);
          if (foundId != null) {
            await ApiService.saveUser({'id': foundId});
          }
        }
      } catch (e) {}
    }

    if (foundId == null || foundId.isEmpty) return;
    _currentParentId = foundId;

    _chatSub = FirebaseFirestore.instance
        .collection('chat_rooms')
        .where('participants', arrayContains: _currentParentId)
        .snapshots()
        .listen((snapshot) {
      bool anyUnread = false;
      Map<String, int> newCounts = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final unreadCount = data['unreadCount_$_currentParentId'] ?? 0;
        
        String roomId = doc.id;
        String docId = roomId.replaceFirst(_currentParentId, '').replaceAll('_', '');
        
        if (docId.isNotEmpty) {
          newCounts[docId] = (unreadCount as num).toInt();
        }

        if (unreadCount > 0) {
          anyUnread = true;
          
          if (ChatService.currentOpenRoom == roomId) {
            ChatService().markRoomAsRead(_currentParentId, docId);
          } else {
             bool isNew = snapshot.docChanges.any((c) => c.doc.id == roomId && (c.type == DocumentChangeType.added || c.type == DocumentChangeType.modified));
             if (isNew) {
               String msgText = data['lastMessage'] ?? 'You received a new message';
               if (_selectedIndex != 3) { // Doctors tab is index 3
                 _showNotification('New Message', msgText);
               }
             }
          }
        }
      }

      if (mounted) {
        setState(() {
          _unreadCounts = newCounts;
          _hasUnreadMessages = anyUnread && _selectedIndex != 3;
        });
      }
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_channel_parent',
      'Parent Chat Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  void dispose() {
    SensorReadingsController.instance.stop();
    _chatSub?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await SensorReadingsController.instance.fetchLatest();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
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
            DoctorsListScreen(unreadCounts: _unreadCounts),
            const ParentProfileScreen(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _selectedIndex,
          hasUnreadMessages: _hasUnreadMessages,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              if (index == 3) {
                _hasUnreadMessages = false;
              }
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

  Future<void> _openChildMode(BuildContext context) async {
    final hasPin = await PinStorage.hasPin();

    if (!context.mounted) return;

    if (!hasPin) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Child Mode PIN'),
          content: const Text(
            'You have not set a PIN yet.\nPlease go to Settings first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Enter Child Mode PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'PIN',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final enteredPin = pinController.text.trim();
              final isCorrect = await PinStorage.isCorrectPin(enteredPin);

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);

              if (!context.mounted) return;

              if (isCorrect) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Correct PIN!'),
                    backgroundColor: Colors.green,
                    duration: Duration(milliseconds: 800),
                  ),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChildDashboardScreen(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wrong PIN'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Enter'),
          ),
        ],
      ),
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
                            color: AppColors.primary.withValues(alpha: 0.15),
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
                                "Welcome back",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Let's achieve your goals today!",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
                    onTap: () => _openChildMode(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.child_care_rounded,
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
              color: Colors.white.withValues(alpha: 0.2),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Book an appointment with specialized doctors",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
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
