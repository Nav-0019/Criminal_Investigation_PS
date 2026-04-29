import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  final List<_PermItem> _perms = [
    _PermItem(
      icon: '🎙️',
      title: 'Microphone',
      subtitle: 'Record live call audio for real-time analysis',
      color: Color(0xFFE6F1FB),
      permission: Permission.microphone,
    ),
    _PermItem(
      icon: '🔔',
      title: 'Notifications',
      subtitle: 'Alert you instantly when a high-risk call is detected',
      color: Color(0xFFFFF3E0),
      permission: Permission.notification,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Request individual permission
  Future<void> _requestPermission(Permission permission) async {
    var status = await permission.request();
    if (status.isPermanentlyDenied) {
      _showSettingsDialog();
    }
  }

  // Request permissions and navigate to home
  Future<void> _requestPermissionsAndContinue() async {
    // Request microphone permission
    var micStatus = await Permission.microphone.request();
    // Request notification permission
    var notifStatus = await Permission.notification.request();
    
    if (micStatus.isGranted || notifStatus.isGranted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // Show settings dialog if permanently denied
      if (mounted) {
        _showSettingsDialog();
      }
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text(
          'Some permissions are required for the app to work properly. '
          'Please enable them in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48),

                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text('🛡️', style: TextStyle(fontSize: 26)),
                  ),
                ),

                SizedBox(height: 20),

                Text('Allow Access', style: AppTextStyles.heading),

                SizedBox(height: 8),

                Text(
                  'NammaShield needs the following permissions to protect you.',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textLight),
                ),

                SizedBox(height: 36),

                ...List.generate(_perms.length, (i) {
                  return _PermCard(
                    item: _perms[i],
                    onTap: () => _requestPermission(_perms[i].permission),
                  );
                }),

                const Spacer(),

                _PrimaryButton(
                  label: 'Allow All & Continue',
                  onTap: _requestPermissionsAndContinue,
                ),

                SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── MODELS ─────────────────────────────

class _PermItem {
  final String icon, title, subtitle;
  final Color color;
  final Permission permission;

  const _PermItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.permission,
  });
}

// ───────────────────────────── UI CARD ─────────────────────────────

class _PermCard extends StatelessWidget {
  final _PermItem item;
  final VoidCallback? onTap;

  const _PermCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(item.icon, style: TextStyle(fontSize: 22)),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.subtitle),
                  SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── BUTTON ─────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}