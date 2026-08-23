import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';

class RipplesOfPeaceWidget extends StatefulWidget {
  const RipplesOfPeaceWidget({super.key});

  @override
  State<RipplesOfPeaceWidget> createState() => _RipplesOfPeaceWidgetState();
}

class RippleCircle {
  final Offset center;
  double radius;
  double opacity;
  final Color color;

  RippleCircle({
    required this.center,
    this.radius = 4.0,
    this.opacity = 0.9,
    required this.color,
  });
}

class FloatingLotus {
  Offset position;
  final String emoji;
  double angle;

  FloatingLotus({
    required this.position,
    required this.emoji,
    this.angle = 0.0,
  });
}

class _RipplesOfPeaceWidgetState extends State<RipplesOfPeaceWidget>
    with SingleTickerProviderStateMixin {
  final List<RippleCircle> _ripples = [];
  late List<FloatingLotus> _lotuses;
  late AnimationController _animController;
  Timer? _autoRippleTimer;

  final List<Color> _rippleColors = const [
    Color(0xFF80DEEA),
    Color(0xFF80CBC4),
    Color(0xFFA5D6A7),
    Color(0xFFC5CAE9),
    Color(0xFFB2EBF2),
  ];

  @override
  void initState() {
    super.initState();

    _lotuses = [
      FloatingLotus(position: const Offset(100, 150), emoji: '🪷'),
      FloatingLotus(position: const Offset(260, 220), emoji: '🪷'),
      FloatingLotus(position: const Offset(140, 320), emoji: '🪷'),
      FloatingLotus(position: const Offset(220, 100), emoji: '🍃'),
    ];

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateRipples);

    _animController.repeat();
    _startAutoRipples();
  }

  void _startAutoRipples() {
    _autoRippleTimer?.cancel();
    _autoRippleTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (!mounted) return;
      final randomX = 60 + math.Random().nextDouble() * 240;
      final randomY = 60 + math.Random().nextDouble() * 320;
      _createRipple(Offset(randomX, randomY));
    });
  }

  void _createRipple(Offset point) {
    if (_ripples.length > 25) {
      _ripples.removeAt(0);
    }
    final color = _rippleColors[math.Random().nextInt(_rippleColors.length)];
    setState(() {
      _ripples.add(RippleCircle(center: point, color: color));
    });
  }

  void _updateRipples() {
    if (!mounted || _ripples.isEmpty) return;

    setState(() {
      for (int i = _ripples.length - 1; i >= 0; i--) {
        final r = _ripples[i];
        r.radius += 2.2;
        r.opacity -= 0.018;

        // Drift lotuses if ripple touches them
        for (var lotus in _lotuses) {
          final distance = (lotus.position - r.center).distance;
          if ((distance - r.radius).abs() < 20) {
            lotus.position += Offset(
              math.sin(r.radius * 0.1) * 0.5,
              math.cos(r.radius * 0.1) * 0.5,
            );
          }
        }

        if (r.opacity <= 0) {
          _ripples.removeAt(i);
        }
      }
    });
  }

  @override
  void dispose() {
    _autoRippleTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Header Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.water_drop_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ripples of Peace (Sound Bath)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Water Ripple Canvas
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(15, 32, 39, 0.2),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Custom Ripple Painter
                CustomPaint(
                  size: Size.infinite,
                  painter: WaterRipplePainter(ripples: _ripples),
                ),

                // Touch Listener for Manual Ripples
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    _createRipple(details.localPosition);
                  },
                  onPanUpdate: (details) {
                    _createRipple(details.localPosition);
                  },
                ),

                // Floating Lotuses
                ..._lotuses.map((lotus) {
                  return Positioned(
                    left: lotus.position.dx - 20,
                    top: lotus.position.dy - 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: Text(
                        lotus.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  );
                }),

                // Overlay Callout
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      '💧 Ketuk atau geser di air untuk menciptakan riak kedamaian harmoni',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WaterRipplePainter extends CustomPainter {
  final List<RippleCircle> ripples;

  WaterRipplePainter({required this.ripples});

  @override
  void paint(Canvas canvas, Size size) {
    for (var r in ripples) {
      final paint = Paint()
        ..color = r.color.withValues(alpha: r.opacity.clamp(0.0, 1.0))
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(r.center, r.radius, paint);

      // Soft glow aura circle
      final glowPaint = Paint()
        ..color = r.color.withValues(alpha: (r.opacity * 0.3).clamp(0.0, 1.0))
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(r.center, r.radius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WaterRipplePainter oldDelegate) => true;
}
