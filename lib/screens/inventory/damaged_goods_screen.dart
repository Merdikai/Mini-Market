import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class DamagedGoodsScreen extends StatefulWidget {
  const DamagedGoodsScreen({super.key});

  @override
  State<DamagedGoodsScreen> createState() => _DamagedGoodsScreenState();
}

class _DamagedGoodsScreenState extends State<DamagedGoodsScreen> {
  Product? _selectedProduct;
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _reasonController = TextEditingController(text: 'Expired / Passed shelf life');

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submitDamageLog(StoreProvider store) {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product.')),
      );
      return;
    }

    final qty = int.tryParse(_quantityController.text) ?? 1;
    if (qty <= 0) return;

    store.logDamagedGoods(
      _selectedProduct!.id,
      qty,
      _reasonController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Wrote off $qty ${_selectedProduct!.unit} of ${_selectedProduct!.title}.'),
        backgroundColor: AppColors.alertOrange,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);
    final products = store.products;

    if (_selectedProduct == null && products.isNotEmpty) {
      _selectedProduct = products.first;
    }

    final qty = int.tryParse(_quantityController.text) ?? 1;
    final costLoss = (_selectedProduct?.costPrice ?? 0.0) * qty;

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Damaged Goods & Waste Log'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Selector
              DropdownButtonFormField<Product>(
                initialValue: _selectedProduct,
                decoration: const InputDecoration(labelText: 'Select Product to Write Off'),
                items: products.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text('${p.title} (Stock: ${p.stock})'),
                  );
                }).toList(),
                onChanged: (p) => setState(() => _selectedProduct = p),
              ),
              const SizedBox(height: 14),

              // Quantity
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Damaged Quantity (${_selectedProduct?.unit ?? "pcs"})',
                  prefixIcon: const Icon(Icons.remove_circle_outline),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Reason
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Disposal Reason',
                  hintText: 'e.g. Expired, packaging crushed during handling',
                ),
              ),
              const SizedBox(height: 20),

              // Cost Loss Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ESTIMATED COST LOSS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(costLoss, store.settings.currencySymbol),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.errorRed,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.delete_sweep_rounded, size: 36, color: AppColors.errorRed),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _submitDamageLog(store),
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Record Waste & Deduct Inventory'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed,
                    foregroundColor: Colors.white,
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
