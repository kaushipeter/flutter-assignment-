import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF7EFCD);
  static const Color charcoal = Color(0xFF36454F);
  static const Color charcoalDark = Color(0xFF1A1A1A);
  static const Color softWhite = Color(0xFFFAFAFA);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        primary: gold,
        onPrimary: charcoalDark,
        secondary: charcoal,
        onSecondary: Colors.white,
        surface: softWhite,
      ),
      scaffoldBackgroundColor: softWhite,
      textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: charcoalDark,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: charcoalDark,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.figtree(
          color: charcoal,
        ),
        bodyMedium: GoogleFonts.figtree(
          color: charcoal,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: charcoalDark,
        foregroundColor: gold,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: charcoalDark,
        selectedItemColor: gold,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        primary: gold,
        onPrimary: charcoalDark,
        secondary: softWhite,
        onSecondary: charcoalDark,
        surface: charcoalDark,
        surfaceTint: charcoal,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: charcoalDark,
      textTheme: GoogleFonts.playfairDisplayTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: goldLight,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: gold,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.figtree(
          color: softWhite,
        ),
        bodyMedium: GoogleFonts.figtree(
          color: softWhite,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: charcoalDark,
        foregroundColor: gold,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: gold,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
  static ThemeData get eyeFriendlyTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold, // Keep brand color
        primary: gold,
        onPrimary: charcoalDark,
        secondary: const Color(0xFF5D4037), // Warm Brown
        surface: const Color(0xFFF5E6CA), // Warm Beige (Eye-friendly background)
        onSurface: const Color(0xFF3E3B32), // Dark, warm gray for text (Low contrast against beige)
      ),
      scaffoldBackgroundColor: const Color(0xFFF5E6CA), // Warm Beige
      textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: const Color(0xFF3E3B32), // Dark warm gray
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: const Color(0xFF5D4037), // Warm Brown
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.figtree(
          color: const Color(0xFF3E3B32), // Dark warm gray
        ),
        bodyMedium: GoogleFonts.figtree(
          color: const Color(0xFF3E3B32), 
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5E6CA), // Match background
        foregroundColor: Color(0xFF5D4037), // Warm Brown
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFE8D5B5), // Slightly darker beige
        selectedItemColor: Color(0xFF5D4037),
        unselectedItemColor: Color(0xFF8D6E63),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
