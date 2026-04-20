import 'package:flutter/material.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/core/widgets/qty_adjuster.dart';
import 'package:warehouse_app/data/sample/sample_order_catalog.dart';

class ItemPickerSheet extends StatefulWidget {
  final List<OrderItem> items;
  final ValueChanged<List<OrderItem>> onChanged;

  const ItemPickerSheet({
    super.key,
    required this.items,
    required this.onChanged,
  });

  @override
  State<ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<ItemPickerSheet> {
  final TextEditingController _scanController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _scanController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final filteredCatalog = sampleOrderCatalog.where((item) {
      if (_search.isEmpty) return true;
      final query = _search.toLowerCase();
      return item.name.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _scanController,
          textInputAction: TextInputAction.done,
          onSubmitted: _handleScanSubmit,
          decoration: const InputDecoration(
            hintText: 'Scan or enter item SKU',
            prefixIcon: Icon(Icons.search),
            suffixIcon: Icon(Icons.qr_code_scanner),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'or browse below',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary(brightness),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.items.isNotEmpty) ...[
          Text(
            'Added Items',
            style: AppTextStyles.title.copyWith(
              color: AppColors.textPrimary(brightness),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (int index = 0; index < widget.items.length; index++) ...[
                  _SelectedItemRow(
                    item: widget.items[index],
                    onChanged: (qty) =>
                        _updateQty(widget.items[index].itemId, qty),
                    onRemove: () => _removeItem(widget.items[index].itemId),
                  ),
                  if (index < widget.items.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _search = value),
          decoration: const InputDecoration(
            hintText: 'Search by item name or SKU',
            prefixIcon: Icon(Icons.filter_list),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              for (int index = 0; index < filteredCatalog.length; index++) ...[
                _CatalogRow(
                  item: filteredCatalog[index],
                  onAdd: () => _addCatalogItem(filteredCatalog[index]),
                ),
                if (index < filteredCatalog.length - 1)
                  const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _handleScanSubmit(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final matched =
        sampleOrderCatalog.where((item) => item.sku == trimmed).toList();
    _scanController.clear();
    if (matched.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item not found in catalog')),
      );
      return;
    }
    _addCatalogItem(matched.first);
  }

  void _addCatalogItem(CatalogItem item) {
    final current = [...widget.items];
    final index = current.indexWhere((existing) => existing.itemId == item.id);
    if (index != -1) {
      current[index] =
          current[index].copyWith(quantity: current[index].quantity + 1);
    } else {
      current.add(
        OrderItem(
          itemId: item.id,
          itemName: item.name,
          itemSku: item.sku,
          quantity: 1,
        ),
      );
    }
    widget.onChanged(current);
  }

  void _updateQty(String itemId, int qty) {
    widget.onChanged([
      for (final item in widget.items)
        if (item.itemId == itemId)
          item.copyWith(quantity: qty.clamp(1, 999))
        else
          item,
    ]);
  }

  void _removeItem(String itemId) {
    widget.onChanged(
      widget.items.where((item) => item.itemId != itemId).toList(),
    );
  }
}

class _SelectedItemRow extends StatelessWidget {
  final OrderItem item;
  final ValueChanged<int> onChanged;
  final VoidCallback onRemove;

  const _SelectedItemRow({
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.itemSku,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary(brightness),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 108,
            child: QtyAdjuster(
              value: item.quantity,
              onChanged: onChanged,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _CatalogRow extends StatelessWidget {
  final CatalogItem item;
  final VoidCallback onAdd;

  const _CatalogRow({
    required this.item,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.sku,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary(brightness),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onAdd,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
