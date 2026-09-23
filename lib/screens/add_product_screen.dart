import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/store_provider.dart';

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
  String _category = 'smartphones';

  final categories = [
    'smartphones',
    'audio',
    'clothing',
    'computers',
    'photography',
    'accessories',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingProduct != null) {
      _titleCtrl.text = widget.existingProduct!.title;
      _priceCtrl.text = widget.existingProduct!.price.toString();
      _descCtrl.text = widget.existingProduct!.description;
      _category = widget.existingProduct!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingProduct != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          isEdit ? 'Edit product' : 'Add product',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _fieldLabel('Title'),
            _textField(_titleCtrl, 'Desk lamp'),
            const SizedBox(height: 16),
            _fieldLabel('Price'),
            _textField(_priceCtrl, '0',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _fieldLabel('Category'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  items: categories
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Description'),
            _textField(_descCtrl, 'Short description', maxLines: 4),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final store = context.read<StoreProvider>();
                  final price =
                      double.tryParse(_priceCtrl.text.trim()) ?? 0;
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
                      description: _descCtrl.text.trim(),
                      icon: Icons.widgets,
                      color: const Color(0xFFE5DAF5),
                    ));
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  isEdit ? 'Save changes' : 'Save product',
                  style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(text,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ),
      );

  Widget _textField(TextEditingController ctrl, String hint,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}