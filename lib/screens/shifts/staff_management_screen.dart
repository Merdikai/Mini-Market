import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/staff_user.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class StaffManagementScreen extends StatelessWidget {
  const StaffManagementScreen({super.key});

  void _showAddStaffDialog(BuildContext context, StoreProvider store) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final pinController = TextEditingController();
    StaffRole selectedRole = StaffRole.cashier;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Add Staff Member'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email Address'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: pinController,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '4-Digit Login PIN',
                        hintText: 'e.g. 5678',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<StaffRole>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(labelText: 'Assigned Role'),
                      items: StaffRole.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.displayName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedRole = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final pin = pinController.text.trim();
                    if (name.isNotEmpty && pin.length == 4) {
                      store.staffList.add(
                        StaffUser(
                          id: 'staff_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          email: emailController.text.trim(),
                          role: selectedRole,
                          pin: pin,
                        ),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Staff member $name added successfully.'),
                          backgroundColor: AppColors.stockGreen,
                        ),
                      );
                    }
                  },
                  child: const Text('Add Staff'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);
    final staffList = store.staffList;

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Staff & Permissions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'Add Staff',
            onPressed: () => _showAddStaffDialog(context, store),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: staffList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final staff = staffList[index];
            final isCurrent = store.currentStaff?.id == staff.id;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrent
                      ? (isDark ? AppColors.neonCyan : AppColors.brandPrimary)
                      : (isDark ? AppColors.glassBorder : AppColors.lightBorder),
                  width: isCurrent ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
                    child: Icon(
                      Icons.person_rounded,
                      color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              staff.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.stockGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    color: AppColors.stockGreen,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${staff.role.displayName} • PIN: ${staff.pin}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          staff.email,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isCurrent)
                    TextButton(
                      onPressed: () {
                        store.switchStaff(staff);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Switched terminal to ${staff.name}')),
                        );
                      },
                      child: const Text('Switch'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStaffDialog(context, store),
        icon: const Icon(Icons.add),
        label: const Text('Add Staff'),
        backgroundColor: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
        foregroundColor: isDark ? AppColors.obsidian : Colors.white,
      ),
    );
  }
}
