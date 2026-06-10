import 'package:flutter/material.dart';

import 'app_colors.dart';

class DevelopmentProgressCard extends StatelessWidget {
  const DevelopmentProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 320;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isCompact
              ? const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressRing(),
                    SizedBox(height: 18),
                    _ProgressDetails(),
                  ],
                )
              : const Row(
                  children: [
                    _ProgressRing(),
                    SizedBox(width: 20),
                    Expanded(child: _ProgressDetails()),
                  ],
                ),
        );
      },
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 70,
      width: 70,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 0.75,
            color: Colors.white,
            strokeWidth: 7,
            backgroundColor: Colors.white24,
          ),
          Center(
            child: Text(
              "75%",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressDetails extends StatelessWidget {
  const _ProgressDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Development Progress",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Keep up the great work!",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "12 tasks completed",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
