import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/models/purchase_order.dart';
import '../providers/receiving_provider.dart';

class PoListScreen extends ConsumerWidget {
  const PoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(purchaseOrdersNotifierProvider);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Receive')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search PO number or supplier...',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
            ),
            Expanded(
              child: ordersState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (orders) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final order = orders[idx];
                    final isPending = order.status == PoStatus.pending;
                    return GestureDetector(
                      onTap: isPending
                          ? () {
                              ref
                                  .read(activeReceiveNotifierProvider.notifier)
                                  .startReceive(order);
                              context.push(AppRoutes.receivingItems);
                            }
                          : null,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(order.id,
                                        style: AppTextStyles.body.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isPending
                                                ? AppColors.textPrimary(
                                                    brightness)
                                                : AppColors.textSecondary(
                                                    brightness))),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${order.supplier} · ${order.lineItems.length} items',
                                      style: AppTextStyles.caption.copyWith(
                                          color: isPending
                                              ? AppColors.textSecondary(
                                                  brightness)
                                              : (brightness == Brightness.dark
                                                  ? AppColors.darkBorder
                                                  : AppColors.border)),
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(isPending
                                  ? BadgeVariant.pending
                                  : BadgeVariant.received),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
