// lib/utils/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF0D7377);
  static const Color primaryLight = Color(0xFF14A085);
  static const Color primaryDark = Color(0xFF0A5C60);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF8E8E);
  static const Color gold = Color(0xFFFFB300);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceCard = Color(0xFF16213E);
  static const Color surfaceElevated = Color(0xFF0F3460);
  static const Color textPrimary = Color(0xFFF0F4F8);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF546E7A);

  // Light theme specific
  static const Color lightBg = Color(0xFFF5F7FA);
  static const Color lightCard = Colors.white;
  static const Color lightText = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF4A5568);
  static const Color lightTextMuted = Color(0xFF9AA5B4);
  static const Color lightBorder = Color(0xFFE2E8F0);

  static const Color underweightColor = Color(0xFF5B8AF0);
  static const Color normalColor = Color(0xFF06D6A0);
  static const Color overweightColor = Color(0xFFFFB300);
  static const Color obeseColor = Color(0xFFFF6B6B);

  static Color getCardColor(bool isDark) => isDark ? surfaceCard : lightCard;
  static Color getBgColor(bool isDark) => isDark ? surface : lightBg;
  static Color getTextColor(bool isDark) => isDark ? textPrimary : lightText;
  static Color getTextSecondary(bool isDark) => isDark ? textSecondary : lightTextSecondary;
  static Color getTextMuted(bool isDark) => isDark ? textMuted : lightTextMuted;
  static Color getBorderColor(bool isDark) => isDark ? surfaceElevated : lightBorder;

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: surface,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary, secondary: accent,
      surface: surfaceCard, onPrimary: Colors.white, onSecondary: Colors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textSecondary),
      bodySmall: TextStyle(color: textMuted),
    )),
    cardTheme: CardThemeData(color: surfaceCard, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    appBarTheme: AppBarTheme(
      backgroundColor: surface, elevation: 0,
      titleTextStyle: GoogleFonts.poppins(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: surfaceElevated.withValues(alpha: 0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primary.withValues(alpha: 0.3))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 2)),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: primary,
    colorScheme: const ColorScheme.light(
      primary: primary, secondary: accent,
      surface: lightCard, onPrimary: Colors.white, onSecondary: Colors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
      bodyLarge: TextStyle(color: lightText),
      bodyMedium: TextStyle(color: lightTextSecondary),
      bodySmall: TextStyle(color: lightTextMuted),
    )),
    cardTheme: CardThemeData(
      color: lightCard, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: primary.withValues(alpha: 0.08),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightCard, elevation: 0,
      titleTextStyle: GoogleFonts.poppins(color: lightText, fontSize: 20, fontWeight: FontWeight.w700),
      iconTheme: const IconThemeData(color: lightText),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: lightBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primary.withValues(alpha: 0.2))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 2)),
      labelStyle: const TextStyle(color: lightTextSecondary),
      hintStyle: const TextStyle(color: lightTextMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    dividerTheme: const DividerThemeData(color: lightBorder),
  );
}

class BMIUtils {
  static double calculateBMI(double weight, double height) {
    final h = height / 100;
    return weight / (h * h);
  }
  static String getCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Underweight': return AppTheme.underweightColor;
      case 'Normal': return AppTheme.normalColor;
      case 'Overweight': return AppTheme.overweightColor;
      case 'Obese': return AppTheme.obeseColor;
      default: return AppTheme.primary;
    }
  }
  static String getCategoryEmoji(String category) {
    switch (category) {
      case 'Underweight': return '🔵';
      case 'Normal': return '✅';
      case 'Overweight': return '🟡';
      case 'Obese': return '🔴';
      default: return '⚪';
    }
  }
  static double getIdealWeightMin(double height, String gender) {
    final h = height - 152.4;
    return gender == 'Male' ? 50.0 + (2.3 * (h / 2.54)) : 45.5 + (2.3 * (h / 2.54));
  }
  static double getIdealWeightMax(double height, String gender) => getIdealWeightMin(height, gender) + 5;
  static String getSleepStatus(double hours) {
    if (hours < 6) return 'Insufficient';
    if (hours <= 9) return 'Optimal';
    return 'Excessive';
  }
}
