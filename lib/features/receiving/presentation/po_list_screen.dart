import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/purchase_order.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/receiving_provider.dart';

class PoListScreen extends ConsumerStatefulWidget {
  const PoListScreen({super.key});

  @override
  ConsumerState<PoListScreen> createState() => _PoListScreenState();
}

class _PoListScreenState extends ConsumerState<PoListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _syncAndReload() =>
      ref.read(purchaseOrdersNotifierProvider.notifier).syncAndReload();

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(purchaseOrdersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'Pending'), Tab(text: 'Completed')],
        ),
      ),
      body: SafeArea(
        top: false,
        child: ordersState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (orders) {
            final filtered = _search.isEmpty
                ? orders
                : orders
                    .where(
                      (order) =>
                          order.displayNumber
                              .toLowerCase()
                              .contains(_search.toLowerCase()) ||
                          order.supplier
                              .toLowerCase()
                              .contains(_search.toLowerCase()),
                    )
                    .toList();

            final inProgress =
                filtered.where((o) => o.status == PoStatus.inProgress).toList();
            final pending =
                filtered.where((o) => o.status == PoStatus.pending).toList();
            final completed =
                filtered.where((o) => o.status == PoStatus.received).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    onChanged: (value) => setState(() => _search = value),
                    decoration: const InputDecoration(
                      hintText: 'Search PO or supplier...',
                      isDense: true,
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      RefreshIndicator(
                        onRefresh: _syncAndReload,
                        child: _PendingTab(
                          inProgress: inProgress,
                          pending: pending,
                          ref: ref,
                        ),
                      ),
                      RefreshIndicator(
                        onRefresh: _syncAndReload,
                        child: _CompletedTab(completed: completed, ref: ref),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PendingTab extends StatelessWidget {
  final List<PurchaseOrder> inProgress;
  final List<PurchaseOrder> pending;
  final WidgetRef ref;

  const _PendingTab({
    required this.inProgress,
    required this.pending,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    if (inProgress.isEmpty && pending.isEmpty) {
      // Scrollable, so pulling down still fetches new orders.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(
            child: Text(
              'No pending purchase orders',
              style: TextStyle(color: AppColors.subtitle),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      children: [
        if (inProgress.isNotEmpty) ...[
          const _SectionLabel('In Progress'),
          ...inProgress.map((order) => _PoCard(order: order, ref: ref)),
        ],
        if (pending.isNotEmpty) ...[
          const _SectionLabel('Pending'),
          ...pending.map((order) => _PoCard(order: order, ref: ref)),
        ],
      ],
    );
  }
}

class _CompletedTab extends StatelessWidget {
  final List<PurchaseOrder> completed;
  final WidgetRef ref;

  const _CompletedTab({
    required this.completed,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    if (completed.isEmpty) {
      // Scrollable, so pulling down still fetches new orders.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(
            child: Text(
              'No completed purchase orders',
              style: TextStyle(color: AppColors.subtitle),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      children: [
        const _SectionLabel('Received'),
        ...completed.map((order) => _PoCard(order: order, ref: ref)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 3),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.subtitle,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _PoCard extends StatelessWidget {
  final PurchaseOrder order;
  final WidgetRef ref;

  const _PoCard({
    required this.order,
    required this.ref,
  });

  Color get _headerColor {
    switch (order.status) {
      case PoStatus.inProgress:
        return AppColors.warning;
      case PoStatus.received:
        return AppColors.primary;
      case PoStatus.pending:
        return const Color(0xFF78909C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActionable =
        order.status == PoStatus.pending || order.status == PoStatus.inProgress;
    final receivedCount =
        order.lineItems.where((i) => i.received != null).length;
    final totalCount = order.lineItems.length;
    final progress = totalCount > 0 ? receivedCount / totalCount : 0.0;

    String dateLabel = '';
    if (order.status == PoStatus.received && order.receivedAt != null) {
      final date = order.receivedAt!;
      dateLabel = '${date.day} ${_month(date.month)} ${date.year}';
    } else if (order.dueDate != null) {
      final date = order.dueDate!;
      dateLabel = 'Due ${date.day} ${_month(date.month)}';
    }

    return GestureDetector(
      onTap: isActionable
          ? () {
              ref
                  .read(activeReceiveNotifierProvider.notifier)
                  .startReceive(order);
              context.push(AppRoutes.receivingItems);
            }
          : () => context.push(AppRoutes.receivingDetails, extra: order.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _headerColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      order.displayNumber,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    dateLabel,
                    style:
                        AppTextStyles.caption.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.supplier,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          order.status == PoStatus.inProgress
                              ? '$receivedCount / $totalCount items received'
                              : '$totalCount items',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (order.status == PoStatus.inProgress)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(progress * 100).round()}%',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.subtitle,
                          ),
                        ),
                        const SizedBox(height: 3),
                        SizedBox(
                          width: 56,
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 3,
                            backgroundColor: AppColors.background,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _month(int month) => const [
        '',
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
      ][month];
}
