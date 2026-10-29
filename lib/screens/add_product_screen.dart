import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/store_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';

class AddProductScreen extends StatefulWidget {
  final Product? existingProduct;
  const AddProductScreen({super.key, this.existingProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'Horology';

  final categories = [
    'Horology',
    'Cyber Apparel',
    'Audio',
    'Futuristic EDC',
    'Hardware',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingProduct != null) {
      _titleCtrl.text = widget.existingProduct!.title;
      _priceCtrl.text = widget.existingProduct!.price.toStringAsFixed(0);
      _descCtrl.text = widget.existingProduct!.description;
      _category = widget.existingProduct!.category;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingProduct != null;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          isEdit ? 'REFINE ARTIFACT' : 'PUBLISH ARTIFACT',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('ARTIFACT DESIGNATION / TITLE'),
                  _textField(_titleCtrl, 'e.g. Apex Chrono Carbon'),
                  const SizedBox(height: 20),
                  _fieldLabel('VALUATION PRICE (USD)'),
                  _textField(_priceCtrl, '1200', keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  _fieldLabel('CLASSIFICATION CATEGORY'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      border: Border.all(color: AppColors.glassBorder),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: categories.contains(_category) ? _category : categories.first,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceDark,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.neonCyan),
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        items: categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _fieldLabel('NARRATIVE SPECIFICATION / DESCRIPTION'),
                  _textField(_descCtrl, 'Describe materials, tolerances, and design narrative...', maxLines: 4),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: AppColors.obsidian,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  final store = context.read<StoreProvider>();
                  final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
                  final title = _titleCtrl.text.trim();
                  if (title.isEmpty) return;

                  if (isEdit) {
                    final p = widget.existingProduct!;
                    p.title = title;
                    p.price = price;
                    p.category = _category;
                    p.description = _descCtrl.text.trim();
                    store.updateProduct(p);
                  } else {
                    store.addProduct(Product(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      price: price,
                      category: _category,
                      description: _descCtrl.text.trim().isEmpty
                          ? 'Engineered precision craftsmanship.'
                          : _descCtrl.text.trim(),
                      icon: Icons.auto_awesome,
                      color: AppColors.neonCyan,
                      badge: 'NEW ARRIVAL',
                    ));
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  isEdit ? 'SAVE SPECIFICATIONS' : 'INITIALIZE ARTIFACT',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _textField(TextEditingController ctrl, String hint,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
