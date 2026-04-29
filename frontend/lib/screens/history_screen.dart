import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _historyItems = [];
  bool _isLoading = true;

  int _highCount = 0;
  int _medCount = 0;
  int _lowCount = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await HistoryService.getHistory();
    int high = 0;
    int med = 0;
    int low = 0;

    for (var item in items) {
      if (item.risk == 'HIGH') high++;
      else if (item.risk == 'MEDIUM') med++;
      else low++;
    }

    if (mounted) {
      setState(() {
        _historyItems = items;
        _highCount = high;
        _medCount = med;
        _lowCount = low;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _stats => [
    {'label': 'High Risk', 'count': '$_highCount', 'color': AppColors.highRed},
    {'label': 'Medium',    'count': '$_medCount', 'color': AppColors.medAmber},
    {'label': 'Low Risk',  'count': '$_lowCount', 'color': AppColors.lowGreen},
  ];

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
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return CustomScrollView(
      slivers: [
        if (!widget.embedded)
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
                if (widget.embedded) ...[
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
        if (_historyItems.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No analysis history yet.',
                  style: AppTextStyles.body,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final item = _historyItems[i];
                  final result = item.fullData;
                  final fraudScore = (result['fraud_score'] as num?)?.toInt() ?? 0;

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultScreen(
                          fileName: item.fileName,
                          isHighRisk: item.risk == 'HIGH',
                          riskLevel: item.risk,
                          transcript: result['transcript'] ?? '',
                          fraudScore: fraudScore,
                          highlightedWords: List<String>.from(result['highlighted_words'] ?? []),
                          fraudTypes: List<String>.from(result['fraud_types'] ?? []),
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
                              color: _riskColor(item.risk),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.subtitle.copyWith(fontSize: 13)),
                                SizedBox(height: 2),
                                Text('${_formatDate(item.timestamp)} · Score $fraudScore',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
                              ],
                            ),
                          ),

                          // Risk badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _riskBg(item.risk),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.risk,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _riskFg(item.risk),
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
                childCount: _historyItems.length,
              ),
            ),
          ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
      ],
    );
  }
}
