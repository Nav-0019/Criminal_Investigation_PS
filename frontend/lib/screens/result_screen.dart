import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart' hide TextDirection;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/history_service.dart';
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
    required this.timestamp,
  });

  final String fileName;
  final String? filePath;
  final bool isHighRisk;
  final String riskLevel;
  final String transcript;
  final int fraudScore;
  final List<String> highlightedWords;
  final List<String> fraudTypes;
  final int timestamp;

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

  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareResult() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Generating alert card...')));
    final widgetToCapture = Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('🛡️ NammaShield', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Spacer(),
                Text('ALERT', style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 20),
            Text('⚠️ Scam Detected', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Risk: $_riskLabel $_riskEmoji', style: TextStyle(color: _riskColor, fontSize: 20, fontWeight: FontWeight.w600)),
            if (widget.fraudTypes.isNotEmpty) ...[
              SizedBox(height: 10),
              Text('Type: ${widget.fraudTypes.map(_formatFraudType).join(', ')}', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Text('Warning: This communication matches patterns found in known scams. Do not share personal details, OTPs, or send money.', 
                  style: TextStyle(color: Colors.red[200], fontSize: 15, height: 1.4)),
            ),
            SizedBox(height: 20),
            Center(child: Text('Stay Safe with NammaShield', style: TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic))),
          ],
        ),
      ),
    );

    final Uint8List imageBytes = await _screenshotController.captureFromWidget(
      widgetToCapture,
      delay: Duration(milliseconds: 50),
      pixelRatio: 3.0,
      context: context,
    );

    final directory = await getTemporaryDirectory();
    final imagePath = await File('${directory.path}/nammashield_alert.png').create();
    await imagePath.writeAsBytes(imageBytes);

    await Share.shareXFiles([XFile(imagePath.path)], text: '⚠️ NammaShield Alert: Suspicious Activity Detected!');
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Report Scam Incident', style: AppTextStyles.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Do you want to report this as a scam incident? This will be added to our global heatmap to warn others.', style: AppTextStyles.body),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Risk: $_riskLabel', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                    if (widget.fraudTypes.isNotEmpty) Text('Type: ${widget.fraudTypes.map(_formatFraudType).join(', ')}', style: AppTextStyles.caption),
                    Text('Location: Auto-attached', style: AppTextStyles.caption),
                    Text('Time: ${DateFormat('MMM d, yyyy - h:mm a').format(DateTime.now())}', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppColors.textLight)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _submitReport();
              },
              child: Text('Submit Report', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _submitReport() async {
    final String refId = 'NS-${Random().nextInt(900000) + 100000}';
    
    // Mark the history item as reported so Police Dashboard can see it
    await HistoryService.markAsReported(widget.timestamp);

    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.lowGreen),
              SizedBox(width: 8),
              Text('Report Submitted', style: AppTextStyles.title),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your report has been successfully submitted.', style: AppTextStyles.body),
              SizedBox(height: 12),
              Text('Reference ID: $refId', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _generateFIRPdf(refId);
              },
              child: Text('Download FIR PDF', style: TextStyle(color: AppColors.primary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Done', style: TextStyle(color: AppColors.textDark)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateFIRPdf(String refId) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('NammaShield Incident Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Reference ID: $refId', style: pw.TextStyle(fontSize: 16)),
              pw.Text('Date: ${DateFormat('MMM d, yyyy - h:mm a').format(DateTime.now())}', style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),
              pw.Text('Incident Details:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Risk Level: $_riskLabel'),
              pw.Text('Fraud Score: ${widget.fraudScore}'),
              if (widget.fraudTypes.isNotEmpty) pw.Text('Detected Types: ${widget.fraudTypes.map(_formatFraudType).join(', ')}'),
              pw.SizedBox(height: 10),
              pw.Text('Transcript:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(widget.transcript.isEmpty ? 'No transcript available.' : widget.transcript),
              pw.SizedBox(height: 30),
              pw.Text('This is an auto-generated preliminary report by NammaShield to assist law enforcement and fraud prevention units.', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10)),
            ],
          );
        },
      ),
    );
    await Printing.sharePdf(bytes: await doc.save(), filename: 'NammaShield_FIR_$refId.pdf');
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
                          ? _showReportDialog
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
                          ? _shareResult
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
