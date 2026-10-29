import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Interactive reactive lattice grid inspired by Artefakt (GetLayers AI).
/// Renders an ambient futuristic grid that illuminates dynamically under touch,
/// with radial energy falloff and subtle breathing pulses.
class LatticeGlowCanvas extends StatefulWidget {
  final Widget? child;
  final double spacing;
  final double dotSize;
  final Color baseColor;
  final Color glowColor;

  const LatticeGlowCanvas({
    super.key,
    this.child,
    this.spacing = 32.0,
    this.dotSize = 1.5,
    this.baseColor = const Color(0x18FFFFFF),
    this.glowColor = AppColors.neonCyan,
  });

  @override
  State<LatticeGlowCanvas> createState() => _LatticeGlowCanvasState();
}

class _LatticeGlowCanvasState extends State<LatticeGlowCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Offset? _pointerPos;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) => setState(() => _pointerPos = e.localPosition),
      onPointerMove: (e) => setState(() => _pointerPos = e.localPosition),
      onPointerUp: (_) => setState(() => _pointerPos = null),
      onPointerCancel: (_) => setState(() => _pointerPos = null),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return CustomPaint(
            painter: _LatticeGridPainter(
              pointerPos: _pointerPos,
              spacing: widget.spacing,
              dotSize: widget.dotSize,
              baseColor: widget.baseColor,
              glowColor: widget.glowColor,
              pulsePhase: _pulseController.value,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _LatticeGridPainter extends CustomPainter {
  final Offset? pointerPos;
  final double spacing;
  final double dotSize;
  final Color baseColor;
  final Color glowColor;
  final double pulsePhase;

  _LatticeGridPainter({
    required this.pointerPos,
    required this.spacing,
    required this.dotSize,
    required this.baseColor,
    required this.glowColor,
    required this.pulsePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()..style = PaintingStyle.fill;

    final cols = (size.width / spacing).ceil() + 1;
    final rows = (size.height / spacing).ceil() + 1;

    const maxInfluenceRadius = 140.0;

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        final x = i * spacing;
        final y = j * spacing;
        final point = Offset(x, y);

        // Distance to active pointer
        double intensity = 0.0;
        if (pointerPos != null) {
          final dist = (point - pointerPos!).distance;
          if (dist < maxInfluenceRadius) {
            intensity = 1.0 - (dist / maxInfluenceRadius);
            intensity = math.pow(intensity, 2).toDouble(); // Quadratic falloff
          }
        }

        // Ambient cyber pulse
        final ambientDist = (point - Offset(size.width * 0.5, size.height * 0.3)).distance;
        final wave = math.sin((ambientDist / 90.0) - (pulsePhase * 2 * math.pi)) * 0.5 + 0.5;
        final ambientGlow = wave * 0.18;

        final totalIntensity = (intensity + ambientGlow).clamp(0.0, 1.0);

        if (totalIntensity > 0.05) {
          glowPaint.color = Color.lerp(
            baseColor,
            glowColor,
            totalIntensity,
          )!.withValues(alpha: (0.15 + 0.85 * totalIntensity).clamp(0.0, 1.0));

          final currentRadius = dotSize + (intensity * 2.5);
          canvas.drawCircle(point, currentRadius, glowPaint);

          // Draw fine lattice connecting crosshairs when near pointer
          if (intensity > 0.45) {
            final linePaint = Paint()
              ..color = glowColor.withValues(alpha: intensity * 0.3)
              ..strokeWidth = 0.8;
            canvas.drawLine(Offset(x - 5, y), Offset(x + 5, y), linePaint);
            canvas.drawLine(Offset(x, y - 5), Offset(x, y + 5), linePaint);
          }
        } else {
          canvas.drawCircle(point, dotSize, basePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LatticeGridPainter oldDelegate) {
    return oldDelegate.pointerPos != pointerPos ||
        oldDelegate.pulsePhase != pulsePhase;
  }
}
