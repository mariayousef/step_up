import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'mini_stat.dart';

class HealthOverviewCard extends StatelessWidget {
  const HealthOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Health Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: MiniStat(
                  icon: Icons.favorite_rounded,
                  label: "Heart Rate",
                  value: "89 bpm",
                  color: Colors.redAccent,
                ),
              ),
              Expanded(
                child: MiniStat(
                  icon: Icons.emoji_emotions_rounded,
                  label: "Mood",
                  value: "Happy",
                  color: Colors.amber,
                ),
              ),
              Expanded(
                child: MiniStat(
                  icon: Icons.water_drop_rounded,
                  label: "Oxygen",
                  value: "97%",
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
