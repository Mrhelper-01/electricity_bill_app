import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0F0F23);
  static const surface = Color(0xFF1A1A35);
  static const card = Color(0xFF1E1E45);
  static const cardAlt = Color(0xFF252555);
  static const primary = Color(0xFFF5A623);
  static const primaryDark = Color(0xFFE08B00);
  static const accent = Color(0xFFFFD700);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFFF5252);
  static const warning = Color(0xFFFFC107);
  static const info = Color(0xFF29B6F6);
  static const textPrimary = Color(0xFFF0F0FF);
  static const textSecondary = Color(0xFF9090BB);
  static const textHint = Color(0xFF606080);
  static const divider = Color(0xFF2A2A55);
  static const inputBg = Color(0xFF252550);
  static const navBg = Color(0xFF161630);
  static const glow = Color(0x40FFD700);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: Color(0xFF1A1A2E),
          onSurface: AppColors.textPrimary,
        ),
        textTheme:
            GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
          headlineLarge: GoogleFonts.orbitron(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24),
          headlineMedium: GoogleFonts.orbitron(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20),
          titleLarge: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18),
          titleMedium: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 16),
          bodyLarge:
              GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 15),
          bodyMedium:
              GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
          bodySmall:
              GoogleFonts.poppins(color: AppColors.textHint, fontSize: 12),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.navBg,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.orbitron(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          iconTheme: const IconThemeData(color: AppColors.primary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.navBg,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBg,
          labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
          hintStyle:
              GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF3A3A70), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: const Color(0xFF1A1A2E),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
            elevation: 0,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.cardAlt,
          contentTextStyle:
              GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
        ),
      );
}

// ---- Electricity Rate Calculator ----
class ElectricityCalculator {
  static const List<Map<String, dynamic>> _blocks = [
    {'limit': 200, 'rate': 0.218},
    {'limit': 100, 'rate': 0.334},
    {'limit': 300, 'rate': 0.516},
    {'limit': 400, 'rate': 0.546},
  ];

  static double calculateTotalCharges(double units) {
    double total = 0;
    double remaining = units;

    for (final block in _blocks) {
      if (remaining <= 0) break;
      final int limit = block['limit'];
      final double rate = block['rate'];
      final double used = remaining > limit ? limit.toDouble() : remaining;
      total += used * rate;
      remaining -= used;
    }
    return total;
  }

  static double calculateFinalCost(double totalCharges, double rebatePercent) {
    return totalCharges - (totalCharges * rebatePercent / 100);
  }

  static String formatRM(double amount) => 'RM ${amount.toStringAsFixed(2)}';
}

const List<String> kMonths = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
