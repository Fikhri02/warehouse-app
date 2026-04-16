import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/count_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/qty_adjuster.dart';

class CountManualEntryScreen extends StatefulWidget {
  final String? initialCode;

  const CountManualEntryScreen({
    super.key,
    this.initialCode,
  });

  @override
  State<CountManualEntryScreen> createState() => _CountManualEntryScreenState();
}

class _CountManualEntryScreenState extends State<CountManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _itemCodeController;
  final _itemNameController = TextEditingController();
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _itemCodeController = TextEditingController(text: widget.initialCode ?? '');
  }

  @override
  void dispose() {
    _itemCodeController.dispose();
    _itemNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Counted quantity must be at least 1')),
      );
      return;
    }

    context.pop(
      CountItem(
        itemCode: _itemCodeController.text.trim(),
        itemName: _itemNameController.text.trim(),
        expected: 0,
        counted: _qty,
        entryMethod: CountEntryMethod.typed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(title: const Text('Manual Item Entry')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _FieldLabel('Item Code'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _itemCodeController,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an item code'
                      : null,
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Item Name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _itemNameController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an item name'
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  'COUNTED QUANTITY',
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.textSecondary(brightness),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                QtyAdjuster(
                  value: _qty,
                  onChanged: (value) => setState(() => _qty = value),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Add Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppTextStyles.micro.copyWith(
          color: AppColors.textSecondary(Theme.of(context).brightness),
          letterSpacing: 0.5,
        ),
      );
}
