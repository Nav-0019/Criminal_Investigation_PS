import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'upload_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.fileName,
    required this.isHighRisk,
    this.filePath,
    this.riskLevel = 'LOW',
    this.transcript = '',
    this.fraudScore = 0,
    this.highlightedWords = const [],
    this.fraudTypes = const [],
  });

  final String fileName;
  final String? filePath;
  final bool isHighRisk;
  final String riskLevel;
  final String transcript;
  final int fraudScore;
  final List<String> highlightedWords;
  final List<String> fraudTypes;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Risk color helpers ──────────────────────────────────────────────────
  bool get _isMedium => widget.riskLevel == 'MEDIUM';
  bool get _isHigh => widget.isHighRisk;
  bool get _isDangerous => _isHigh || _isMedium;

  Color get _riskColor => _isHigh ? AppColors.highRed : _isMedium ? AppColors.medAmber : AppColors.lowGreen;
  Color get _riskDark => _isHigh ? AppColors.highRedDark : _isMedium ? AppColors.medAmberDark : AppColors.lowGreenDark;
  Color get _riskDeep => _isHigh ? AppColors.highRedDeep : _isMedium ? AppColors.medAmberDark : AppColors.lowGreenDeep;
  Color get _riskBg => _isHigh ? AppColors.highRedBg : _isMedium ? AppColors.medAmberBg : AppColors.lowGreenBg;
  Color get _riskBorder => _isHigh ? AppColors.highRedBorder : _isMedium ? Color(0xFFE8D5A8) : AppColors.lowGreenBorder;
  Color get _riskAccent => _isHigh ? AppColors.highRedAccent : _isMedium ? Color(0xFFFFF8EE) : AppColors.lowGreenAccent;

  String get _riskLabel {
    switch (widget.riskLevel) {
      case 'HIGH': return 'HIGH RISK';
      case 'MEDIUM': return 'MEDIUM RISK';
      default: return 'LOW RISK';
    }
  }

  String get _riskEmoji {
    switch (widget.riskLevel) {
      case 'HIGH': return '🚨';
      case 'MEDIUM': return '⚠️';
      default: return '✅';
    }
  }

  String _formatFraudType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final suspiciousPhrases = widget.highlightedWords;

    final transcript = widget.transcript.isEmpty
        ? (_isHigh
            ? 'Suspicious activity detected in call.'
            : _isMedium
                ? 'Some suspicious patterns detected.'
                : 'No suspicious activity detected.')
        : widget.transcript;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
        ),
        title: Text('Result', style: AppTextStyles.title),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _fade,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              SizedBox(height: 12),

              // ── Risk Badge ─────────────────────────────────────────────
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: _riskBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _riskBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: _riskColor.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(_riskEmoji, style: TextStyle(fontSize: 44)),
                      SizedBox(height: 8),
                      Text(_riskLabel,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _riskDark,
                              letterSpacing: -0.3)),
                      SizedBox(height: 6),
                      Text('Score: ${widget.fraudScore} / 100',
                          style: TextStyle(fontSize: 14, color: _riskDeep)),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // ── Action Banner ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _riskAccent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border(left: BorderSide(color: _riskColor, width: 3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isHigh
                          ? '⚠ Action required'
                          : _isMedium
                              ? '⚠ Exercise caution'
                              : '✓ No immediate concern',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _riskDark),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _isHigh
                          ? 'Terminate the call immediately. Do not share any personal information.'
                          : _isMedium
                              ? 'Be careful with this call. Verify the caller\'s identity before sharing any details.'
                              : 'No suspicious patterns detected. Exercise normal caution.',
                      style: TextStyle(fontSize: 13, color: _riskDeep, height: 1.5),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // ── Fraud Types ─────────────────────────────────────────────
              if (widget.fraudTypes.isNotEmpty) ...[
                Text('Detected fraud categories',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textLight)),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.fraudTypes.map((type) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.category_rounded, size: 12, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            _formatFraudType(type),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
              ],

              // ── Suspicious Phrases ─────────────────────────────────────
              if (_isDangerous && suspiciousPhrases.isNotEmpty) ...[
                Text('Suspicious phrases detected',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textLight)),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suspiciousPhrases.map((phrase) {
                    final isRed = _isHigh;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isRed ? AppColors.highRedBg : AppColors.medAmberBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        phrase,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isRed ? AppColors.highRedDark : AppColors.medAmberDark,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
              ] else if (!_isDangerous) ...[
                Text('No suspicious phrases found',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textLight)),
                SizedBox(height: 6),
                Text('0 flagged keywords in this call',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                SizedBox(height: 20),
              ],

              // ── Transcript ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description_rounded, size: 15, color: AppColors.textLight),
                        SizedBox(width: 6),
                        Text('Transcript',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (_isDangerous && suspiciousPhrases.isNotEmpty)
                      _HighlightedTranscript(text: transcript, keywords: suspiciousPhrases)
                    else
                      Text(transcript,
                          style: TextStyle(fontSize: 13, color: AppColors.textMid, height: 1.6)),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // ── Action Buttons ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _OutlineButton(
                      label: _isDangerous ? '📤 Report' : '🏠 Home',
                      onTap: _isDangerous
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Scam report submitted to database.')),
                              );
                            }
                          : () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (ctx) => const HomeScreen()),
                                (r) => false,
                              ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _PrimaryButton(
                      label: _isDangerous ? 'Share Result' : 'Analyse Another',
                      onTap: _isDangerous
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sharing analysis results…')),
                              );
                            }
                          : () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (ctx) => const UploadScreen()),
                              ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Highlighted Transcript ─────────────────────────────────────────────────────

class _HighlightedTranscript extends StatelessWidget {
  const _HighlightedTranscript({required this.text, required this.keywords});
  final String text;
  final List<String> keywords;

  @override
  Widget build(BuildContext context) {
    // Split by whitespace but keep the whitespace
    final words = text.split(RegExp(r'(?<=\s)|(?=\s)'));

    final spans = words.map((word) {
      final clean = word.replaceAll(RegExp(r'[^a-zA-Z]'), '');
      final isKey = keywords.any((k) => k.toLowerCase() == clean.toLowerCase());
      return TextSpan(
        text: word,
        style: TextStyle(
          fontSize: 13,
          height: 1.6,
          color: isKey ? AppColors.highRedDeep : AppColors.textMid,
          backgroundColor: isKey ? AppColors.highRed.withValues(alpha: 0.15) : null,
          fontWeight: isKey ? FontWeight.w600 : FontWeight.normal,
        ),
      );
    }).toList();

    return RichText(text: TextSpan(children: spans));
  }
}

// ── Buttons ────────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
