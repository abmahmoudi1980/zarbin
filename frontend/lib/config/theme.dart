import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Zarbin Gold Color
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color secondaryGold = Color(0xFFDAA520);

  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGold,
        brightness: Brightness.light,
        primary: const Color(0xFF745B00),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFFFE086),
        onPrimaryContainer: const Color(0xFF241A00),
        secondary: const Color(0xFF6A5D3F),
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFF3E1BB),
        onSecondaryContainer: const Color(0xFF231B04),
        surface: const Color(0xFFFFFBFF),
        onSurface: const Color(0xFF1E1B16),
        surfaceVariant: const Color(0xFFECE1CF),
        onSurfaceVariant: const Color(0xFF4D4639),
        outline: const Color(0xFF7E7667),
      ),
      textTheme: GoogleFonts.vazirmatnTextTheme(
        Theme.of(context).textTheme,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFFECE1CF),
            width: 1,
          ),
        ),
        color: const Color(0xFFFFFBFF),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGold,
        brightness: Brightness.dark,
        primary: const Color(0xFFFFE086),
        onPrimary: const Color(0xFF3D2F00),
        primaryContainer: const Color(0xFF584400),
        onPrimaryContainer: const Color(0xFFFFE086),
        secondary: const Color(0xFFD6C5A1),
        onSecondary: const Color(0xFF3A2F15),
        secondaryContainer: const Color(0xFF52452A),
        onSecondaryContainer: const Color(0xFFF3E1BB),
        surface: const Color(0xFF1E1B16),
        onSurface: const Color(0xFFE9E1D9),
        surfaceVariant: const Color(0xFF4D4639),
        onSurfaceVariant: const Color(0xFFD0C5B4),
        outline: const Color(0xFF998F80),
      ),
      textTheme: GoogleFonts.vazirmatnTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFF4D4639),
            width: 1,
          ),
        ),
        color: const Color(0xFF1E1B16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
      ),
    );
  }
}
