import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Interactive 360-degree holographic turntable product viewer
/// Inspired by Geneva horology luxury showcase (Ora by Scrolltide)
class HologramTurntable extends StatefulWidget {
  final IconData icon;
  final Color primaryColor;
  final String title;
  final String category;
  final double price;
  final double size;

  const HologramTurntable({
    super.key,
    required this.icon,
    required this.primaryColor,
    required this.title,
    required this.category,
    required this.price,
    this.size = 280,
  });

  @override
  State<HologramTurntable> createState() => _HologramTurntableState();
}

class _HologramTurntableState extends State<HologramTurntable>
    with TickerProviderStateMixin {
  late AnimationController _idleFloatController;
  late AnimationController _spinController;

  double _rotationAngle = 0.0;
  final double _tiltAngle = 0.12;
  double _lastDragX = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _idleFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    )..repeat();
  }

  @override
  void dispose() {
    _idleFloatController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _isDragging = true;
        _lastDragX = details.localPosition.dx;
      },
      onHorizontalDragUpdate: (details) {
        final delta = details.localPosition.dx - _lastDragX;
        _lastDragX = details.localPosition.dx;
        setState(() {
          _rotationAngle += delta * 0.015;
        });
      },
      onHorizontalDragEnd: (_) {
        _isDragging = false;
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleFloatController, _spinController]),
        builder: (context, child) {
          final floatOffset = math.sin(_idleFloatController.value * 2 * math.pi) * 8.0;
          final autoSpin = _isDragging ? 0.0 : (_spinController.value * 2 * math.pi * 0.15);
          final currentRotation = _rotationAngle + autoSpin;

          return SizedBox(
            height: widget.size + 60,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Ambient Hologram Base Pedestal Rings
                Positioned(
                  bottom: 12,
                  child: CustomPaint(
                    size: Size(widget.size * 0.9, 50),
                    painter: _PedestalRingsPainter(
                      color: widget.primaryColor,
                      rotation: currentRotation,
                    ),
                  ),
                ),

                // 2. Floating 3D Product Mesh Representation
                Transform.translate(
                  offset: Offset(0, floatOffset - 15),
                  child: Transform(
                    alignment: FractionalOffset.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateX(_tiltAngle)
                      ..rotateY(currentRotation),
                    child: Container(
                      width: widget.size * 0.65,
                      height: widget.size * 0.65,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.primaryColor.withValues(alpha: 0.35),
                            AppColors.surfaceDark.withValues(alpha: 0.85),
                            widget.primaryColor.withValues(alpha: 0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Color.lerp(widget.primaryColor, Colors.white, 0.4)!.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.primaryColor.withValues(alpha: 0.28),
                            blurRadius: 36,
                            spreadRadius: 2,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Hologram Wireframe Grid lines
                          CustomPaint(
                            size: Size(widget.size * 0.65, widget.size * 0.65),
                            painter: _WireframeOverlayPainter(
                              accentColor: widget.primaryColor,
                            ),
                          ),
                          // Core Product Icon / Visual Center
                          Icon(
                            widget.icon,
                            size: widget.size * 0.32,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Subtle Interactive 360° Drag Indicator Pill
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_outlined, size: 14, color: AppColors.neonCyan),
                        const SizedBox(width: 6),
                        Text(
                          'DRAG TO ROTATE 360°',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PedestalRingsPainter extends CustomPainter {
  final Color color;
  final double rotation;

  _PedestalRingsPainter({required this.color, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );

    // Glowing base ellipse
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawOval(rect, glowPaint);

    // Outer precision ring
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(rect, ringPaint);

    // Inner concentric ring
    final innerRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.65,
      height: size.height * 0.65,
    );
    ringPaint.color = color.withValues(alpha: 0.25);
    canvas.drawOval(innerRect, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _PedestalRingsPainter oldDelegate) => true;
}

class _WireframeOverlayPainter extends CustomPainter {
  final Color accentColor;

  _WireframeOverlayPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 0.8;

    const divisions = 4;
    final stepX = size.width / divisions;
    final stepY = size.height / divisions;

    for (int i = 1; i < divisions; i++) {
      canvas.drawLine(Offset(stepX * i, 0), Offset(stepX * i, size.height), linePaint);
      canvas.drawLine(Offset(0, stepY * i), Offset(size.width, stepY * i), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
