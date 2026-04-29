import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/police_home_screen.dart';

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
  final isLoggedIn = prefs.getString('userName') != null;
  final userRole = prefs.getString('userRole') ?? 'Citizen';

  runApp(NammaShieldApp(
    hasCompletedOnboarding: hasCompletedOnboarding,
    isLoggedIn: isLoggedIn,
    userRole: userRole,
  ));
}

class NammaShieldApp extends StatelessWidget {
  final bool hasCompletedOnboarding;
  final bool isLoggedIn;
  final String userRole;
  
  const NammaShieldApp({
    super.key, 
    required this.hasCompletedOnboarding,
    required this.isLoggedIn,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, isDark, _) {
        Widget initialScreen;
        if (!isLoggedIn) {
          initialScreen = const AuthScreen();
        } else if (userRole == 'Police') {
          initialScreen = const PoliceHomeScreen();
        } else if (!hasCompletedOnboarding) {
          initialScreen = const SplashScreen();
        } else {
          initialScreen = const HomeScreen();
        }

        return MaterialApp(
          title: 'NammaShield',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: initialScreen,
        );
      },
    );
  }
}