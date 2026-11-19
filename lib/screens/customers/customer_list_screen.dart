import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/customer.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditCustomerDialog(BuildContext context, StoreProvider store, [Customer? toEdit]) {
    final nameController = TextEditingController(text: toEdit?.name ?? '');
    final phoneController = TextEditingController(text: toEdit?.phone ?? '');
    final emailController = TextEditingController(text: toEdit?.email ?? '');
    final addressController = TextEditingController(text: toEdit?.address ?? '');
    final notesController = TextEditingController(text: toEdit?.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(toEdit != null ? 'Edit Customer' : 'Add New Customer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Customer Full Name *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Home / Delivery Address'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Preferences / Dietary Notes'),
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
                final phone = phoneController.text.trim();
                if (name.isNotEmpty && phone.isNotEmpty) {
                  if (toEdit != null) {
                    final updated = toEdit.copyWith(
                      name: name,
                      phone: phone,
                      email: emailController.text.trim(),
                      address: addressController.text.trim(),
                      notes: notesController.text.trim(),
                    );
                    store.updateCustomer(updated);
                  } else {
                    final newCustomer = Customer(
                      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      phone: phone,
                      email: emailController.text.trim(),
                      address: addressController.text.trim(),
                      notes: notesController.text.trim(),
                    );
                    store.addCustomer(newCustomer);
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Customer $name saved successfully.'),
                      backgroundColor: AppColors.stockGreen,
                    ),
                  );
                }
              },
              child: const Text('Save Customer'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCreditDialog(BuildContext context, StoreProvider store, Customer customer) {
    final amountController = TextEditingController(text: '20.00');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Top-up Store Credit: ${customer.name}'),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Credit Amount (\$)',
              prefixIcon: Icon(Icons.attach_money_rounded),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amountController.text) ?? 0.0;
                if (amt > 0) {
                  store.addStoreCredit(customer.id, amt);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added \$${amt.toStringAsFixed(2)} store credit to ${customer.name}.'),
                      backgroundColor: AppColors.stockGreen,
                    ),
                  );
                }
              },
              child: const Text('Add Credit'),
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

    final customers = store.customers.where((c) {
      if (_query.isEmpty) return true;
      return c.name.toLowerCase().contains(_query.toLowerCase()) ||
          c.phone.contains(_query) ||
          c.email.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Customer CRM & Loyalty'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'Add Customer',
            onPressed: () => _showAddEditCustomerDialog(context, store),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _query = val),
                decoration: InputDecoration(
                  hintText: 'Search customer by name, phone or email...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Customers List
            Expanded(
              child: customers.isEmpty
                  ? Center(
                      child: Text(
                        'No matching customers found.',
                        style: TextStyle(
                          color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: customers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        final isCartCustomer = store.selectedCartCustomer?.id == customer.id;

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerDetailScreen(customer: customer),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isCartCustomer
                                    ? AppColors.stockGreen
                                    : (isDark ? AppColors.glassBorder : AppColors.lightBorder),
                                width: isCartCustomer ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: isDark ? AppColors.neonCyan.withValues(alpha: 0.15) : AppColors.brandPrimary.withValues(alpha: 0.12),
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 22,
                                        color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            customer.name,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                            ),
                                          ),
                                          Text(
                                            '${customer.phone} • ${customer.visitCount} visits',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Loyalty Points Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.champagneGold.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star_rounded, size: 14, color: AppColors.champagneGold),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${customer.loyaltyPoints} pts',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.champagneGold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Store Credit: ${CurrencyFormatter.format(customer.storeCredit, store.settings.currencySymbol)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: customer.storeCredit > 0 ? AppColors.stockGreen : AppColors.textMuted,
                                          ),
                                        ),
                                        Text(
                                          'Lifetime Spent: ${CurrencyFormatter.format(customer.totalSpent, store.settings.currencySymbol)}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        OutlinedButton(
                                          onPressed: () => _showAddCreditDialog(context, store, customer),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          ),
                                          child: const Text('+ Credit'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            store.setCartCustomer(isCartCustomer ? null : customer);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  isCartCustomer
                                                      ? 'Unlinked customer from active cart.'
                                                      : 'Linked ${customer.name} to active POS cart.',
                                                ),
                                                backgroundColor: AppColors.stockGreen,
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            backgroundColor: isCartCustomer ? AppColors.errorRed : (isDark ? AppColors.neonCyan : AppColors.brandPrimary),
                                            foregroundColor: isCartCustomer ? Colors.white : (isDark ? AppColors.obsidian : Colors.white),
                                          ),
                                          child: Text(isCartCustomer ? 'Unlink' : 'Link POS'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditCustomerDialog(context, store),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Customer'),
      ),
    );
  }
}
