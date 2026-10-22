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

class SupervisorDashboardScreen extends ConsumerWidget {
  const SupervisorDashboardScreen({super.key});

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
                subtitle: '2 active',
                icon: Icons.inventory_2_outlined,
                isPrimary: true,
                onTap: () => context.go(AppRoutes.stockCount),
              ),
              QuickActionCard(
                label: 'Stock Receive',
                subtitle: '1 pending',
                icon: Icons.move_to_inbox_outlined,
                onTap: () => context.go(AppRoutes.receiving),
              ),
              QuickActionCard(
                label: 'Assign Tasks',
                subtitle: '3 workers',
                icon: Icons.assignment_outlined,
                onTap: () => context.push(AppRoutes.assignTasks),
              ),
              QuickActionCard(
                label: 'Reports',
                subtitle: 'View summaries',
                icon: Icons.bar_chart_outlined,
                onTap: () => context.push(AppRoutes.reports),
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
          Text('Pending Review',
              style: AppTextStyles.micro.copyWith(
                color: AppColors.textSecondary(brightness),
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                _ReviewTile(
                  title: 'Count #15 — John Doe',
                  subtitle: 'Aisle C · 2 variances',
                  onReview: () => context.push(AppRoutes.pendingReview),
                ),
                const Divider(height: 1),
                _ReviewTile(
                  title: 'PO-2041 — Discrepancy',
                  subtitle: 'Steel Bolt M8 · −20 units',
                  onReview: () => context.push(AppRoutes.pendingReview),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onReview;

  const _ReviewTile({
    required this.title,
    required this.subtitle,
    required this.onReview,
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
          GestureDetector(
            onTap: onReview,
            child: Text('Review',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
