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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Health Overview",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              MiniStat(
                icon: Icons.favorite_rounded,
                label: "Heart Rate",
                value: "89 bpm",
                color: Colors.redAccent,
              ),
              MiniStat(
                icon: Icons.water_drop_rounded,
                label: "Oxygen",
                value: "97%",
                color: Colors.blueAccent,
              ),
              MiniStat(
                icon: Icons.mood_rounded,
                label: "Mood",
                value: "Happy",
                color: Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
