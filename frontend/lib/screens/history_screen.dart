import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, this.embedded = false});
  final bool embedded;

  List<Map<String, dynamic>> get _stats => [
    {'label': 'High Risk', 'count': '3', 'color': AppColors.highRed},
    {'label': 'Medium',    'count': '1', 'color': AppColors.medAmber},
    {'label': 'Low Risk',  'count': '8', 'color': AppColors.lowGreen},
  ];

  List<Map<String, dynamic>> get _items => [
    {
      'name': 'kyc_scam_call.wav',
      'date': 'Today · Score 75',
      'risk': 'HIGH',
      'score': 75,
      'color': AppColors.highRed,
      'bg':    AppColors.highRedBg,
      'fg':    AppColors.highRedDark,
      'high':  true,
    },
    {
      'name': 'unknown_caller.mp3',
      'date': 'Yesterday · Score 42',
      'risk': 'MED',
      'score': 42,
      'color': AppColors.medAmber,
      'bg':    AppColors.medAmberBg,
      'fg':    AppColors.medAmberDark,
      'high':  false,
    },
    {
      'name': 'bank_appointment.wav',
      'date': 'Apr 25 · Score 12',
      'risk': 'LOW',
      'score': 12,
      'color': AppColors.lowGreen,
      'bg':    AppColors.lowGreenBg,
      'fg':    AppColors.lowGreenDark,
      'high':  false,
    },
    {
      'name': 'trai_impersonator.wav',
      'date': 'Apr 24 · Score 85',
      'risk': 'HIGH',
      'score': 85,
      'color': AppColors.highRed,
      'bg':    AppColors.highRedBg,
      'fg':    AppColors.highRedDark,
      'high':  true,
    },
    {
      'name': 'call_insurance.mp3',
      'date': 'Apr 23 · Score 18',
      'risk': 'LOW',
      'score': 18,
      'color': AppColors.lowGreen,
      'bg':    AppColors.lowGreenBg,
      'fg':    AppColors.lowGreenDark,
      'high':  false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (!embedded)
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            floating: true,
            title: Text('Analysis History', style: AppTextStyles.title),
            centerTitle: false,
          ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (embedded) ...[
                  Text('Analysis History', style: AppTextStyles.title),
                  SizedBox(height: 16),
                ],

                // ── Stat cards ───────────────────────────────────────────
                Row(
                  children: _stats.map((s) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: s == _stats.last ? 0 : 10,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                        child: Column(
                          children: [
                            Text(
                              s['count'] as String,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: s['color'] as Color,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              s['label'] as String,
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textLight),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 24),

                // ── Section header ───────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('All Analyses', style: AppTextStyles.subtitle),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_list_rounded, size: 14, color: AppColors.textLight),
                          SizedBox(width: 4),
                          Text('Filter', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // ── History List ───────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final item = _items[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultScreen(
                        fileName: item['name'] as String,
                        isHighRisk: item['high'] as bool,
                      ),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
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
                        // Coloured dot
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: item['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'] as String,
                                  style: AppTextStyles.subtitle.copyWith(fontSize: 13)),
                              SizedBox(height: 2),
                              Text(item['date'] as String,
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
                            ],
                          ),
                        ),

                        // Risk badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: item['bg'] as Color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['risk'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: item['fg'] as Color,
                            ),
                          ),
                        ),

                        SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded,
                            color: AppColors.textMuted, size: 18),
                      ],
                    ),
                  ),
                );
              },
              childCount: _items.length,
            ),
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
      ],
    );
  }
}
