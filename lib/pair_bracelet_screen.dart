import 'package:flutter/material.dart';
import 'package:step_up/app_colors.dart';

class PairBraceletScreen extends StatelessWidget {
  const PairBraceletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView( // ✅ إضافة لحل overflow
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80), // ✅ مسافة علشان يبقى في توازن
              const Icon(Icons.bluetooth, size: 120, color: AppColors.primary),
              const SizedBox(height: 40),
              const Text(
                "Pair Your Bracelet",
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Turn on Bluetooth and make sure your bracelet is near your phone to connect.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text(
                  "Pair Now",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
