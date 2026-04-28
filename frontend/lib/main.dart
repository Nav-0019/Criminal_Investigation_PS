import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;

  runApp(NammaShieldApp(hasCompletedOnboarding: hasCompletedOnboarding));
}

class NammaShieldApp extends StatelessWidget {
  final bool hasCompletedOnboarding;
  
  const NammaShieldApp({super.key, required this.hasCompletedOnboarding});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          key: ValueKey(isDark), // Force complete rebuild on theme change
          title: 'NammaShield',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: hasCompletedOnboarding ? const HomeScreen() : const SplashScreen(),
        );
      },
    );
  }
}