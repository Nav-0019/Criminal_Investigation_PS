import 'package:flutter/material.dart';

class AppColors {
  static Color get primary => const Color(0xFF3B4DB8);
  static Color get primaryLight => AppTheme.isDark ? const Color(0xFF1E285D) : const Color(0xFFE6F1FB);

  static Color get background => AppTheme.isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F0);
  static Color get surface => AppTheme.isDark ? const Color(0xFF1E1E1E) : Colors.white;

  static Color get textDark => AppTheme.isDark ? const Color(0xFFF0F0F0) : const Color(0xFF1A1A18);
  static Color get textMid => AppTheme.isDark ? const Color(0xFFB0B0B0) : const Color(0xFF666666);
  static Color get textLight => AppTheme.isDark ? const Color(0xFF888888) : const Color(0xFF888888);
  static Color get textMuted => AppTheme.isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA);

  static Color get highRed => const Color(0xFFE24B4A);
  static Color get highRedDark => AppTheme.isDark ? const Color(0xFFF7C1C1) : const Color(0xFFA32D2D);
  static Color get highRedDeep => AppTheme.isDark ? const Color(0xFFFCEBEB) : const Color(0xFF791F1F);
  static Color get highRedBg => AppTheme.isDark ? const Color(0xFF3B1515) : const Color(0xFFFCEBEB);
  static Color get highRedBorder => AppTheme.isDark ? const Color(0xFF5E2222) : const Color(0xFFF7C1C1);
  static Color get highRedAccent => AppTheme.isDark ? const Color(0xFF2E1010) : const Color(0xFFFFF5F5);

  static Color get medAmber => const Color(0xFFBA7517);
  static Color get medAmberDark => AppTheme.isDark ? const Color(0xFFFAEEDA) : const Color(0xFF854F0B);
  static Color get medAmberBg => AppTheme.isDark ? const Color(0xFF332006) : const Color(0xFFFAEEDA);

  static Color get lowGreen => const Color(0xFF639922);
  static Color get lowGreenDark => AppTheme.isDark ? const Color(0xFFEAF3DE) : const Color(0xFF3B6D11);
  static Color get lowGreenDeep => AppTheme.isDark ? const Color(0xFFC0DD97) : const Color(0xFF27500A);
  static Color get lowGreenBg => AppTheme.isDark ? const Color(0xFF1A2A09) : const Color(0xFFEAF3DE);
  static Color get lowGreenBorder => AppTheme.isDark ? const Color(0xFF27420D) : const Color(0xFFC0DD97);
  static Color get lowGreenAccent => AppTheme.isDark ? const Color(0xFF121D06) : const Color(0xFFF3FAE8);

  static Color get divider => AppTheme.isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE);
  static Color get border => AppTheme.isDark ? const Color(0xFF3C3C3C) : const Color(0xFFD0D0CC);
}

class AppTextStyles {
  static TextStyle get heading => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.3,
  );

  static TextStyle get title => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.2,
  );

  static TextStyle get subtitle => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static TextStyle get body => TextStyle(
    fontSize: 14,
    color: AppColors.textMid,
    height: 1.5,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 12,
    color: AppColors.textLight,
  );

  static TextStyle get label => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 0.6,
  );
}

class AppTheme {
  static final ValueNotifier<bool> themeNotifier = ValueNotifier(false);
  static bool get isDark => themeNotifier.value;
  
  static void toggleTheme() {
    themeNotifier.value = !themeNotifier.value;
  }

  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
        appBarTheme: AppBarTheme(
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
