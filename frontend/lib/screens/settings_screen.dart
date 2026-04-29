import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _storeHistory = true;
  String _alertThreshold = 'Medium & above';
  String _userName = 'Protected User';
  bool _isPolice = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Protected User';
      _storeHistory = prefs.getBool('storeHistory') ?? true;
      final role = prefs.getString('userRole') ?? 'Citizen';
      if (role == 'Police') {
        _isPolice = true;
        _userName += ' (Police Official)';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      children: [
        if (widget.embedded) ...[
          Text('Settings', style: AppTextStyles.title),
          SizedBox(height: 20),
        ],

        // ── Profile card ───────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B4DB8), Color(0xFF5865D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text('👤', style: TextStyle(fontSize: 24))),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userName,
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    SizedBox(height: 3),
                    Text('NammaShield v1.0 · Team Dream Smith',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 20),
            ],
          ),
        ),

        if (!_isPolice) ...[
          SizedBox(height: 28),
          // ── ANALYSIS Section ───────────────────────────────────────────────
          _SectionLabel(label: 'ANALYSIS'),
          SizedBox(height: 10),

          _SettingsCard(children: [
            _NavRow(
              icon: '🔔',
              iconBg: Color(0xFFFFF3E0),
              title: 'Alert threshold',
              subtitle: 'Notify at: $_alertThreshold',
              onTap: () => _showThresholdSheet(context),
            ),
          ]),
        ],

        SizedBox(height: 20),

        // ── APPEARANCE Section ─────────────────────────────────────────────
        _SectionLabel(label: 'APPEARANCE'),
        SizedBox(height: 10),

        _SettingsCard(children: [
          ValueListenableBuilder<bool>(
            valueListenable: AppTheme.themeNotifier,
            builder: (context, isDark, _) {
              return _ToggleRow(
                icon: '🌙',
                iconBg: Color(0xFFE8E5FA),
                title: 'Dark mode',
                subtitle: 'Switch to a darker theme',
                value: isDark,
                onChanged: (v) => AppTheme.toggleTheme(),
              );
            },
          ),
        ]),

        if (!_isPolice) ...[
          SizedBox(height: 20),

          // ── PRIVACY Section ────────────────────────────────────────────────
          _SectionLabel(label: 'PRIVACY'),
          SizedBox(height: 10),

          _SettingsCard(children: [
            _ToggleRow(
              icon: '💾',
              iconBg: Color(0xFFEAF3DE),
              title: 'Store analysis history',
              subtitle: 'Secure Local Persistence',
              value: _storeHistory,
              onChanged: (v) async {
                setState(() => _storeHistory = v);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('storeHistory', v);
              },
            ),
          ]),

          SizedBox(height: 20),

          // ── ABOUT Section ──────────────────────────────────────────────────
          _SectionLabel(label: 'ABOUT'),
          SizedBox(height: 10),

          _SettingsCard(children: [
            _NavRow(
              icon: '📋',
              iconBg: Color(0xFFF5F5F0),
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              onTap: () => _showPrivacyPolicy(context),
            ),
            Divider(height: 1, color: AppColors.divider),
            _NavRow(
              icon: '⭐',
              iconBg: Color(0xFFFFF9E6),
              title: 'Rate NammaShield',
              subtitle: 'Help us improve',
              onTap: () => _showRatingDialog(context),
            ),
            Divider(height: 1, color: AppColors.divider),
            _NavRow(
              icon: '🐛',
              iconBg: Color(0xFFFCEBEB),
              title: 'Report a bug',
              subtitle: 'Send feedback to Team Dream Smith',
              onTap: () async {
                final uri = Uri.parse('mailto:shubhamchauhan0019@gmail.com?subject=NammaShield%20Bug%20Report');
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open email app. Please email shubhamchauhan0019@gmail.com')),
                    );
                  }
                }
              },
            ),
          ]),
        ],

        SizedBox(height: 20),

        // ── ACCOUNT Section ────────────────────────────────────────────────
        _SectionLabel(label: 'ACCOUNT'),
        SizedBox(height: 10),

        _SettingsCard(children: [
          _NavRow(
            icon: '🚪',
            iconBg: Color(0xFFFFEBEE),
            title: 'Log Out',
            subtitle: 'Sign out of NammaShield',
            onTap: () => _handleLogout(context),
          ),
        ]),

        SizedBox(height: 32),

        // ── Footer ─────────────────────────────────────────────────────────
        Center(
          child: Column(
            children: [
              Image.asset('assets/logo.png', height: 40),
              SizedBox(height: 6),
              Text('NammaShield',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              SizedBox(height: 2),
              Text('v1.0.0 · Team Dream Smith',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
              SizedBox(height: 2),
              Text('AI-Powered Scam Call Detection',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  void _showThresholdSheet(BuildContext context) {
    final options = ['Low & above', 'Medium & above', 'High only'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alert Threshold', style: AppTextStyles.title),
            SizedBox(height: 6),
            Text('Receive notifications when risk is at or above:',
                style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
            SizedBox(height: 20),
            ...options.map((opt) => GestureDetector(
                  onTap: () {
                    setState(() => _alertThreshold = opt);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _alertThreshold == opt ? AppColors.primaryLight : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _alertThreshold == opt ? AppColors.primary : AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(opt,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: _alertThreshold == opt
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: _alertThreshold == opt
                                      ? AppColors.primary
                                      : AppColors.textDark)),
                        ),
                        if (_alertThreshold == opt)
                          Icon(Icons.check_circle_rounded,
                              color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                )),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('Privacy Policy', style: AppTextStyles.title),
        content: SingleChildScrollView(
          child: Text(
            'At NammaShield by Team Dream Smith, your privacy is our top priority.\n\n'
            '1. Local Processing: All audio processing and history logs are stored exclusively on your device by default.\n\n'
            '2. Data Security: Audio files uploaded for AI analysis are processed securely and deleted immediately after scoring. '
            'We do not store your personal conversations or audio files on our servers.\n\n'
            '3. Contributions: If you opt-in to contribute, only anonymized metadata (like scam keywords) is shared to improve the global detection model.\n\n'
            'By using NammaShield, you agree to these terms.',
            style: TextStyle(color: AppColors.textDark, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Understood', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    int rating = 5;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.background,
          title: Text('Rate NammaShield', style: AppTextStyles.title, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How is your experience so far?', style: TextStyle(color: AppColors.textLight)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => rating = index + 1),
                    child: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Color(0xFFFFB800),
                      size: 40,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('Thank you for rating us $rating stars!')),
                );
              },
              child: Text('Submit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userRole');

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (ctx) => const AuthScreen()),
        (route) => false,
      );
    }
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String icon, title, subtitle;
  final Color iconBg;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _IconBox(icon: icon, bg: iconBg),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String icon, title, subtitle;
  final Color iconBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconBox(icon: icon, bg: iconBg),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                  SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.bg});
  final String icon;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Center(child: Text(icon, style: TextStyle(fontSize: 18))),
    );
  }
}
