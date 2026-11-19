import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Renders a real internet product image with loading indicator and graceful fallback
class RetailProductImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final BoxFit fit;

  const RetailProductImage({
    super.key,
    required this.imageUrl,
    this.width = 60,
    this.height = 60,
    this.borderRadius,
    this.fallbackIcon = Icons.shopping_basket_outlined,
    this.fallbackColor,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final radius = borderRadius ?? BorderRadius.circular(12);

    if (imageUrl.isEmpty) {
      return _buildFallback(isDark, radius);
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
            child: Center(
              child: SizedBox(
                width: (width.isFinite && width > 0) ? width * 0.35 : 24.0,
                height: (height.isFinite && height > 0) ? height * 0.35 : 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                  ),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback(isDark, radius);
        },
      ),
    );
  }

  Widget _buildFallback(bool isDark, BorderRadius radius) {
    final iconSize = (width.isFinite && width > 0)
        ? width * 0.45
        : (height.isFinite && height > 0 ? height * 0.45 : 28.0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fallbackColor?.withValues(alpha: 0.15) ??
            (isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary),
        borderRadius: radius,
        border: Border.all(
          color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: iconSize,
          color: fallbackColor ?? (isDark ? AppColors.neonCyan : AppColors.brandPrimary),
        ),
      ),
    );
  }
}
