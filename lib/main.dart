import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/LoginScreen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/child_data_screen.dart';
import 'screens/ProfileScreen.dart';
import 'models/register_request_model.dart';

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
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/child_info') {
          final parent = settings.arguments as ParentModel;

          return MaterialPageRoute(
            builder: (_) => ChildDataScreen(parent: parent),
          );
        }
        return null;
      },
    );
  }
}
