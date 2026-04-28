import 'package:flutter/material.dart';

class AppColors {
  // Primary brand
  static const primary = Color(0xFF3B4DB8);
  static const primaryLight = Color(0xFFE6F1FB);

  // Background
  static const background = Color(0xFFF5F5F0);
  static const surface = Colors.white;

  // Text
  static const textDark = Color(0xFF1A1A18);
  static const textMid = Color(0xFF666666);
  static const textLight = Color(0xFF888888);
  static const textMuted = Color(0xFFAAAAAA);

  // Risk — High
  static const highRed = Color(0xFFE24B4A);
  static const highRedDark = Color(0xFFA32D2D);
  static const highRedDeep = Color(0xFF791F1F);
  static const highRedBg = Color(0xFFFCEBEB);
  static const highRedBorder = Color(0xFFF7C1C1);
  static const highRedAccent = Color(0xFFFFF5F5);

  // Risk — Medium
  static const medAmber = Color(0xFFBA7517);
  static const medAmberDark = Color(0xFF854F0B);
  static const medAmberBg = Color(0xFFFAEEDA);

  // Risk — Low
  static const lowGreen = Color(0xFF639922);
  static const lowGreenDark = Color(0xFF3B6D11);
  static const lowGreenDeep = Color(0xFF27500A);
  static const lowGreenBg = Color(0xFFEAF3DE);
  static const lowGreenBorder = Color(0xFFC0DD97);
  static const lowGreenAccent = Color(0xFFF3FAE8);

  // Divider / border
  static const divider = Color(0xFFEEEEEE);
  static const border = Color(0xFFD0D0CC);
}

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.3,
  );

  static const title = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.2,
  );

  static const subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const body = TextStyle(
    fontSize: 14,
    color: AppColors.textMid,
    height: 1.5,
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textLight,
  );

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 0.6,
  );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textDark),
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        useMaterial3: true,
      );
}
