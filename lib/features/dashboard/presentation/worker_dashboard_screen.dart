import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_greeting.dart';
import 'widgets/quick_action_card.dart';

class WorkerDashboardScreen extends ConsumerWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authNotifierProvider).valueOrNull;
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: const DashboardAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DashboardGreeting(session: session),
          const SizedBox(height: 20),
          Text('Quick Actions',
              style: AppTextStyles.micro.copyWith(
                color: AppColors.textSecondary(brightness),
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: [
              QuickActionCard(
                label: 'Stock Count',
                subtitle: 'Start counting',
                icon: Icons.inventory_2_outlined,
                isPrimary: true,
                onTap: () => context.go(AppRoutes.stockCount),
              ),
              QuickActionCard(
                label: 'Stock Receive',
                subtitle: 'Receive goods',
                icon: Icons.move_to_inbox_outlined,
                onTap: () => context.go(AppRoutes.receiving),
              ),
              QuickActionCard(
                label: 'Delivery Orders',
                subtitle: 'Manage transfers',
                icon: Icons.local_shipping_outlined,
                onTap: () => context.push(AppRoutes.deliveryOrders),
              ),
              QuickActionCard(
                label: 'Sales Orders',
                subtitle: 'Customer sales',
                icon: Icons.receipt_long_outlined,
                onTap: () => context.push(AppRoutes.salesOrders),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Recent Activity',
              style: AppTextStyles.micro.copyWith(
                color: AppColors.textSecondary(brightness),
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 10),
          const Card(
            child: Column(
              children: [
                _ActivityTile(
                  title: 'Count Session #14',
                  subtitle: 'Aisle B · 2h ago',
                  status: 'DONE',
                  statusColor: AppColors.success,
                ),
                Divider(height: 1),
                _ActivityTile(
                  title: 'Received PO-2041',
                  subtitle: 'Supplier: Acme · Today',
                  status: 'DONE',
                  statusColor: AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color:
                          AppColors.textSecondary(Theme.of(context).brightness),
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status,
                style: AppTextStyles.micro.copyWith(color: statusColor)),
          ),
        ],
      ),
    );
  }
}
