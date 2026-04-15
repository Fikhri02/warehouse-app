import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/qty_adjuster.dart';
import '../providers/receiving_provider.dart';

class ReceiveItemsScreen extends ConsumerStatefulWidget {
  const ReceiveItemsScreen({super.key});

  @override
  ConsumerState<ReceiveItemsScreen> createState() => _ReceiveItemsScreenState();
}

class _ReceiveItemsScreenState extends ConsumerState<ReceiveItemsScreen> {
  int _qty = 0;

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(activeReceiveNotifierProvider);
    if (order == null) {
      return const Scaffold(
          body: Center(child: Text('No active receive session')));
    }

    final pending =
        order.lineItems.where((i) => i.received == null && !i.flagged).toList();
    final done = order.lineItems.length - pending.length;
    final total = order.lineItems.length;
    final progress = total > 0 ? done / total : 0.0;

    if (pending.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.receivingSummary);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentItem = pending.first;

    return Scaffold(
      appBar: AppBar(
        title: Text('${order.id} — ${order.supplier}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              key: ValueKey(currentItem.itemCode),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next item',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.subtitle)),
                    const SizedBox(height: 4),
                    Text(currentItem.itemName, style: AppTextStyles.title),
                    const SizedBox(height: 2),
                    Text(
                      '${currentItem.itemCode} · Expected: ${currentItem.expected} units',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.subtitle),
                    ),
                    const SizedBox(height: 16),
                    QtyAdjuster(
                      value: _qty,
                      onChanged: (v) => setState(() => _qty = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_scanner,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Scan barcode to verify item',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref
                          .read(activeReceiveNotifierProvider.notifier)
                          .flagItem(itemCode: currentItem.itemCode);
                      setState(() => _qty = 0);
                    },
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error),
                    child: const Text('Flag Issue'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(activeReceiveNotifierProvider.notifier)
                          .confirmItem(
                            itemCode: currentItem.itemCode,
                            received: _qty,
                          );
                      setState(() => _qty = 0);
                    },
                    child: const Text('Confirm Item'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
