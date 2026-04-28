import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _chartAnim;

  // ── Mock data ──────────────────────────────────────────────────────────────
  int totalScans = 12;
  int highRisk = 7;
  int mediumRisk = 3;
  int lowRisk = 2;

  final Map<String, int> keywords = {
    'OTP': 5,
    'KYC': 3,
    'Blocked': 2,
    'Bank': 4,
    'UPI': 2,
  };

  final Map<String, int> locations = {
    'Bangalore': 6,
    'Delhi': 3,
    'Mumbai': 2,
    'Chennai': 1,
  };

  final List<Map<String, dynamic>> reports = [
    {'time': 'Today, 2:30 PM', 'risk': 'HIGH', 'keyword': 'OTP', 'file': 'kyc_scam_call.wav'},
    {'time': 'Today, 1:10 PM', 'risk': 'MEDIUM', 'keyword': 'Bank', 'file': 'unknown_caller.mp3'},
    {'time': 'Yesterday, 11:45 AM', 'risk': 'LOW', 'keyword': 'General', 'file': 'bank_call.mp3'},
    {'time': 'Apr 26, 4:20 PM', 'risk': 'HIGH', 'keyword': 'UPI', 'file': 'upi_fraud.wav'},
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _chartAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _refreshData() {
    _animCtrl.reset();
    setState(() {
      totalScans += 1;
      highRisk += 1;
    });
    _animCtrl.forward();
  }

  Color _riskColor(String risk) {
    switch (risk) {
      case 'HIGH':
        return AppColors.highRed;
      case 'MEDIUM':
        return AppColors.medAmber;
      default:
        return AppColors.lowGreen;
    }
  }

  Color _riskBg(String risk) {
    switch (risk) {
      case 'HIGH':
        return AppColors.highRedBg;
      case 'MEDIUM':
        return AppColors.medAmberBg;
      default:
        return AppColors.lowGreenBg;
    }
  }

  Color _riskFg(String risk) {
    switch (risk) {
      case 'HIGH':
        return AppColors.highRedDark;
      case 'MEDIUM':
        return AppColors.medAmberDark;
      default:
        return AppColors.lowGreenDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (!widget.embedded)
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            floating: true,
            title: Text('Dashboard', style: AppTextStyles.title),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh_rounded,
                    color: AppColors.primary, size: 22),
                onPressed: _refreshData,
              ),
            ],
          ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.embedded) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Dashboard', style: AppTextStyles.title),
                      GestureDetector(
                        onTap: _refreshData,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.refresh_rounded,
                                  size: 14, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text('Refresh',
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
                  SizedBox(height: 16),
                ],

                // ── Overview stat cards ──────────────────────────────────
                Row(
                  children: [
                    _buildStatCard('Total', totalScans, AppColors.primary,
                        Icons.analytics_rounded),
                    _buildStatCard(
                        'High', highRisk, AppColors.highRed, Icons.warning_rounded),
                    _buildStatCard('Medium', mediumRisk, AppColors.medAmber,
                        Icons.info_rounded),
                    _buildStatCard(
                        'Low', lowRisk, AppColors.lowGreen, Icons.check_circle_rounded),
                  ],
                ),

                SizedBox(height: 24),

                // ── Risk Distribution — Pie + Bar ────────────────────────
                Text('Risk Distribution', style: AppTextStyles.subtitle),
                SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: Column(
                    children: [
                      // Pie chart
                      AnimatedBuilder(
                        animation: _chartAnim,
                        builder: (context, _) {
                          return SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 40,
                                startDegreeOffset: -90,
                                sections: [
                                  PieChartSectionData(
                                    value: highRisk.toDouble() * _chartAnim.value,
                                    color: AppColors.highRed,
                                    title: '$highRisk',
                                    titleStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    radius: 45,
                                  ),
                                  PieChartSectionData(
                                    value: mediumRisk.toDouble() * _chartAnim.value,
                                    color: AppColors.medAmber,
                                    title: '$mediumRisk',
                                    titleStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    radius: 42,
                                  ),
                                  PieChartSectionData(
                                    value: lowRisk.toDouble() * _chartAnim.value,
                                    color: AppColors.lowGreen,
                                    title: '$lowRisk',
                                    titleStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    radius: 40,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 12),

                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legend(AppColors.highRed, 'High'),
                          SizedBox(width: 20),
                          _legend(AppColors.medAmber, 'Medium'),
                          SizedBox(width: 20),
                          _legend(AppColors.lowGreen, 'Low'),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Bar chart
                      AnimatedBuilder(
                        animation: _chartAnim,
                        builder: (context, _) {
                          return SizedBox(
                            height: 160,
                            child: BarChart(
                              BarChartData(
                                maxY: (highRisk + 2).toDouble(),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 2,
                                  getDrawingHorizontalLine: (v) => FlLine(
                                    color: AppColors.divider,
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      interval: 2,
                                      getTitlesWidget: (val, _) => Text(
                                        val.toInt().toString(),
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textMuted),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (val, _) {
                                        const labels = ['High', 'Medium', 'Low'];
                                        final idx = val.toInt();
                                        if (idx < 0 || idx >= labels.length) {
                                          return SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(labels[idx],
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textLight,
                                                  fontWeight: FontWeight.w500)),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                barGroups: [
                                  BarChartGroupData(x: 0, barRods: [
                                    BarChartRodData(
                                      toY: highRisk.toDouble() * _chartAnim.value,
                                      color: AppColors.highRed,
                                      width: 28,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(6)),
                                    )
                                  ]),
                                  BarChartGroupData(x: 1, barRods: [
                                    BarChartRodData(
                                      toY: mediumRisk.toDouble() * _chartAnim.value,
                                      color: AppColors.medAmber,
                                      width: 28,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(6)),
                                    )
                                  ]),
                                  BarChartGroupData(x: 2, barRods: [
                                    BarChartRodData(
                                      toY: lowRisk.toDouble() * _chartAnim.value,
                                      color: AppColors.lowGreen,
                                      width: 28,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(6)),
                                    )
                                  ]),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // ── Top Keywords ─────────────────────────────────────────
                Text('Top Scam Keywords', style: AppTextStyles.subtitle),
                SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: keywords.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${entry.value}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 24),

                // ── Location Breakdown ───────────────────────────────────
                Text('Reports by Location', style: AppTextStyles.subtitle),
                SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: Column(
                    children: locations.entries.toList().asMap().entries.map(
                      (mapEntry) {
                        final idx = mapEntry.key;
                        final entry = mapEntry.value;
                        final pct =
                            (entry.value / totalScans * 100).toStringAsFixed(0);
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.location_on_rounded,
                                        size: 18, color: AppColors.primary),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(entry.key,
                                            style: AppTextStyles.subtitle
                                                .copyWith(fontSize: 13)),
                                        SizedBox(height: 4),
                                        // Progress bar
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: entry.value / totalScans,
                                            backgroundColor: AppColors.divider,
                                            color: AppColors.primary,
                                            minHeight: 4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    '${entry.value} ($pct%)',
                                    style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMid),
                                  ),
                                ],
                              ),
                            ),
                            if (idx < locations.length - 1)
                              Divider(
                                  height: 1, color: AppColors.divider),
                          ],
                        );
                      },
                    ).toList(),
                  ),
                ),

                SizedBox(height: 24),
                
                buildHeatmap(),

                SizedBox(height: 24),

                // ── Recent Reports ───────────────────────────────────────
                Text('Recent Reports', style: AppTextStyles.subtitle),
                SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // ── Report list ──────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final report = reports[i];
                final risk = report['risk'] as String;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      // Risk dot
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _riskColor(risk),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report['file'] as String,
                                style:
                                    AppTextStyles.subtitle.copyWith(fontSize: 13)),
                            SizedBox(height: 2),
                            Text(
                              '${report['time']} · ${report['keyword']}',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ),

                      // Risk badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _riskBg(risk),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          risk,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _riskFg(risk),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: reports.length,
            ),
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _buildStatCard(String title, int value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
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
            Icon(icon, size: 20, color: color),
            SizedBox(height: 6),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: 2),
            Text(
              title,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textLight, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeatmap() {
  final Map<String, int> heatmapData = {
    "Bangalore": 6,
    "Delhi": 4,
    "Mumbai": 2,
    "Chennai": 3,
  };

  Color getColor(int value) {
    if (value >= 5) return Colors.red;
    if (value >= 3) return Colors.orange;
    return Colors.green;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Scam Heatmap",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),

      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: heatmapData.entries.map((entry) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: getColor(entry.value).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: getColor(entry.value)),
            ),
            child: Column(
              children: [
                Text(entry.key,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("${entry.value} reports"),
              ],
            ),
          );
        }).toList(),
      ),
    ],
  );
}

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: AppColors.textMid,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}