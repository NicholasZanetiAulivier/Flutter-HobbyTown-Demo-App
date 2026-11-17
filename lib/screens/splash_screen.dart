import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hobby_town_demo/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _pink = Color(0xFFFF4F8B);
  static const _bgDark = Color(0xFF0E0E12);
  static const _bgPurple = Color(0xFF301F47);

  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0E0E12),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _progress.forward().whenComplete(_goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _orbit.dispose();
    _progress.dispose();
    super.dispose();
  }

  Widget _logo(double size, double radius, double padding) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _pink,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Image.asset('resources/images/logo.png', fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_bgDark, Color(0xFF1A1424), _bgPurple],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Orbit rings + big logo
              Align(
                alignment: const Alignment(0, -0.2),
                child: SizedBox(
                  width: 230,
                  height: 230,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _orbit,
                        builder: (_, __) => CustomPaint(
                          size: const Size(230, 230),
                          painter: _OrbitPainter(
                            progress: _orbit.value,
                            dotColor: _pink,
                          ),
                        ),
                      ),
                      _logo(88, 28, 10),
                    ],
                  ),
                ),
              ),

              // Brand row + tagline
              Align(
                alignment: const Alignment(0, 0.38),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _logo(40, 12, 4),
                        const SizedBox(width: 12),
                        const Text(
                          'myhobbytown.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Hobimu, duniamu.',
                      style: TextStyle(
                        color: Color(0xFFE6E1EE),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Footer text + progress bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 48,
                child: Column(
                  children: [
                    const Text(
                      'Teman hobi kamu · Sejak 2003',
                      style: TextStyle(color: Color(0xFFB9B2C6), fontSize: 11),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: SizedBox(
                        width: 68,
                        height: 3,
                        child: AnimatedBuilder(
                          animation: _progress,
                          builder: (_, __) => LinearProgressIndicator(
                            value: _progress.value,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              _pink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws the two faint concentric rings and the small pink dot
/// travelling along the outer ring.
class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.progress, required this.dotColor});

  final double progress;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerR = size.width / 2 - 4;
    final innerR = outerR * 0.67;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.10);

    canvas.drawCircle(center, outerR, ringPaint);
    canvas.drawCircle(center, innerR, ringPaint);

    // Short arc that orbits (starts upper-right like the design).
    final startAngle = -math.pi / 4 + progress * 2 * math.pi;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..color = dotColor;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerR),
      startAngle,
      0.06,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter old) =>
      old.progress != progress || old.dotColor != dotColor;
}
