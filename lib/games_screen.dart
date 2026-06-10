import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Games',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 48
                      ? constraints.maxHeight - 48
                      : 0,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _GamesIcon(),
                    SizedBox(height: 24),
                    _ComingSoonTitle(),
                    SizedBox(height: 16),
                    _ComingSoonMessage(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GamesIcon extends StatelessWidget {
  const _GamesIcon();

  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      child: const Icon(
        Icons.videogame_asset_rounded,
        size: 120,
        color: Color(0xFFFF9800),
      ),
    );
  }
}

class _ComingSoonTitle extends StatelessWidget {
  const _ComingSoonTitle();

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: const Text(
        'Coming Soon!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
        ),
      ),
    );
  }
}

class _ComingSoonMessage extends StatelessWidget {
  const _ComingSoonMessage();

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: const Text(
        'Fun and educational games will be added here soon.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
      ),
    );
  }
}
