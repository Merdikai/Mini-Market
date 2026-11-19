import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../customers/customer_list_screen.dart';
import '../expenses/expense_list_screen.dart';
import '../inventory/category_management_screen.dart';
import '../inventory/inventory_ledger_screen.dart';
import '../inventory/product_catalog_screen.dart';
import '../inventory/stocktake_audit_screen.dart';
import '../purchasing/supplier_list_screen.dart';
import '../reports/reports_dashboard_screen.dart';
import '../shifts/shift_management_screen.dart';
import '../shifts/staff_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showStoreProfileDialog(BuildContext context, StoreProvider store) {
    final nameController = TextEditingController(text: store.settings.storeName);
    final taglineController = TextEditingController(text: store.settings.tagline);
    final addressController = TextEditingController(text: store.settings.address);
    final phoneController = TextEditingController(text: store.settings.phone);
    final emailController = TextEditingController(text: store.settings.email);
    final taxIdController = TextEditingController(text: store.settings.taxId);
    final taxRateController = TextEditingController(text: (store.settings.taxRate * 100).toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Store Profile & Tax Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Store Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: taglineController,
                  decoration: const InputDecoration(labelText: 'Store Tagline / Slogan'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Physical Address'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Contact Phone'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Store Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: taxIdController,
                  decoration: const InputDecoration(labelText: 'Tax Registration ID'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: taxRateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Sales Tax Rate (%)',
                    suffixText: '%',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final rate = (double.tryParse(taxRateController.text) ?? 8.0) / 100.0;
                final updated = store.settings.copyWith(
                  storeName: nameController.text.trim(),
                  tagline: taglineController.text.trim(),
                  address: addressController.text.trim(),
                  phone: phoneController.text.trim(),
                  email: emailController.text.trim(),
                  taxId: taxIdController.text.trim(),
                  taxRate: rate,
                );
                store.updateSettings(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Store settings updated successfully.'),
                    backgroundColor: AppColors.stockGreen,
                  ),
                );
              },
              child: const Text('Save Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showReceiptDesignerDialog(BuildContext context, StoreProvider store) {
    final headerController = TextEditingController(text: store.settings.receiptHeader);
    final footerController = TextEditingController(text: store.settings.receiptFooter);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Thermal Receipt Customization'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: headerController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Receipt Header Message',
                  hintText: 'e.g. Thank you for choosing Mini Market!',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: footerController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Receipt Footer / Return Policy',
                  hintText: 'e.g. Return within 7 days with valid receipt.',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final updated = store.settings.copyWith(
                  receiptHeader: headerController.text.trim(),
                  receiptFooter: footerController.text.trim(),
                );
                store.updateSettings(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Receipt template updated.'),
                    backgroundColor: AppColors.stockGreen,
                  ),
                );
              },
              child: const Text('Save Template'),
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('System Settings & Control'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Store Identity Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(18),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.settings.storeName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            store.settings.tagline,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showStoreProfileDialog(context, store),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  Text(
                    '${store.settings.address} • Tel: ${store.settings.phone}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                    ),
                  ),
                  Text(
                    'Tax ID: ${store.settings.taxId} • Default VAT: ${(store.settings.taxRate * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Appearance & Frame Controls
            _buildSectionHeader('DISPLAY & THEMES', isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Obsidian Dark Mode', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: const Text('OLED true black contrast theme', style: TextStyle(fontSize: 12)),
                      value: store.settings.isDarkMode,
                      activeThumbColor: AppColors.neonCyan,
                      onChanged: (_) => store.toggleTheme(),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('iPhone Showcase Frame', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: const Text('Display bezel frame for presentations & demos', style: TextStyle(fontSize: 12)),
                      value: store.settings.isDemoFrameVisible,
                      activeThumbColor: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                      onChanged: (_) => store.toggleDemoFrame(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Thermal Receipt Designer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: const Text('Custom header, footer and return policy', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showReceiptDesignerDialog(context, store),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Business Operations Quick Access
            _buildSectionHeader('RETAIL MODULES & HUBS', isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildNavTile(
                    context,
                    icon: Icons.inventory_2_outlined,
                    title: 'Product Catalog & Inventory',
                    subtitle: '${store.products.length} products on file',
                    destination: const ProductCatalogScreen(),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    context,
                    icon: Icons.history_edu_rounded,
                    title: 'Inventory Movement Ledger',
                    subtitle: 'Audit trail of purchases, sales & adjustments',
                    destination: const InventoryLedgerScreen(),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    context,
                    icon: Icons.fact_check_outlined,
                    title: 'Stocktake & Physical Count Audit',
                    subtitle: 'Reconcile counted stock vs database',
                    destination: const StocktakeAuditScreen(),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    context,
                    icon: Icons.category_outlined,
                    title: 'Department Categories',
                    subtitle: '${store.categoriesList.length} store departments',
                    destination: const CategoryManagementScreen(),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    context,
                    icon: Icons.lock_clock_outlined,
                    title: 'Cashier Shifts & Safe Drops',
                    subtitle: 'Drawer opening float and reconciliation',
                    destination: const ShiftManagementScreen(),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    context,
                    icon: Icons.badge_outlined,
                    title: 'Staff Directory & Permissions',
                    subtitle: '${store.staffList.length} staff members registered',
                    destination: const StaffManagementScreen(),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    context,
                    icon: Icons.people_outline_rounded,
                    title: 'Customer CRM & Store Credit',
                    subtitle: '${store.customers.length} registered customer accounts',
                    destination: const CustomerListScreen(),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    context,
                    icon: Icons.local_shipping_outlined,
                    title: 'Suppliers & Purchase Orders',
                    subtitle: '${store.suppliers.length} vendors • ${store.purchaseOrders.length} orders',
                    destination: const SupplierListScreen(),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: 'Store Expenses & Outflow',
                    subtitle: '${store.expenses.length} expense vouchers',
                    destination: const ExpenseListScreen(),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    context,
                    icon: Icons.analytics_outlined,
                    title: 'Financial Reports & P&L',
                    subtitle: 'Daily X-Report, Z-Report and Statements',
                    destination: const ReportsDashboardScreen(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Version Footer
            Center(
              child: Column(
                children: [
                  Text(
                    '${AppConstants.appName} Enterprise v${AppConstants.appVersion}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Clean Architecture • Offline-First Retail POS',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget destination,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, size: 22),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
      ),
    );
  }
}
