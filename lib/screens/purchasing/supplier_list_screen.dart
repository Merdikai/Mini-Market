import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/supplier.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class SupplierListScreen extends StatelessWidget {
  const SupplierListScreen({super.key});

  void _showAddEditSupplierDialog(BuildContext context, StoreProvider store, [Supplier? toEdit]) {
    final nameController = TextEditingController(text: toEdit?.name ?? '');
    final companyController = TextEditingController(text: toEdit?.companyName ?? '');
    final emailController = TextEditingController(text: toEdit?.email ?? '');
    final phoneController = TextEditingController(text: toEdit?.phone ?? '');
    final addressController = TextEditingController(text: toEdit?.address ?? '');
    final taxIdController = TextEditingController(text: toEdit?.taxId ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(toEdit != null ? 'Edit Supplier' : 'Add New Supplier'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: 'Company / Business Name *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Contact Representative Name *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Warehouse / Delivery Address'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: taxIdController,
                  decoration: const InputDecoration(labelText: 'Tax EIN / VAT ID'),
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
                final company = companyController.text.trim();
                final contact = nameController.text.trim();
                if (company.isNotEmpty && contact.isNotEmpty) {
                  if (toEdit != null) {
                    final updated = toEdit.copyWith(
                      companyName: company,
                      name: contact,
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      address: addressController.text.trim(),
                      taxId: taxIdController.text.trim(),
                    );
                    store.updateSupplier(updated);
                  } else {
                    final newSupplier = Supplier(
                      id: 'sup_${DateTime.now().millisecondsSinceEpoch}',
                      companyName: company,
                      name: contact,
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      address: addressController.text.trim(),
                      taxId: taxIdController.text.trim(),
                    );
                    store.addSupplier(newSupplier);
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Supplier $company saved successfully.'),
                      backgroundColor: AppColors.stockGreen,
                    ),
                  );
                }
              },
              child: const Text('Save Supplier'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);
    final suppliers = store.suppliers;

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Supplier Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_rounded),
            tooltip: 'Add Supplier',
            onPressed: () => _showAddEditSupplierDialog(context, store),
          ),
        ],
      ),
      body: SafeArea(
        child: suppliers.isEmpty
            ? Center(
                child: Text(
                  'No suppliers registered.',
                  style: TextStyle(
                    color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: suppliers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final sup = suppliers[index];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                sup.companyName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () => _showAddEditSupplierDialog(context, store, sup),
                            ),
                          ],
                        ),
                        Text(
                          'Contact: ${sup.name}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              sup.phone,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(width: 14),
                            const Icon(Icons.email_outlined, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              sup.email,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sup.address,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                          ),
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Outstanding AP Balance:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(sup.balance, store.settings.currencySymbol),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: sup.balance > 0 ? AppColors.alertOrange : AppColors.stockGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSupplierDialog(context, store),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Add Supplier'),
      ),
    );
  }
}
