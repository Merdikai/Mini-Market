import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class SearchAndFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final VoidCallback? onBarcodeTap;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilter;

  const SearchAndFilterBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search products, SKU or barcode...',
    this.onBarcodeTap,
    this.onFilterTap,
    this.hasActiveFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
              ),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ),
        if (onBarcodeTap != null) ...[
          const SizedBox(width: 8),
          _buildActionButton(
            context,
            icon: Icons.qr_code_scanner_rounded,
            onTap: onBarcodeTap!,
            isDark: isDark,
            tooltip: 'Scan Barcode',
            accentColor: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
          ),
        ],
        if (onFilterTap != null) ...[
          const SizedBox(width: 8),
          _buildActionButton(
            context,
            icon: Icons.tune_rounded,
            onTap: onFilterTap!,
            isDark: isDark,
            tooltip: 'Filter',
            hasBadge: hasActiveFilter,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required String tooltip,
    Color? accentColor,
    bool hasBadge = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasBadge
                  ? AppColors.alertOrange
                  : (isDark ? AppColors.glassBorder : AppColors.lightBorder),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: accentColor ??
                    (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
              ),
              if (hasBadge)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.alertOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
