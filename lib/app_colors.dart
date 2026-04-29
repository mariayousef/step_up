import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1FCC79);
  static const Color secondary = Color(0xFFFF6464);
  static const Color background = Color(0xFFF4F5F7);
  static const Color textMain = Color(0xFF2E3E5C);
  static const Color textSecondary = Color(0xFF9FA5C0);
  static const Color outline = Color(0xFFD0DBEA);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1FCC79), Color(0xFF119E5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6464), Color(0xFFE24C4C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static BoxShadow softShadow = BoxShadow(
    color: const Color(0xFF2E3E5C).withOpacity(0.08),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
}
