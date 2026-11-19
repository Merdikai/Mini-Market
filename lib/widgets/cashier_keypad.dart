import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class CashierKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPress;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final ValueChanged<double>? onQuickCash;
  final double? orderTotal;

  const CashierKeypad({
    super.key,
    required this.onKeyPress,
    required this.onBackspace,
    required this.onClear,
    this.onQuickCash,
    this.orderTotal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onQuickCash != null && orderTotal != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                _buildQuickCashButton(
                  context,
                  label: 'Exact',
                  amount: orderTotal!,
                  isPrimary: true,
                ),
                const SizedBox(width: 8),
                _buildQuickCashButton(
                  context,
                  label: '\$10',
                  amount: 10.0,
                ),
                const SizedBox(width: 8),
                _buildQuickCashButton(
                  context,
                  label: '\$20',
                  amount: 20.0,
                ),
                const SizedBox(width: 8),
                _buildQuickCashButton(
                  context,
                  label: '\$50',
                  amount: 50.0,
                ),
                const SizedBox(width: 8),
                _buildQuickCashButton(
                  context,
                  label: '\$100',
                  amount: 100.0,
                ),
              ],
            ),
          ),
        ],
        _buildKeyRow(context, ['1', '2', '3'], isDark),
        const SizedBox(height: 8),
        _buildKeyRow(context, ['4', '5', '6'], isDark),
        const SizedBox(height: 8),
        _buildKeyRow(context, ['7', '8', '9'], isDark),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildSpecialKey(
              context,
              label: 'C',
              onTap: onClear,
              isDark: isDark,
              color: AppColors.errorRed,
            ),
            const SizedBox(width: 8),
            _buildKey(context, '0', isDark),
            const SizedBox(width: 8),
            _buildSpecialKey(
              context,
              icon: Icons.backspace_outlined,
              onTap: onBackspace,
              isDark: isDark,
              color: AppColors.alertOrange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyRow(BuildContext context, List<String> keys, bool isDark) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKey(context, key, isDark),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKey(BuildContext context, String key, bool isDark) {
    return InkWell(
      onTap: () => onKeyPress(key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceElevated : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
          ),
        ),
        child: Text(
          key,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(
    BuildContext context, {
    String? label,
    IconData? icon,
    required VoidCallback onTap,
    required bool isDark,
    required Color color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
              ),
            ),
            child: icon != null
                ? Icon(icon, color: color, size: 20)
                : Text(
                    label ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCashButton(
    BuildContext context, {
    required String label,
    required double amount,
    bool isPrimary = false,
  }) {
    final isDark = AppTheme.isDark(context);
    return Expanded(
      child: InkWell(
        onTap: () => onQuickCash?.call(amount),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isPrimary
                ? (isDark ? AppColors.neonCyan : AppColors.brandPrimary)
                : (isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPrimary
                  ? Colors.transparent
                  : (isDark ? AppColors.glassBorder : AppColors.lightBorder),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isPrimary
                  ? (isDark ? AppColors.obsidian : Colors.white)
                  : (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
            ),
          ),
        ),
      ),
    );
  }
}
