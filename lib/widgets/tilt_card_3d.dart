import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Interactive 3D perspective tilt card inspired by Artefakt and luxury watch showcases.
/// Dynamically updates 4x4 transform matrix and simulates an iridescent specular light reflection.
class TiltCard3D extends StatefulWidget {
  final Widget child;
  final double maxTiltAngle;
  final double perspective;
  final double depth;
  final bool enableSheen;
  final VoidCallback? onTap;

  const TiltCard3D({
    super.key,
    required this.child,
    this.maxTiltAngle = 0.22, // radians (~12.6 degrees)
    this.perspective = 0.0018,
    this.depth = 12.0,
    this.enableSheen = true,
    this.onTap,
  });

  @override
  State<TiltCard3D> createState() => _TiltCard3DState();
}

class _TiltCard3DState extends State<TiltCard3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<double> _rotXAnimation;
  late Animation<double> _rotYAnimation;

  double _rotX = 0.0;
  double _rotY = 0.0;
  Offset _touchPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _springController.addListener(() {
      setState(() {
        _rotX = _rotXAnimation.value;
        _rotY = _rotYAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    _springController.stop();
    final localPos = details.localPosition;
    _touchPosition = localPos;

    // Normalize touch from -1.0 to 1.0 relative to center
    final normX = (localPos.dx / size.width - 0.5) * 2.0;
    final normY = (localPos.dy / size.height - 0.5) * 2.0;

    setState(() {
      _rotY = (normX * widget.maxTiltAngle).clamp(-widget.maxTiltAngle, widget.maxTiltAngle);
      _rotX = (-normY * widget.maxTiltAngle).clamp(-widget.maxTiltAngle, widget.maxTiltAngle);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    _rotXAnimation = Tween<double>(begin: _rotX, end: 0.0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutCubic),
    );
    _rotYAnimation = Tween<double>(begin: _rotY, end: 0.0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutCubic),
    );
    _springController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardSize = Size(constraints.maxWidth, constraints.maxHeight);

        // 3D Perspective Matrix
        final transform = Matrix4.identity()
          ..setEntry(3, 2, widget.perspective)
          ..rotateX(_rotX)
          ..rotateY(_rotY);

        return GestureDetector(
          onTap: widget.onTap,
          onPanUpdate: (d) => _handlePanUpdate(d, cardSize),
          onPanEnd: _handlePanEnd,
          onPanCancel: () => _handlePanEnd(DragEndDetails()),
          child: Transform(
            transform: transform,
            alignment: FractionalOffset.center,
            child: Stack(
              children: [
                widget.child,
                // Specular Light Sheen Overlay
                if (widget.enableSheen && (_rotX != 0 || _rotY != 0))
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(
                                (_touchPosition.dx / (cardSize.width > 0 ? cardSize.width : 1) - 0.5) * 2,
                                (_touchPosition.dy / (cardSize.height > 0 ? cardSize.height : 1) - 0.5) * 2,
                              ),
                              radius: 0.85,
                              colors: [
                                AppColors.neonCyan.withValues(alpha: 0.18),
                                Colors.white.withValues(alpha: 0.08),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
