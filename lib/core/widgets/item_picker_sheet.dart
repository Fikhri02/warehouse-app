import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/core/widgets/qty_adjuster.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';

class ItemPickerSheet extends ConsumerStatefulWidget {
  final List<OrderItem> items;
  final ValueChanged<List<OrderItem>> onChanged;

  const ItemPickerSheet({
    super.key,
    required this.items,
    required this.onChanged,
  });

  @override
  ConsumerState<ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends ConsumerState<ItemPickerSheet> {
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
    final catalog = ref.watch(orderCatalogSearchProvider(_search));

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
                    onChanged: (qty) => _updateQty(index, qty),
                    onRemove: () => _removeItem(index),
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
        catalog.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text('Could not load items: $error'),
          data: (items) => Card(
            child: Column(
              children: [
                for (int index = 0; index < items.length; index++) ...[
                  _CatalogRow(item: items[index], onAdd: () => _addCatalogItem(items[index])),
                  if (index < items.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleScanSubmit(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _scanController.clear();
    final item = await ref.read(ordersRepositoryProvider).findItem(trimmed);
    if (!mounted) return;
    if (item == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item not found in catalog')));
      return;
    }
    _addCatalogItem(item);
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

  // By position: an order may take the same item from two bins.
  void _updateQty(int index, int qty) {
    widget.onChanged([
      for (int i = 0; i < widget.items.length; i++)
        if (i == index) widget.items[i].copyWith(quantity: qty.clamp(1, 999)) else widget.items[i],
    ]);
  }

  void _removeItem(int index) {
    widget.onChanged([...widget.items]..removeAt(index));
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
                  item.locationCode == null ? item.itemSku : '${item.itemSku} · ${item.locationCode}',
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
