import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'permissions_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _fadeIn;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Detect scam calls instantly',
      'sub': 'AI-powered analysis identifies suspicious patterns in real time.',
    },
    {
      'title': 'Upload or record live calls',
      'sub': 'Analyse saved audio files or record during a suspicious call.',
    },
    {
      'title': 'Stay protected, always',
      'sub': 'Get instant risk scores and alerts before you share anything.',
    },
  ];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut);
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), _fadeCtrl.forward);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Shield Logo ──────────────────────────────────────────────
              ScaleTransition(
                scale: _logoScale,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(52, 52),
                      painter: _ShieldPainter(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  children: [
                    const Text(
                      'NammaShield',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'AI that listens before scammers win',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Onboarding Pages ─────────────────────────────────────────
              FadeTransition(
                opacity: _fadeIn,
                child: SizedBox(
                  height: 160,
                  child: PageView.builder(
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => _OnboardPage(
                      title: _pages[i]['title']!,
                      subtitle: _pages[i]['sub']!,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Dot indicators ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          active ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const Spacer(flex: 2),

              // ── CTA Buttons ──────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  children: [
                    _PrimaryButton(
                      label: 'Get Started',
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PermissionsScreen()),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Already have an account? Sign in',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.title, required this.subtitle});
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textLight,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Shield Painter ────────────────────────────────────────────────────────────

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(0, h * 0.25)
      ..lineTo(0, h * 0.5)
      ..quadraticBezierTo(0, h * 0.9, w / 2, h)
      ..quadraticBezierTo(w, h * 0.9, w, h * 0.5)
      ..lineTo(w, h * 0.25)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    // Checkmark
    final check = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final ckPath = Path()
      ..moveTo(w * 0.28, h * 0.52)
      ..lineTo(w * 0.44, h * 0.68)
      ..lineTo(w * 0.72, h * 0.38);

    canvas.drawPath(ckPath, check);
  }

  @override
  bool shouldRepaint(_) => false;
}
