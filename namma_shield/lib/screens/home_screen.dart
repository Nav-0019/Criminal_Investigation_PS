import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'upload_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  final List<Map<String, dynamic>> _recent = [
    {
      'name': 'call_kyc_01.mp3',
      'date': 'Today, 9:15 AM',
      'risk': 'HIGH',
      'score': 75,
      'color': AppColors.highRed,
      'bg': AppColors.highRedBg,
      'fg': AppColors.highRedDark,
    },
    {
      'name': 'call_bank_02.mp3',
      'date': 'Yesterday, 3:42 PM',
      'risk': 'LOW',
      'score': 12,
      'color': AppColors.lowGreen,
      'bg': AppColors.lowGreenBg,
      'fg': AppColors.lowGreenDark,
    },
    {
      'name': 'unknown_caller.mp3',
      'date': 'Apr 26, 11:00 AM',
      'risk': 'MED',
      'score': 42,
      'color': AppColors.medAmber,
      'bg': AppColors.medAmberBg,
      'fg': AppColors.medAmberDark,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    switch (_tabIndex) {
      case 1:
        return const HistoryScreen(embedded: true);
      case 2:
        return const SettingsScreen(embedded: true);
      default:
        return _AnalyseTab(
          recent: _recent,
          pulse: _pulse,
          onUpload: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadScreen()),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _BottomNav(
        current: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}

// ── Analyse Tab ────────────────────────────────────────────────────────────────

class _AnalyseTab extends StatelessWidget {
  const _AnalyseTab(
      {required this.recent, required this.pulse, required this.onUpload});
  final List<Map<String, dynamic>> recent;
  final Animation<double> pulse;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),

        // ── Top bar ────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('NammaShield', style: AppTextStyles.title),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.settings_outlined,
                        size: 15, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('Settings',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Status card ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B4DB8), Color(0xFF5865D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              ScaleTransition(
                scale: pulse,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🛡️', style: TextStyle(fontSize: 22)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protection Status',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.circle, color: Color(0xFF7EE89D), size: 10),
                        SizedBox(width: 6),
                        Text(
                          'Active',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '12 calls analysed this week',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Action buttons ─────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: '📎',
                label: 'Upload Audio',
                onTap: onUpload,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: '🎙️',
                label: 'Record Live',
                onTap: onUpload,
                isPrimary: false,
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // ── Recent analyses ────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Analyses', style: AppTextStyles.subtitle),
            Text(
              'See all',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...recent.map((r) => _RecentItem(data: r)),

        const SizedBox(height: 20),
      ],
    );
  }
}

// ── Bottom Nav ─────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.current, required this.onTap});
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Icons.shield_outlined, Icons.shield_rounded, 'Analyse'),
      (Icons.history_outlined, Icons.history_rounded, 'History'),
      (Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(tabs.length, (i) {
            final active = i == current;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? tabs[i].$2 : tabs[i].$1,
                        size: 22,
                        color: active ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tabs[i].$3,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: active
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Action Card ────────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard(
      {required this.icon,
      required this.label,
      required this.onTap,
      required this.isPrimary});
  final String icon, label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isPrimary ? AppColors.primary : AppColors.divider),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recent Item ────────────────────────────────────────────────────────────────

class _RecentItem extends StatelessWidget {
  const _RecentItem({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: data['color'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'] as String,
                    style: AppTextStyles.subtitle
                        .copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Text(data['date'] as String,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textLight)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: data['bg'] as Color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              data['risk'] as String,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: data['fg'] as Color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
