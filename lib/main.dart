import 'package:flutter/material.dart';
import 'package:step_up/child_data_screen.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'LoginScreen.dart';
import 'signup_screen.dart';
import 'bracelet_instruction_screen.dart';
import 'qr_scanner_screen.dart';
import 'home_screen.dart';
import 'app_colors.dart';

void main() {
  runApp(const StepUpApp());
}

class StepUpApp extends StatelessWidget {
  const StepUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Step Up',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),

      home: const SplashScreen(),

      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/bracelet_instruction': (context) => const BraceletInstructionScreen(),
        '/qr_scanner': (context) => const QrScannerScreen(),
        '/child_info': (context) => const ChildDataScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
