import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Palette (Warm Sand & Electric Violet)
  static const Color lightPrimary = Color(0xFF6366F1);
  static const Color lightBackground = Color(0xFFFAF9F6);
  static const Color lightSurface = Color(0xFFFAF9F6);
  static const Color lightOnSurface = Color(0xFF1C1917);
  static const Color lightSecondaryText = Color(0xFF78716C);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightInputBg = Color(0xFFF5F5F4);
  static const Color lightBorder = Color(0xFFE7E5E4);

  // Dark Palette (Midnight Obsidian & Indigo Glow)
  static const Color darkPrimary = Color(0xFF4F7CFF);
  static const Color darkBackground = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF1E222D);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFA1A8B3);
  static const Color darkCardBg = Color(0xFF171A21);
  static const Color darkInputBg = Color(0xFF1E222D);
  static const Color darkBorder = Color(0xFF282D3A);

  // Errors & Success
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  static ThemeData get lightTheme {
    return _buildTheme(
      primary: lightPrimary,
      background: lightBackground,
      surface: lightSurface,
      onSurface: lightOnSurface,
      secondaryText: lightSecondaryText,
      cardBg: lightCardBg,
      inputBg: lightInputBg,
      borderVariant: lightBorder,
      brightness: Brightness.light,
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      primary: darkPrimary,
      background: darkBackground,
      surface: darkSurface,
      onSurface: darkOnSurface,
      secondaryText: darkSecondaryText,
      cardBg: darkCardBg,
      inputBg: darkInputBg,
      borderVariant: darkBorder,
      brightness: Brightness.dark,
    );
  }

  static ThemeData _buildTheme({
    required Color primary,
    required Color background,
    required Color surface,
    required Color onSurface,
    required Color secondaryText,
    required Color cardBg,
    required Color inputBg,
    required Color borderVariant,
    required Brightness brightness,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
        secondary: brightness == Brightness.dark ? const Color(0xFF8B5CF6) : primary.withOpacity(0.8),
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        background: background,
        onBackground: onSurface,
        surface: surface,
        onSurface: onSurface,
        surfaceVariant: cardBg,
        onSurfaceVariant: onSurface,
        outline: borderVariant,
      ),
      dividerColor: borderVariant,
      cardColor: cardBg,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          height: 1.2,
          letterSpacing: -1.0,
          color: onSurface,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.25,
          letterSpacing: -0.8,
          color: onSurface,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.33,
          letterSpacing: -0.5,
          color: onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.55,
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: onSurface,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.43,
          color: onSurface,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.33,
          letterSpacing: 1.2,
          color: secondaryText,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: borderVariant, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: secondaryText.withOpacity(0.5),
        ),
      ),
    );
  }
}
