import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/retail_cached_image.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? productToEdit;

  const AddEditProductScreen({super.key, this.productToEdit});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _skuController;
  late TextEditingController _barcodeController;
  late TextEditingController _priceController;
  late TextEditingController _costPriceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _unitController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descController;
  late String _selectedCategory;

  bool get _isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _titleController = TextEditingController(text: p?.title ?? '');
    _skuController = TextEditingController(text: p?.sku ?? 'MM-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
    _barcodeController = TextEditingController(text: p?.barcode ?? '012${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}');
    _priceController = TextEditingController(text: p != null ? p.price.toStringAsFixed(2) : '');
    _costPriceController = TextEditingController(text: p != null ? p.costPrice.toStringAsFixed(2) : '');
    _stockController = TextEditingController(text: p != null ? p.stock.toString() : '20');
    _minStockController = TextEditingController(text: p != null ? p.minStock.toString() : '5');
    _unitController = TextEditingController(text: p?.unit ?? 'pcs');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&q=80');
    _descController = TextEditingController(text: p?.description ?? '');
    _selectedCategory = p?.category ?? 'Produce';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _unitController.dispose();
    _imageUrlController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveProduct(StoreProvider store) {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final cost = double.tryParse(_costPriceController.text) ?? 0.0;
    final stock = int.tryParse(_stockController.text) ?? 0;
    final minStock = int.tryParse(_minStockController.text) ?? 5;

    if (_isEditing) {
      final updated = widget.productToEdit!.copyWith(
        title: _titleController.text.trim(),
        sku: _skuController.text.trim(),
        barcode: _barcodeController.text.trim(),
        price: price,
        costPrice: cost,
        category: _selectedCategory,
        stock: stock,
        minStock: minStock,
        unit: _unitController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        description: _descController.text.trim(),
      );
      store.updateProduct(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully.'),
          backgroundColor: AppColors.stockGreen,
        ),
      );
    } else {
      final newProduct = Product(
        id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        sku: _skuController.text.trim(),
        barcode: _barcodeController.text.trim(),
        price: price,
        costPrice: cost,
        category: _selectedCategory,
        stock: stock,
        minStock: minStock,
        unit: _unitController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        description: _descController.text.trim(),
      );
      store.addProduct(newProduct);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product created and added to catalog.'),
          backgroundColor: AppColors.stockGreen,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add New Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            tooltip: 'Save',
            onPressed: () => _saveProduct(store),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Real Image Preview Header
                Center(
                  child: Column(
                    children: [
                      RetailProductImage(
                        imageUrl: _imageUrlController.text,
                        width: 100,
                        height: 100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Refresh Image Preview'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Title & Category
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Product Title *',
                    hintText: 'e.g. Organic Gala Apples',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Department / Category'),
                  items: store.categories.where((c) => c != 'All').map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 12),

                // SKU & Barcode Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _skuController,
                        decoration: const InputDecoration(labelText: 'SKU Code'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _barcodeController,
                        decoration: const InputDecoration(labelText: 'UPC / Barcode'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Financials: Selling Price & Cost Price
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Selling Price (\$) *',
                          prefixIcon: Icon(Icons.sell_outlined),
                        ),
                        validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid price' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _costPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Cost Price (\$) *',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                        validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid cost' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Inventory Controls: Stock & Min Stock
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Current Stock *',
                          prefixIcon: Icon(Icons.storage_rounded),
                        ),
                        validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter valid count' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _minStockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Low Stock Alert At *',
                        ),
                        validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter threshold' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          hintText: 'pcs/kg/pack',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Image URL
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'CDN Image URL',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description / Notes',
                    hintText: 'Specifications, origin, ingredients or allergens...',
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _saveProduct(store),
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: Text(
                      _isEditing ? 'Save Product Changes' : 'Create Catalog Product',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
