import 'package:bbtml_new/theme/app_colors.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightAppColors.primary.withValues(
        alpha: 0.8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50), // roundness
      ),
    ),
    scaffoldBackgroundColor: lightAppColors.background,
    fontFamily: "OpenSans",
    extensions: const <ThemeExtension<dynamic>>[lightAppColors],
    appBarTheme: AppBarTheme(
      centerTitle: true,
      titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: lightAppColors.background,
          fontSize: 24),
      backgroundColor: lightAppColors.primary,
      foregroundColor: lightAppColors.background,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        foregroundColor: lightAppColors.primary,
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black54,
        height: 1.4,
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    dividerColor: lightAppColors.textSecondary,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: lightAppColors.buttonBackground,
        foregroundColor: lightAppColors.buttonText,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: lightAppColors.textPrimary),
      displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w600,
          color: lightAppColors.textPrimary),
      displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w500,
          color: lightAppColors.textPrimary),
      headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: lightAppColors.textPrimary),
      headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: lightAppColors.textSecondary),
      headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: lightAppColors.textPrimary),
      titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: lightAppColors.textPrimary),
      titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightAppColors.textPrimary),
      titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: lightAppColors.textSecondary),
      bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: lightAppColors.textSecondary),
      bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: lightAppColors.textSecondary),
      bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: lightAppColors.textSecondary),
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: lightAppColors.primary),
      labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: lightAppColors.buttonBackground),
      labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: lightAppColors.grey),
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightAppColors.primary.withValues(
        alpha: 0.8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50), // roundness
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFF2C383F),
    fontFamily: "OpenSans",
    extensions: const <ThemeExtension<dynamic>>[darkAppColors],
    appBarTheme: AppBarTheme(
      centerTitle: true,
      titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: darkAppColors.textPrimary,
          fontSize: 24),
      backgroundColor: darkAppColors.primary,
      foregroundColor: darkAppColors.textPrimary,
    ),
    dividerColor: darkAppColors.textPrimary,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: darkAppColors.buttonBackground,
        foregroundColor: darkAppColors.buttonText,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: darkAppColors.textPrimary),
      displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w600,
          color: darkAppColors.textPrimary),
      displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w500,
          color: darkAppColors.textPrimary),
      headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkAppColors.textPrimary),
      headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: darkAppColors.textPrimary),
      headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: darkAppColors.textPrimary),
      titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: darkAppColors.textPrimary),
      titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkAppColors.textSecondary),
      titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkAppColors.textSecondary),
      bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkAppColors.textPrimary),
      bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkAppColors.textSecondary),
      bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkAppColors.textSecondary),
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkAppColors.primary),
      labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkAppColors.primary),
      labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w400, color: darkAppColors.grey),
    ),
    dialogTheme: DialogThemeData(backgroundColor: darkAppColors.background),
  );
}

const lightAppColors = AppColors(
  primary: Colors.blueAccent, // A fresh teal for primary color
  background: Color(0xFFFDFDFD), // Soft white background
  textPrimary: Color(0xFF1C1C1E), // Near-black for good readability
  textSecondary: Color(0xFF6E6E73), // Neutral gray for secondary text
  buttonBackground:
      Colors.lightBlueAccent, // Slightly lighter than primary for buttons
  buttonText: Color(0xFFFFFFFF), // White text for buttons

  // Additional
  white: Color(0xFFFFFFFF),
  black: Color(0xFF000000),
  grey: Color(0xFFB0BEC5), // Cool gray for borders, disabled states
  backgroundDark: Color(0xFF9BD2F1), // Subtle light-gray background
  red: Color(0xFFF58D8D), // Vibrant red for alerts
  redButton: Color(0xFFD32F2F), // Deep red for danger buttons
  green: Color(0xFF66BB6A), // Medium green for success icons
  greenButton: Color(0xFF07601A), // Strong green for confirm buttons
);

const darkAppColors = AppColors(
  primary: Colors.blueAccent, // A fresh teal for primary color
  background: Color(0xFF121212), // True dark (Google Material standard)
  textPrimary: Color(0xFFE0E0E0), // Soft white for primary text (high contrast)
  textSecondary: Color(0xFFB0B0B0), // Muted gray for secondary text
  buttonBackground:
      Colors.blue, // Same vibrant teal for buttons (consistent branding)
  buttonText: Color(0xFF121212), // Dark text on bright button for contrast

  // Additional
  white: Color(0xFFFFFFFF),
  black: Color(0xFF000000),
  grey: Color(0xFF455A64), // Cool blue-gray (elevated surfaces, borders)
  backgroundDark:
      Color(0xFF1E1E1E), // Slightly elevated cards/floating surfaces
  red: Color(0xFFF58D8D), // Keep same vibrant red (alerts should stand out)
  redButton: Color(0xFFE57373), // Softer red button (avoids harshness in dark)
  green: Color(0xFF81C784), // Lighter green for visibility
  greenButton: Color(0xFF66BB6A), // Brighter confirm button (clear affordance)
);
