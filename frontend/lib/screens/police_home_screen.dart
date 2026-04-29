import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'police_dashboard_screen.dart';
import 'police_case_registry_screen.dart';
import 'settings_screen.dart'; // We can just reuse settings screen but handle logout for police

class PoliceHomeScreen extends StatefulWidget {
  const PoliceHomeScreen({super.key});

  @override
  State<PoliceHomeScreen> createState() => _PoliceHomeScreenState();
}

class _PoliceHomeScreenState extends State<PoliceHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    PoliceDashboardScreen(),
    PoliceCaseRegistryScreen(),
    SettingsScreen(), // Reusing the generic settings screen
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textLight,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings),
                label: 'Command',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder_shared),
                label: 'Registry',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
