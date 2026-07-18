import 'package:flutter/material.dart';

class KidTheme {
  // Color Palette - Child-friendly, high-contrast, cheerful
  static const Color background = Color(0xFFFFFBEA);      // Warm, eye-friendly light yellow
  static const Color primaryBlue = Color(0xFF00A6FF);      // Deep sky dolphin blue
  static const Color primaryOrange = Color(0xFFFF7B39);    // Coral orange for action buttons
  static const Color textDark = Color(0xFF1E293B);         // Very dark blue-gray for high contrast text
  static const Color successGreen = Color(0xFF4BD37B);     // Bright green for correct state
  static const Color cardBg = Color(0xFFFFFFFF);           // White card bg
  static const Color accentYellow = Color(0xFFFFD54F);     // Yellow for stars and decorations

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: primaryOrange,
        background: background,
      ),
      textTheme: const TextTheme(
        // Extra large for child instruction
        displayLarge: TextStyle(
          fontSize: 38.0,
          fontWeight: FontWeight.w900,
          color: textDark,
          height: 1.2,
        ),
        // Used for target syllables/vowels
        displayMedium: TextStyle(
          fontSize: 72.0,
          fontWeight: FontWeight.w900,
          color: textDark,
          letterSpacing: 2,
        ),
        // Heading styles
        headlineMedium: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        // Standard readable button / card text
        bodyLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        // Mascot speech bubble text
        bodyMedium: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 6,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
          shadowColor: primaryOrange.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  // Rounded card decoration with bold, high-contrast border and shadows
  static BoxDecoration kidCardDecoration({Color color = cardBg, Color borderColor = primaryBlue}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(
        color: borderColor,
        width: 4,
      ),
      boxShadow: [
        BoxShadow(
          color: borderColor.withValues(alpha: 0.2),
          offset: const Offset(0, 8),
          blurRadius: 0,
        ),
      ],
    );
  }

  // Speech bubble decoration
  static BoxDecoration speechBubbleDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
        bottomLeft: Radius.circular(4),
      ),
      border: Border.all(
        color: textDark,
        width: 3,
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          offset: Offset(0, 4),
          blurRadius: 0,
        ),
      ],
    );
  }
}
