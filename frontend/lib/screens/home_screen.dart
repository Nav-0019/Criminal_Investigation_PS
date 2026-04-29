import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'upload_screen.dart';
import 'history_screen.dart';
import 'dashboard_screen.dart';
import 'result_screen.dart';
import 'settings_screen.dart';
import '../services/history_service.dart';
import 'package:intl/intl.dart';

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

  List<HistoryItem> _recent = [];
  int _totalScans = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _totalScans = items.length;
        _recent = items.take(3).toList();
      });
    }
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
        return const DashboardScreen(embedded: true);
      case 3:
        return const SettingsScreen(embedded: true);
      default:
        return _AnalyseTab(
          recent: _recent,
          totalScans: _totalScans,
          pulse: _pulse,
          onUpload: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadScreen()),
            ).then((_) => _loadHistory());
          },
          onSettings: () => setState(() => _tabIndex = 3),
          onHistory: () => setState(() => _tabIndex = 1),
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
      {required this.recent, required this.totalScans, required this.pulse, required this.onUpload, required this.onSettings, required this.onHistory});
  final List<HistoryItem> recent;
  final int totalScans;
  final Animation<double> pulse;
  final VoidCallback onUpload;
  final VoidCallback onSettings;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        SizedBox(height: 8),

        // ── Top bar ────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('NammaShield', style: AppTextStyles.title),
            GestureDetector(
              onTap: onSettings,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
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

        SizedBox(height: 20),

        // ── Status card ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B4DB8), Color(0xFF5865D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
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
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset('assets/logo.png', height: 26),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protection Status',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Row(
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
                    SizedBox(height: 4),
                    Text(
                      '$totalScans calls analysed',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

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
            SizedBox(width: 12),
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

        SizedBox(height: 28),

        // ── Recent analyses ────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Analyses', style: AppTextStyles.subtitle),
            GestureDetector(
              onTap: onHistory,
              child: Text(
                'See all',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),

        SizedBox(height: 12),

        ...recent.map((r) => _RecentItem(data: r)),

        SizedBox(height: 20),
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
      (Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
      (Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                      SizedBox(height: 3),
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
          color: isPrimary ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isPrimary ? AppColors.primary : AppColors.divider),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 24)),
            SizedBox(height: 6),
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
  final HistoryItem data;

  Color _riskColor(String risk) {
    if (risk == 'HIGH') return AppColors.highRed;
    if (risk == 'MEDIUM') return AppColors.medAmber;
    return AppColors.lowGreen;
  }

  Color _riskBg(String risk) {
    if (risk == 'HIGH') return AppColors.highRedBg;
    if (risk == 'MEDIUM') return AppColors.medAmberBg;
    return AppColors.lowGreenBg;
  }

  Color _riskFg(String risk) {
    if (risk == 'HIGH') return AppColors.highRedDark;
    if (risk == 'MEDIUM') return AppColors.medAmberDark;
    return AppColors.lowGreenDark;
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0 && now.day == date.day) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != date.day)) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    }
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final result = data.fullData;
    final fraudScore = (result['fraud_score'] as num?)?.toInt() ?? 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            fileName: data.fileName,
            isHighRisk: data.risk == 'HIGH',
            riskLevel: data.risk,
            transcript: result['transcript'] ?? '',
            fraudScore: fraudScore,
            highlightedWords: List<String>.from(result['highlighted_words'] ?? []),
            fraudTypes: List<String>.from(result['fraud_types'] ?? []),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
                color: _riskColor(data.risk),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle
                          .copyWith(fontSize: 13)),
                  SizedBox(height: 2),
                  Text('${_formatDate(data.timestamp)} · Score $fraudScore',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textLight)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _riskBg(data.risk),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                data.risk,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _riskFg(data.risk),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
