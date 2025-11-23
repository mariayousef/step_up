import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'body_training_screen.dart';
import 'speech_training_screen.dart';
import 'exit_child_mode_screen.dart';

class ChildDashboardScreen extends StatelessWidget {
  const ChildDashboardScreen({super.key});

  Future<bool> _onWillPop(BuildContext context) async {
    // بدل ما يخرج مباشرة، نفتح شاشة الخروج اللي فيها PIN
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExitChildModeScreen(),
      ),
    );
    // نرجّع false عشان ما يعملش pop للشاشة دي
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFDEBFF), Color(0xFFE3F3FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 26),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor:
                            AppColors.primary.withOpacity(0.15),
                            child: const Icon(Icons.person,
                                color: AppColors.primary, size: 34),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Hi Ahmed! 👋',
                            style: TextStyle(
                              color: AppColors.textMain,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.favorite_border,
                          color: Colors.pinkAccent, size: 26),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // زر تمارين الجسم
                  _buildTrainingButton(
                    context: context,
                    title: 'Body Training',
                    icon: Icons.accessibility_new,
                    color: const Color(0xFF00C471),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BodyTrainingScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // زر تمارين النطق
                  _buildTrainingButton(
                    context: context,
                    title: 'Speech Training',
                    icon: Icons.record_voice_over,
                    color: const Color(0xFF007BFF),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SpeechTrainingScreen(),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // زر الخروج
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExitChildModeScreen(),
                        ),
                      ),
                      child: const Text(
                        'Exit child mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 90,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
