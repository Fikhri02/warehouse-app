import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/delivery_orders/presentation/widgets/delivery_order_card.dart';
import 'package:warehouse_app/features/delivery_orders/providers/delivery_orders_provider.dart';

class DeliveryOrdersListScreen extends ConsumerWidget {
  const DeliveryOrdersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go(AppRoutes.dashboard);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () => context.go(AppRoutes.dashboard),
            ),
            title: const Text('Delivery Orders'),
            bottom: const TabBar(
              tabs: [Tab(text: 'Active'), Tab(text: 'Completed')],
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
            ),
          ),
          body: const SafeArea(
            top: false,
            child: TabBarView(
              children: [
                _OrdersTab(active: true),
                _OrdersTab(active: false),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push(AppRoutes.deliveryOrderNew),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class _OrdersTab extends ConsumerWidget {
  final bool active;

  const _OrdersTab({required this.active});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(deliveryOrdersProvider(active));
    final brightness = Theme.of(context).brightness;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(syncCoordinatorProvider).syncNow();
        return ref.refresh(deliveryOrdersProvider(active).future);
      },
      child: orders.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 220),
            Center(child: CircularProgressIndicator()),
          ],
        ),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Error loading delivery orders: $error',
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ],
        ),
        data: (data) {
          if (data.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 200),
                Center(
                  child: Text(
                    'No delivery orders yet',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary(brightness),
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              for (final order in data)
                DeliveryOrderCard(
                  order: order,
                  onTap: () => context.push(AppRoutes.deliveryOrderDetail,
                      extra: order.id),
                ),
            ],
          );
        },
      ),
    );
  }
}
