import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode { white, blue, black }

class AppTheme {
  // --- White Theme Colors ---
  static const Color whitePrimary = Color(0xFF2563EB);
  static const Color whiteBackground = Color(0xFFFFFFFF);
  static const Color whiteSurface = Color(0xFFF1F5F9);
  static const Color whiteText = Color(0xFF1E293B);

  // --- Blue Theme Colors ---
  static const Color blueBackground = Color(0xFF1E40AF);
  static const Color blueAccent = Color(0xFF3B82F6);
  static const Color blueSurface = Color(0xFFE0E7FF);
  // static const Color blueText = Color(0xFFFFFFFF); // implied white

  // --- Black Theme Colors ---
  static const Color blackBackground = Color(0xFF0F172A);
  static const Color blackSurface = Color(0xFF1E293B);
  static const Color blackAccent = Color(0xFF60A5FA);
  static const Color blackText = Color(0xFFF8FAFC);

  // --- Shared Colors ---
  static const Color errorColor = Color(0xFFE74C3C);

  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.white:
        return _buildTheme(
          brightness: Brightness.light,
          primary: whitePrimary,
          background: whiteBackground,
          surface: whiteSurface,
          onSurface: whiteText,
          textColor: whiteText,
        );
      case AppThemeMode.blue:
        return _buildTheme(
          brightness: Brightness.dark, // Context indicates dark bg
          primary: blueAccent,
          background: blueBackground,
          surface: blueSurface,
          onSurface: Colors
              .black87, // Surface is light, so text on surface should be dark
          textColor: Colors.white, // Text on background should be white
          isBlueTheme: true,
        );
      case AppThemeMode.black:
        return _buildTheme(
          brightness: Brightness.dark,
          primary: blackAccent,
          background: blackBackground,
          surface: blackSurface,
          onSurface: blackText,
          textColor: blackText,
        );
    }
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color background,
    required Color surface,
    required Color onSurface,
    required Color textColor,
    bool isBlueTheme = false,
  }) {
    final baseTextTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    return ThemeData(
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: primary,
        onSecondary: Colors.white,
        error: errorColor,
        onError: Colors.white,
        background: background,
        onBackground: textColor,
        surface: surface,
        onSurface: onSurface,
      ),
      textTheme: GoogleFonts.latoTextTheme(
        baseTextTheme,
      ).apply(bodyColor: textColor, displayColor: textColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: isBlueTheme ? 0 : 5, // Flat look for modern blue theme?
        ),
      ),
      iconTheme: IconThemeData(color: textColor),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: GoogleFonts.poppins(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper to maintain legacy static styles if needed during transition,
  // but preferably we remove these.
  static const LinearGradient gradientBackground = LinearGradient(
    colors: [whitePrimary, Color(0xFF50E3C2)], // Legacy fallback
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
