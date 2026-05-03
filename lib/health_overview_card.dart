import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'mini_stat.dart';
import 'models/sensor_reading_model.dart';
import 'services/sensor_service.dart';

class HealthOverviewCard extends StatelessWidget {
  const HealthOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SensorReading?>(
      valueListenable: SensorReadingsController.instance.latestReading,
      builder: (context, reading, _) {
        final heartRate = reading?.heartRate == null
            ? '--'
            : '${reading!.heartRate} bpm';
        final temperature = reading?.temperature == null
            ? '--'
            : '${reading!.temperature!.toStringAsFixed(1)} C';
        final gpsValue = reading?.satellites == null
            ? '--'
            : '${reading!.satellites} sats';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Health Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: MiniStat(
                      icon: Icons.favorite_rounded,
                      label: "Heart Rate",
                      value: heartRate,
                      color: Colors.redAccent,
                    ),
                  ),
                  Expanded(
                    child: MiniStat(
                      icon: Icons.thermostat_rounded,
                      label: "Temperature",
                      value: temperature,
                      color: Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: MiniStat(
                      icon: Icons.gps_fixed_rounded,
                      label: "GPS",
                      value: gpsValue,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
