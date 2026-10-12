import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';
import 'package:warehouse_app/features/delivery_orders/providers/delivery_orders_provider.dart';

class DeliveryOrderDetailScreen extends ConsumerWidget {
  final String id;

  const DeliveryOrderDetailScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderValue = ref.watch(deliveryOrderDetailProvider(id));

    return orderValue.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Delivery Order')),
        body: Center(child: Text('Unable to load order: $error')),
      ),
      data: (order) {
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Delivery Order')),
            body: const Center(child: Text('Order not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(order.orderNumber)),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatusBanner(
                    status: order.status, changedAt: _latestChange(order)),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Order Info',
                  rows: [
                    ('Destination', order.destination),
                    ('Delivery Date', _formatDate(order.deliveryDate)),
                    ('Created By', order.createdBy),
                    (
                      'Notes',
                      order.notes?.trim().isNotEmpty == true
                          ? order.notes!
                          : '-'
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ItemsCard(items: order.items),
                const SizedBox(height: 12),
                _TimelineCard(
                  status: order.status,
                  history: order.statusHistory,
                ),
              ],
            ),
          ),
          bottomNavigationBar: _ActionBar(order: order),
        );
      },
    );
  }

  DateTime _latestChange(DeliveryOrder order) {
    if (order.statusHistory.isEmpty) return order.createdAt;
    return order.statusHistory.last.changedAt;
  }
}

class _ActionBar extends ConsumerWidget {
  final DeliveryOrder order;

  const _ActionBar({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (order.status == OrderStatus.shipped) {
      return const SizedBox.shrink();
    }
    final isSupervisor = ref.watch(authNotifierProvider.select((a) => a.valueOrNull?.role)) == UserRole.supervisor;

    Widget child;
    if (order.status == OrderStatus.draft) {
      child = ElevatedButton(
        onPressed: () => context.push(AppRoutes.deliveryOrderNew, extra: order),
        child: const Text('Edit Order'),
      );
    } else if (order.status == OrderStatus.pendingApproval) {
      child = !isSupervisor
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Waiting for a supervisor to approve', textAlign: TextAlign.center),
            )
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(context, ref, OrderStatus.draft),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(context, ref, OrderStatus.submitted),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            );
    } else {
      child = ElevatedButton(
        onPressed: () => _updateStatus(context, ref, order.status.nextStatus!),
        child: Text(order.status.nextActionLabel!),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: child,
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, OrderStatus status) async {
    try {
      await ref.read(ordersRepositoryProvider).updateOrderStatus(kind: OrderKind.delivery, id: order.id, status: status);
    } on StateError catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    _reload(ref);
    // Send it now, then show what the server made of it: a refused change falls back to the server's status.
    await ref.read(syncCoordinatorProvider).syncNow();
    _reload(ref);
  }

  void _reload(WidgetRef ref) {
    ref.invalidate(deliveryOrdersProvider(true));
    ref.invalidate(deliveryOrdersProvider(false));
    ref.invalidate(deliveryOrderDetailProvider(order.id));
  }
}

class _StatusBanner extends StatelessWidget {
  final OrderStatus status;
  final DateTime changedAt;

  const _StatusBanner({
    required this.status,
    required this.changedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              status.displayName,
              style: AppTextStyles.title.copyWith(color: Colors.white),
            ),
          ),
          Text(
            _formatDateTime(changedAt),
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<(String, String)> rows;

  const _InfoCard({
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.title),
            const SizedBox(height: 12),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.$1, style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(row.$2, style: AppTextStyles.body),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final List<OrderItem> items;

  const _ItemsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Items', style: AppTextStyles.title),
            const SizedBox(height: 12),
            for (int index = 0; index < items.length; index++) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[index].itemName,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary(brightness),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[index].locationCode == null
                              ? items[index].itemSku
                              : '${items[index].itemSku} · ${items[index].locationCode}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary(brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('×${items[index].quantity}', style: AppTextStyles.body),
                ],
              ),
              if (index < items.length - 1) const Divider(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final OrderStatus status;
  final List<OrderStatusHistory> history;

  const _TimelineCard({
    required this.status,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status History', style: AppTextStyles.title),
            const SizedBox(height: 12),
            for (int index = 0; index < OrderStatus.values.length; index++)
              _TimelineRow(
                status: OrderStatus.values[index],
                currentStatus: status,
                history: history,
                isLast: index == OrderStatus.values.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final OrderStatus status;
  final OrderStatus currentStatus;
  final List<OrderStatusHistory> history;
  final bool isLast;

  const _TimelineRow({
    required this.status,
    required this.currentStatus,
    required this.history,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final matched = history.where((item) => item.status == status).toList();
    final isCurrent = currentStatus == status;
    final isDone = matched.isNotEmpty;
    final dotColor = isCurrent
        ? status.color
        : isDone
            ? AppColors.primary
            : AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.displayName,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    matched.isEmpty
                        ? 'Pending'
                        : _formatDateTime(matched.last.changedAt),
                    style: AppTextStyles.caption.copyWith(
                      color:
                          AppColors.textSecondary(Theme.of(context).brightness),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}

String _formatDateTime(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.day} ${months[value.month - 1]} ${value.year} · ${value.hour}:$minute';
}
