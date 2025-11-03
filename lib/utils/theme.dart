import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyText = Color(0x993C3C43); // 60% opacity
  static const Color black = Color(0xFF000000);
  static const Color greyLight = Color(0x33646161); // 20% opacity
  static const Color primaryDark = Color(0xFF0E433F);
  static const Color backgroundLight = Color(0x80F0F3E9); // 50% opacity
  static const Color greyMedium = Color(0xFFACA7A7);
  static const Color primaryGreen = Color(0xFF0F766E);
  static const Color backgroundWhite = Color(0xFFF0F3E9);
  static const Color blackOverlay = Color(0x2E000000); // 18% opacity
  static const Color yellow = Color(0xFFFFDF0E);
  static const Color greyBackground = Color(0xFFD9D9D9);
  static const Color blackMedium = Color(0xAB000000); // 67% opacity
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleRed = Color(0xFFEB4335);
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color errorRed = Color(0xFFFF0000);
  static const Color greyDisabled = Color(0xFFCACACA);
  static const Color primaryDarkTransparent = Color(0x800E433F); // 50% opacity

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primaryDark,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryDark,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: primaryDark,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: black,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: greyText,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: greyText,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: white,
  );

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  );

  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: white,
    foregroundColor: primaryGreen,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: primaryGreen, width: 1),
    ),
    elevation: 0,
  );

  static ButtonStyle googleButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: white,
    foregroundColor: black,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: greyDisabled, width: 1),
    ),
    elevation: 1,
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: bodyMedium,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: backgroundWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: greyDisabled, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: greyDisabled, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
    );
  }

  // Theme Data
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: white,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: primaryDark,
      error: errorRed,
      surface: white,
      onPrimary: white,
      onSecondary: white,
      onError: white,
      onSurface: black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: primaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headingMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: greyDisabled, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: greyDisabled, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
    ),
  );
}
