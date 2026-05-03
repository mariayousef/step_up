import 'package:flutter/material.dart';
import 'package:step_up/app_colors.dart';
import 'package:step_up/screens/home_screen.dart';
import 'package:step_up/screens/parent/onboarding_screen.dart';
import 'package:step_up/screens/parent/parent_login_screen.dart';
import 'package:step_up/screens/parent/parent_signup_screen.dart';
import 'package:step_up/screens/parent/parent_home_screen.dart';
import 'package:step_up/screens/parent/child_data_screen.dart';
import 'package:step_up/screens/parent/parent_profile_screen.dart';
import 'package:step_up/screens/parent/splash_screen.dart';
import 'package:step_up/screens/role_selection_screen.dart';
import 'package:step_up/screens/doctor/doctor_login_screen.dart';
import 'package:step_up/screens/doctor/doctor_signup_screen.dart';
import 'package:step_up/screens/doctor/doctor_home_screen.dart';
import 'package:step_up/models/register_request_model.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        textTheme: GoogleFonts.nunitoTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.textMain),
          titleTextStyle: GoogleFonts.nunito(
            color: AppColors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            textStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      home: const SplashScreen(),

      routes: {
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/onboarding': (context) => const OnboardingScreen(),

        // Parent Routes
        '/parent_login': (context) => const ParentLoginScreen(),
        '/parent_signup': (context) => const ParentSignupScreen(),
        '/signup': (context) => const ParentSignupScreen(), // Alias to prevent errors
        '/parent_home': (context) => const ParentHomeScreen(),
        '/parent_profile': (context) => const ParentProfileScreen(),

        // Doctor Routes
        '/doctor_login': (context) => const DoctorLoginScreen(),
        '/doctor_signup': (context) => const DoctorSignupScreen(),
        '/doctor_home': (context) => const DoctorHomeScreen(),
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
