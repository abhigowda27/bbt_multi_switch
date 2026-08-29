import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color buttonBackground;
  final Color buttonText;

  // Additional colors
  final Color white;
  final Color black;
  final Color grey;
  final Color backgroundDark;
  final Color red;
  final Color redButton;
  final Color green;
  final Color greenButton;

  const AppColors({
    required this.primary,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.buttonBackground,
    required this.buttonText,
    required this.white,
    required this.black,
    required this.grey,
    required this.backgroundDark,
    required this.red,
    required this.redButton,
    required this.green,
    required this.greenButton,
  });

  @override
  AppColors copyWith({
    Color? primary,
    Color? background,
    Color? textPrimary,
    Color? textSecondary,
    Color? buttonBackground,
    Color? buttonText,
    Color? appBar,
    Color? white,
    Color? black,
    Color? grey,
    Color? backgroundDark,
    Color? red,
    Color? redButton,
    Color? green,
    Color? greenButton,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      background: background ?? this.background,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      buttonBackground: buttonBackground ?? this.buttonBackground,
      buttonText: buttonText ?? this.buttonText,
      white: white ?? this.white,
      black: black ?? this.black,
      grey: grey ?? this.grey,
      backgroundDark: backgroundDark ?? this.backgroundDark,
      red: red ?? this.red,
      redButton: redButton ?? this.redButton,
      green: green ?? this.green,
      greenButton: greenButton ?? this.greenButton,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      background: Color.lerp(background, other.background, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      buttonBackground:
          Color.lerp(buttonBackground, other.buttonBackground, t)!,
      buttonText: Color.lerp(buttonText, other.buttonText, t)!,
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      grey: Color.lerp(grey, other.grey, t)!,
      backgroundDark: Color.lerp(backgroundDark, other.backgroundDark, t)!,
      red: Color.lerp(red, other.red, t)!,
      redButton: Color.lerp(redButton, other.redButton, t)!,
      green: Color.lerp(green, other.green, t)!,
      greenButton: Color.lerp(greenButton, other.greenButton, t)!,
    );
  }
}
