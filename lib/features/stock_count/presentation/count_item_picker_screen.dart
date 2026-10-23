import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/count_session.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/core/widgets/qty_adjuster.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';

final _searchProvider = FutureProvider.autoDispose.family<List<CatalogItemRef>, String>(
  (ref, term) => ref.watch(stockCountRepositoryProvider).searchItems(term),
);

/// Server mode: counting an item without a barcode means choosing it from the catalogue (no free-text items).
class CountItemPickerScreen extends ConsumerStatefulWidget {
  const CountItemPickerScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  ConsumerState<CountItemPickerScreen> createState() => _CountItemPickerScreenState();
}

class _CountItemPickerScreenState extends ConsumerState<CountItemPickerScreen> {
  late final TextEditingController _search = TextEditingController(text: widget.initialCode ?? '');
  late String _term = widget.initialCode ?? '';
  CatalogItemRef? _chosen;
  int _qty = 1;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final results = ref.watch(_searchProvider(_term));
    final chosen = _chosen;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Item')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _search,
                autofocus: true,
                onChanged: (value) => setState(() => _term = value),
                decoration: const InputDecoration(hintText: 'Search by SKU or name', prefixIcon: Icon(Icons.search)),
              ),
            ),
            Expanded(
              child: results.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text("Couldn't search the catalogue.")),
                data: (items) => items.isEmpty
                    ? Center(
                        child: Text(
                          'No item matches "$_term".',
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary(brightness)),
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) => ListTile(
                          title: Text(items[i].name, style: AppTextStyles.bodyMedium),
                          subtitle: Text(items[i].sku, style: AppTextStyles.code),
                          trailing: items[i].id == chosen?.id ? const Icon(Icons.check, color: AppColors.primary) : null,
                          onTap: () => setState(() {
                            _chosen = items[i];
                            _qty = 1;
                          }),
                        ),
                      ),
              ),
            ),
            if (chosen != null)
              SafeArea(
                top: false,
                minimum: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(chosen.name, style: AppTextStyles.title),
                    const SizedBox(height: 8),
                    QtyAdjuster(value: _qty, onChanged: (v) => setState(() => _qty = v)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _qty < 1
                          ? null
                          : () => context.pop(CountItem(
                                itemId: chosen.id,
                                itemCode: chosen.sku,
                                itemName: chosen.name,
                                expected: 0,
                                counted: _qty,
                                entryMethod: CountEntryMethod.typed,
                              )),
                      child: const Text('Add to Count'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
