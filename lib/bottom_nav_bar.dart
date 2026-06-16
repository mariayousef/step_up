import 'package:flutter/material.dart';

import 'app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hasUnreadMessages;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasUnreadMessages = false,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        const BottomNavigationBarItem(
          icon: Icon(Icons.location_on_rounded),
          label: 'Location',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.trending_up_rounded),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.medical_services_rounded),
              if (hasUnreadMessages)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          label: 'Doctors',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
