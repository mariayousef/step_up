import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'speech_stages_screen.dart';
class SpeechLevelsScreen extends StatelessWidget {
  const SpeechLevelsScreen({super.key});

  static const _levels = [
    _SpeechLevel(
      level: 1,
      title: 'Level 1',
      subtitle: 'English Letters',
      color: Color(0xFF4CAF50),
      icon: Icons.abc_rounded,
    ),
    _SpeechLevel(
      level: 2,
      title: 'Level 2',
      subtitle: 'Letter Sounds',
      color: Color(0xFFFF9800),
      icon: Icons.record_voice_over_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Speech Levels',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              FadeInDown(
                child: const Text(
                  'Choose a Level',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              for (var index = 0; index < _levels.length; index++) ...[
                FadeInUp(
                  delay: Duration(milliseconds: 100 * (index + 1)),
                  child: _LevelCard(level: _levels[index]),
                ),
                if (index != _levels.length - 1) const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeechLevel {
  final int level;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _SpeechLevel({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}

class _LevelCard extends StatelessWidget {
  final _SpeechLevel level;

  const _LevelCard({required this.level});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpeechStagesScreen(level: level.level),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: level.color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: level.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(level.icon, color: level.color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: level.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
