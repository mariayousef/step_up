import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'body_training_screen.dart';
import 'exit_child_mode_screen.dart';
import 'games_screen.dart';
import 'speech_levels_screen.dart';

class ChildDashboardScreen extends StatelessWidget {
  const ChildDashboardScreen({super.key});

  void _openExitScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExitChildModeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _openExitScreen(context);
      },
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          FadeInDown(child: _buildHeader()),
                          const SizedBox(height: 40),
                          ..._buildTrainingActions(context),
                          const Spacer(),
                          const SizedBox(height: 24),
                          FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            child: _ExitButton(
                              onPressed: () => _openExitScreen(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.star_rounded, color: Colors.amber, size: 26),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hi Ahmed!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.favorite_border, color: Colors.pinkAccent, size: 26),
      ],
    );
  }

  List<Widget> _buildTrainingActions(BuildContext context) {
    final actions = [
      _TrainingAction(
        title: 'Body Training',
        icon: Icons.accessibility_new,
        color: const Color(0xFF00C471),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BodyTrainingScreen()),
        ),
      ),
      _TrainingAction(
        title: 'Speech Training',
        icon: Icons.record_voice_over,
        color: const Color(0xFF007BFF),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SpeechLevelsScreen()),
        ),
      ),
      _TrainingAction(
        title: 'Games',
        icon: Icons.videogame_asset_rounded,
        color: const Color(0xFFFF9800),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GamesScreen()),
        ),
      ),
    ];

    return [
      for (var index = 0; index < actions.length; index++) ...[
        FadeInUp(
          delay: Duration(milliseconds: 100 * (index + 1)),
          child: _TrainingButton(action: actions[index]),
        ),
        if (index != actions.length - 1) const SizedBox(height: 16),
      ],
    ];
  }
}

class _TrainingAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TrainingAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _TrainingButton extends StatelessWidget {
  final _TrainingAction action;

  const _TrainingButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 90,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: action.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: action.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(
              action.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
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

class _ExitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ExitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B6B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        onPressed: onPressed,
        child: const Text(
          'Exit child mode',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
