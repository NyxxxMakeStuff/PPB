import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFAF7EF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEBE6D8);
  static const Color cardSubtleBg = Color(0xFFF4F0E5);
  
  static const Color darkCharcoal = Color(0xFF1E2421);
  static const Color textSecondary = Color(0xFF747974);
  static const Color textSubtle = Color(0xFF9EA39E);
  
  static const Color accentOrange = Color(0xFFC84C24);
  static const Color accentOrangeLight = Color(0xFFFBF0EC);
  
  static const Color greenIndicator = Color(0xFF386B49);
  static const Color yellowIndicator = Color(0xFFD89B33);
  static const Color tealIndicator = Color(0xFF3B6B77);
  
  static const Color divider = Color(0xFFE6E1D3);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkCharcoal,
        primary: AppColors.darkCharcoal,
        secondary: AppColors.accentOrange,
        background: AppColors.background,
        surface: AppColors.cardBg,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkCharcoal),
        titleTextStyle: TextStyle(
          color: AppColors.darkCharcoal,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkCharcoal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkCharcoal,
          side: const BorderSide(color: AppColors.darkCharcoal, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4CFC3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4CFC3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkCharcoal, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFFA5A096), fontSize: 15),
      ),
    );
  }

  static TextStyle serifTitle({double fontSize = 28, FontWeight fontWeight = FontWeight.bold, Color color = AppColors.darkCharcoal}) {
    return TextStyle(
      fontFamily: 'serif',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.15,
    );
  }

  static TextStyle uppercaseSubHeader({double fontSize = 12, Color color = AppColors.textSecondary}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: color,
    );
  }
}
