import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cashier_keypad.dart';

class CashierPinScreen extends StatefulWidget {
  final VoidCallback? onUnlocked;

  const CashierPinScreen({super.key, this.onUnlocked});

  @override
  State<CashierPinScreen> createState() => _CashierPinScreenState();
}

class _CashierPinScreenState extends State<CashierPinScreen> {
  String _enteredPin = '';
  String? _errorMessage;

  void _onKeyPress(String key) {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += key;
      _errorMessage = null;
    });

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _onClear() {
    setState(() {
      _enteredPin = '';
      _errorMessage = null;
    });
  }

  void _verifyPin() {
    final store = context.read<StoreProvider>();
    final success = store.authenticatePin(_enteredPin);
    if (success) {
      if (widget.onUnlocked != null) {
        widget.onUnlocked!();
      } else {
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _enteredPin = '';
        _errorMessage = 'Invalid PIN. Try again or select user.';
      });
    }
  }

  void _showUserPicker(BuildContext context, StoreProvider store, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Switch Staff Member',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 14),
              ...store.staffList.map((staff) {
                final isSelected = store.currentStaff?.id == staff.id;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
                    child: Icon(
                      Icons.person,
                      color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                    ),
                  ),
                  title: Text(
                    staff.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  subtitle: Text('${staff.role.displayName} • PIN: ${staff.pin}'),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.stockGreen)
                      : null,
                  onTap: () {
                    store.switchStaff(staff);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);
    final staff = store.currentStaff ?? store.staffList.first;

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lock Icon / Avatar
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.neonCyan.withValues(alpha: 0.12)
                          : AppColors.brandPrimary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 36,
                      color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Staff Name & Role
                  Text(
                    staff.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      staff.role.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4-Digit PIN Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isFilled = index < _enteredPin.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled
                              ? (isDark ? AppColors.neonCyan : AppColors.brandPrimary)
                              : Colors.transparent,
                          border: Border.all(
                            color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),

                  // Error Message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.errorRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),

                  // Cashier Keypad
                  CashierKeypad(
                    onKeyPress: _onKeyPress,
                    onBackspace: _onBackspace,
                    onClear: _onClear,
                  ),
                  const SizedBox(height: 20),

                  // Switch User Button
                  TextButton.icon(
                    onPressed: () => _showUserPicker(context, store, isDark),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: const Text('Switch Staff / Demo Accounts'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
