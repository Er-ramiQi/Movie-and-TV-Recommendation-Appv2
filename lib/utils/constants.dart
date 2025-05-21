import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDark = Color(0xFF1F1D36);
  static const Color primaryLight = Color(0xFF3F3B6C);
  static const Color accent = Color(0xFFE9A6A6);
  static const Color accentLight = Color(0xFFF1D4D4);
  static const Color textDark = Color(0xFF121212);
  static const Color textLight = Color(0xFFF5F5F5);
  static const Color background = Color(0xFF0A0A0A);
  static const Color cardDark = Color(0xFF1D1D1D);
  static const Color cardLight = Color(0xFFF0F0F0);
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF4CAF50);
  static const Color starYellow = Color(0xFFFFD700);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryDark,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: AppColors.primaryDark,
      secondary: AppColors.accent,
      surface: AppColors.background,
      error: AppColors.error,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textLight,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textLight,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.primaryDark,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.textLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textLight,
        side: const BorderSide(color: AppColors.primaryLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  static ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: AppColors.primaryLight,
    colorScheme: const ColorScheme.light().copyWith(
      primary: AppColors.primaryLight,
      secondary: AppColors.accent,
      surface: Colors.white,
      error: AppColors.error,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textDark,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        side: const BorderSide(color: AppColors.primaryLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}

class AppConstants {
  static const String appName = 'Limux';
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;
  
  static const String prefsKey = 'user_preferences';
  static const String profileKey = 'user_profile';
  
  static const String genericErrorMessage = 'Oups ! Une erreur est survenue. Veuillez réessayer.';
}

class ApiEndpoints {
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/';
  static const String posterSize = 'w342';
  static const String backdropSize = 'w780';
  static const String profileSize = 'w185';
  
  static String getPosterUrl(String path) {
    if (path.isEmpty) return '';
    return '$imageBaseUrl$posterSize$path';
  }
  
  static String getBackdropUrl(String path) {
    if (path.isEmpty) return '';
    return '$imageBaseUrl$backdropSize$path';
  }
  
  static String getProfileUrl(String path) {
    if (path.isEmpty) return '';
    return '$imageBaseUrl$profileSize$path';
  }
}