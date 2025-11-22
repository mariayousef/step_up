import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'health_overview_card.dart';
import 'development_progress_card.dart';
import 'bottom_nav_bar.dart';
import 'LocationScreen.dart';
import 'ProgressScreen.dart';
import 'ProfileScreen.dart'; // Make sure to import ProfileScreen
import 'NotificationScreen.dart';

// ===================== Child Location Card =====================
class ChildLocationCard extends StatelessWidget {
  final bool isInsideZone;
  final VoidCallback onOpenLocation;

  const ChildLocationCard({
    super.key,
    required this.isInsideZone,
    required this.onOpenLocation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenLocation,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isInsideZone ? Colors.green.shade50 : Colors.red.shade50,
          border: Border.all(
            color: isInsideZone ? Colors.green : Colors.red,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            const Center(
              child: Text(
                'Map Placeholder',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isInsideZone ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isInsideZone ? 'Inside Safe Zone' : 'Outside Safe Zone',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== Main Home Screen with Bottom Nav =====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  bool get isChildInsideZone => true;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeContentScreen(
        isChildInsideZone: isChildInsideZone,
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
      ),
      const LocationScreen(),
      const ProgressScreen(),
      const ProfileScreen(), // Added ProfileScreen as the 4th screen
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// ===================== Home Content Screen =====================
class HomeContentScreen extends StatelessWidget {
  final bool isChildInsideZone;
  final VoidCallback onOpenLocation;
  final VoidCallback onOpenProgress;

  const HomeContentScreen({
    super.key,
    required this.isChildInsideZone,
    required this.onOpenLocation,
    required this.onOpenProgress,
  });

  void _openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- Header ----------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  Column(
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
                ],
              ),
              // Notification Icon - Now clickable
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
          const SizedBox(height: 20),

          // ----------- Location Widget -----------
          ChildLocationCard(
            isInsideZone: isChildInsideZone,
            onOpenLocation: onOpenLocation,
          ),
          const SizedBox(height: 30),

          const HealthOverviewCard(),
          const SizedBox(height: 30),

          // ----------- Development Progress Widget -----------
          GestureDetector(
            onTap: onOpenProgress,
            child: const DevelopmentProgressCard(),
          ),
        ],
      ),
    );
  }
}