import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'package:step_up/screens/child/body_training_screen.dart';
import 'exit_child_mode_screen.dart';
import 'games_screen.dart';
import 'speech_levels_screen.dart';
import 'services/api_service.dart';

class ChildDashboardScreen extends StatefulWidget {
  const ChildDashboardScreen({super.key});

  @override
  State<ChildDashboardScreen> createState() => _ChildDashboardScreenState();
}

class _ChildDashboardScreenState extends State<ChildDashboardScreen> {
  String _childName = 'Buddy';

  @override
  void initState() {
    super.initState();
    _loadChildName();
  }

  Future<void> _loadChildName() async {
    final user = await ApiService.getUser();
    if (user != null && user['child_name'] != null) {
      setState(() {
        _childName = user['child_name'];
      });
    }
  }

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
        const Icon(Icons.star_rounded, color: Colors.amber, size: 36),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 42,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hi $_childName!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.favorite_rounded, color: Colors.pinkAccent, size: 36),
      ],
    );
  }

  List<Widget> _buildTrainingActions(BuildContext context) {
    final actions = [
      _TrainingAction(
        title: 'Body Training',
        icon: Icons.accessibility_new_rounded,
        color: const Color(0xFF00C471),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BodyTrainingScreen()),
        ),
      ),
      _TrainingAction(
        title: 'Speech Training',
        icon: Icons.record_voice_over_rounded,
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
        if (index != actions.length - 1) const SizedBox(height: 20),
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
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        width: double.infinity,
        height: 110,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [action.color.withValues(alpha: 0.8), action.color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: action.color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(action.icon, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      action.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 24),
                ],
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
      height: 64,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B6B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
          shadowColor: const Color(0xFFFF6B6B).withValues(alpha: 0.5),
        ),
        onPressed: onPressed,
        child: const Text(
          'Exit Child Mode',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
