import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.isSmall = false,
  });

  factory StatusBadge.stock(int stock, int minStock) {
    if (stock <= 0) {
      return const StatusBadge(
        label: 'Out of Stock',
        color: AppColors.errorRed,
        icon: Icons.cancel_outlined,
      );
    } else if (stock <= minStock) {
      return StatusBadge(
        label: 'Low: $stock left',
        color: AppColors.alertOrange,
        icon: Icons.warning_amber_rounded,
      );
    } else {
      return StatusBadge(
        label: '$stock in stock',
        color: AppColors.stockGreen,
        icon: Icons.check_circle_outline,
      );
    }
  }

  factory StatusBadge.order(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return const StatusBadge(
          label: 'Completed',
          color: AppColors.stockGreen,
          icon: Icons.check_circle,
        );
      case OrderStatus.refunded:
        return const StatusBadge(
          label: 'Refunded',
          color: AppColors.errorRed,
          icon: Icons.replay,
        );
      case OrderStatus.held:
        return const StatusBadge(
          label: 'Held',
          color: AppColors.alertOrange,
          icon: Icons.pause_circle_outline,
        );
      case OrderStatus.voided:
        return const StatusBadge(
          label: 'Voided',
          color: AppColors.textMuted,
          icon: Icons.block,
        );
    }
  }

  factory StatusBadge.shift(ShiftStatus status) {
    if (status == ShiftStatus.open) {
      return const StatusBadge(
        label: 'Shift Open',
        color: AppColors.neonCyan,
        icon: Icons.lock_open_rounded,
      );
    } else {
      return const StatusBadge(
        label: 'Shift Closed',
        color: AppColors.textMuted,
        icon: Icons.lock_outline_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isSmall ? 11 : 13,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
