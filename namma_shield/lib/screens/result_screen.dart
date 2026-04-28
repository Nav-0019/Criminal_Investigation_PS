import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'upload_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.fileName, required this.isHighRisk, this.filePath});
  final String fileName;
  final String? filePath;
  final bool isHighRisk;

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

  @override
  Widget build(BuildContext context) {
    final high = widget.isHighRisk;

    final riskColor   = high ? AppColors.highRed    : AppColors.lowGreen;
    final riskDark    = high ? AppColors.highRedDark : AppColors.lowGreenDark;
    final riskDeep    = high ? AppColors.highRedDeep : AppColors.lowGreenDeep;
    final riskBg      = high ? AppColors.highRedBg   : AppColors.lowGreenBg;
    final riskBorder  = high ? AppColors.highRedBorder : AppColors.lowGreenBorder;
    final riskAccent  = high ? AppColors.highRedAccent  : AppColors.lowGreenAccent;
    final riskLabel   = high ? 'HIGH RISK'  : 'LOW RISK';
    final riskEmoji   = high ? '🚨' : '✅';
    final riskScore   = high ? 75  : 12;

    final suspiciousPhrases = high
        ? ['OTP', 'KYC', 'verify', 'urgent', 'account', 'bank']
        : <String>[];

    final transcript = high
        ? '"Please share your OTP to complete KYC verification. Your account will be blocked if you don\'t act urgently..."'
        : '"Hello, this is your bank calling to confirm your appointment. Is now a good time to speak about your home loan inquiry?"';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
        ),
        title: const Text('Result', style: AppTextStyles.title),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _fade,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 12),

              // ── Risk Badge ─────────────────────────────────────────────
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: riskBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: riskBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: riskColor.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(riskEmoji, style: const TextStyle(fontSize: 44)),
                      const SizedBox(height: 8),
                      Text(riskLabel,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: riskDark,
                              letterSpacing: -0.3)),
                      const SizedBox(height: 6),
                      Text('Score: $riskScore / 100',
                          style: TextStyle(fontSize: 14, color: riskDeep)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Action Banner ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: riskAccent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border(left: BorderSide(color: riskColor, width: 3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      high ? '⚠ Action required' : '✓ No immediate concern',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: riskDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      high
                          ? 'Terminate the call immediately. Do not share any personal information.'
                          : 'No suspicious patterns detected. Exercise normal caution.',
                      style: TextStyle(fontSize: 13, color: riskDeep, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Suspicious Phrases ─────────────────────────────────────
              if (high) ...[
                const Text('Suspicious phrases detected',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textLight)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suspiciousPhrases.map((phrase) {
                    final isRed = ['OTP', 'KYC', 'verify'].contains(phrase);
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
                const SizedBox(height: 20),
              ] else ...[
                const Text('No suspicious phrases found',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textLight)),
                const SizedBox(height: 6),
                const Text('0 flagged keywords in this call',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
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
                    const Row(
                      children: [
                        Icon(Icons.description_rounded, size: 15, color: AppColors.textLight),
                        SizedBox(width: 6),
                        Text('Transcript',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (high)
                      _HighlightedTranscript(text: transcript)
                    else
                      Text(transcript,
                          style: const TextStyle(fontSize: 13, color: AppColors.textMid, height: 1.6)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Action Buttons ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _OutlineButton(
                      label: high ? '📤 Report' : '🏠 Home',
                      onTap: high
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Scam report submitted to database.')),
                              );
                            }
                          : () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                                (r) => false,
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PrimaryButton(
                      label: high ? 'Share Result' : 'Analyse Another',
                      onTap: high
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sharing analysis results…')),
                              );
                            }
                          : () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const UploadScreen()),
                              ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Highlighted Transcript ─────────────────────────────────────────────────────

class _HighlightedTranscript extends StatelessWidget {
  const _HighlightedTranscript({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final keywords = ['OTP', 'KYC', 'verification', 'account', 'urgent', 'blocked'];
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
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
