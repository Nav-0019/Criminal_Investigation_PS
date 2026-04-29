import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';
import '../services/api_service.dart';

class AnalysingScreen extends StatefulWidget {
  const AnalysingScreen({super.key, required this.fileName, this.filePath});
  final String fileName;
  final String? filePath;

  @override
  State<AnalysingScreen> createState() => _AnalysingScreenState();
}

class _AnalysingScreenState extends State<AnalysingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinCtrl;

  int _completedSteps = 0;
  String? _errorMessage;

  final List<_Step> _steps = [
    _Step(label: 'Audio received', icon: Icons.audio_file_rounded),
    _Step(label: 'Speech-to-text conversion', icon: Icons.record_voice_over_rounded),
    _Step(label: 'Scam pattern analysis', icon: Icons.search_rounded),
    _Step(label: 'Risk score calculation', icon: Icons.analytics_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _startAnalysis();
  }

  bool _isApiDone = false;

  void _startAnalysis() async {
    _simulateSteps();

    if (widget.filePath == null || widget.filePath!.isEmpty) {
      _showError('No file path provided.');
      return;
    }

    try {
      final result = await ApiService.analyzeAudio(widget.filePath!);

      if (!mounted) return;
      
      _isApiDone = true;

      // Ensure all steps instantly mark as completed
      setState(() => _completedSteps = _steps.length);
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      final String riskLevel = result['risk'] ?? 'LOW';
      final bool isHighRisk = riskLevel == 'HIGH';

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim, secondaryAnim) => ResultScreen(
            fileName: widget.fileName,
            filePath: widget.filePath,
            isHighRisk: isHighRisk,
            riskLevel: riskLevel,
            transcript: result['transcript'] ?? '',
            fraudScore: (result['fraud_score'] as num?)?.toInt() ?? 0,
            highlightedWords: List<String>.from(result['highlighted_words'] ?? []),
            fraudTypes: List<String>.from(result['fraud_types'] ?? []),
          ),
          transitionsBuilder: (context, anim, secondaryAnim, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _isApiDone = true;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _isApiDone = true;
      _showError('Connection Error: Make sure the backend is running.\n\n$e');
    }
  }

  void _simulateSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      if (_isApiDone) return;
      if (_completedSteps >= i + 1) continue;
      
      await Future.delayed(Duration(milliseconds: 800 + i * 400));
      
      if (!mounted || _isApiDone) return;
      
      if (_completedSteps < i + 1) {
        setState(() => _completedSteps = i + 1);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _errorMessage = message);
    _spinCtrl.stop();
  }

  void _retry() {
    setState(() {
      _errorMessage = null;
      _completedSteps = 0;
      _isApiDone = false;
    });
    _spinCtrl.repeat();
    _startAnalysis();
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
        ),
        title: Text(
          _errorMessage != null ? 'Error' : 'Analysing…',
          style: AppTextStyles.title,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _errorMessage != null ? _buildErrorView() : _buildProgressView(),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Column(
      children: [
        const Spacer(),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.highRedBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.error_outline_rounded, color: AppColors.highRed, size: 40),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Analysis Failed',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.highRedAccent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.highRedBorder),
          ),
          child: Text(
            _errorMessage!,
            style: TextStyle(fontSize: 13, color: AppColors.highRedDeep, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    'Go Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _retry,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Retry',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildProgressView() {
    return Column(
      children: [
        const Spacer(),
        // Spinner ring
        SizedBox(
          width: 80,
          height: 80,
          child: RotationTransition(
            turns: _spinCtrl,
            child: CustomPaint(painter: _RingPainter()),
          ),
        ),
        SizedBox(height: 20),
        Text('Processing your call',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        SizedBox(height: 6),
        Text(widget.fileName,
            style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
        SizedBox(height: 40),
        ...List.generate(_steps.length, (i) => _StepRow(
          step: _steps[i],
          isDone: i < _completedSteps,
          isActive: i == _completedSteps,
        )),
        SizedBox(height: 32),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          tween: Tween<double>(
            begin: 0,
            end: _completedSteps / _steps.length,
          ),
          builder: (context, value, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Processing', style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
                  Text('${(value * 100).round()}%',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _Step {
  final String label;
  final IconData icon;
  const _Step({required this.label, required this.icon});
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isDone, required this.isActive});
  final _Step step;
  final bool isDone, isActive;

  @override
  Widget build(BuildContext context) {
    final Color dotColor = isDone ? AppColors.lowGreen : isActive ? AppColors.primary : AppColors.border;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            child: Center(
              child: isDone
                  ? Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : isActive
                      ? SizedBox(width: 12, height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.8,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : SizedBox.shrink(),
            ),
          ),
          SizedBox(width: 14),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isDone ? AppColors.textDark : isActive ? AppColors.primary : AppColors.textMuted,
            ),
            child: Text(step.label),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    paint.color = AppColors.divider;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);

    paint.shader = SweepGradient(
      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0)],
      stops: [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2));

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      -1.5708, 4.71239, false, paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
