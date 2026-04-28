import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoAnalyse = true;
  bool _storeHistory = true;
  bool _contribute = false;
  String _alertThreshold = 'Medium & above';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      children: [
        if (widget.embedded) ...[
          const Text('Settings', style: AppTextStyles.title),
          const SizedBox(height: 20),
        ],

        // ── Profile card ───────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
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
                child: const Center(child: Text('👤', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Protected User',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    SizedBox(height: 3),
                    Text('NammaShield v1.0 · Team Dream Smith',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 20),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ── ANALYSIS Section ───────────────────────────────────────────────
        _SectionLabel(label: 'ANALYSIS'),
        const SizedBox(height: 10),

        _SettingsCard(children: [
          _ToggleRow(
            icon: '⚡',
            iconBg: const Color(0xFFE6F1FB),
            title: 'Auto-analyse on call end',
            subtitle: 'Run analysis automatically after every call',
            value: _autoAnalyse,
            onChanged: (v) => setState(() => _autoAnalyse = v),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _NavRow(
            icon: '🔔',
            iconBg: const Color(0xFFFFF3E0),
            title: 'Alert threshold',
            subtitle: 'Notify at: $_alertThreshold',
            onTap: () => _showThresholdSheet(context),
          ),
        ]),

        const SizedBox(height: 20),

        // ── PRIVACY Section ────────────────────────────────────────────────
        _SectionLabel(label: 'PRIVACY'),
        const SizedBox(height: 10),

        _SettingsCard(children: [
          _ToggleRow(
            icon: '💾',
            iconBg: const Color(0xFFEAF3DE),
            title: 'Store analysis history',
            subtitle: 'Saved locally on device only',
            value: _storeHistory,
            onChanged: (v) => setState(() => _storeHistory = v),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _ToggleRow(
            icon: '🌐',
            iconBg: const Color(0xFFF5F0FF),
            title: 'Contribute to scam database',
            subtitle: 'Share anonymous trend data',
            value: _contribute,
            onChanged: (v) => setState(() => _contribute = v),
          ),
        ]),

        const SizedBox(height: 20),

        // ── ABOUT Section ──────────────────────────────────────────────────
        _SectionLabel(label: 'ABOUT'),
        const SizedBox(height: 10),

        _SettingsCard(children: [
          _NavRow(
            icon: '📋',
            iconBg: const Color(0xFFF5F5F0),
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.divider),
          _NavRow(
            icon: '⭐',
            iconBg: const Color(0xFFFFF9E6),
            title: 'Rate NammaShield',
            subtitle: 'Help us improve',
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.divider),
          _NavRow(
            icon: '🐛',
            iconBg: const Color(0xFFFCEBEB),
            title: 'Report a bug',
            subtitle: 'Send feedback to Team Dream Smith',
            onTap: () {},
          ),
        ]),

        const SizedBox(height: 32),

        // ── Footer ─────────────────────────────────────────────────────────
        Center(
          child: Column(
            children: [
              const Text('🛡️', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              const Text('NammaShield',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text('v1.0.0 · Team Dream Smith',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 2),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alert Threshold', style: AppTextStyles.title),
            const SizedBox(height: 6),
            Text('Receive notifications when risk is at or above:',
                style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
            const SizedBox(height: 20),
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
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
      style: const TextStyle(
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
        color: Colors.white,
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
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
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
    );
  }
}
