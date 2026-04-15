import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/receiving_provider.dart';

class ReceiveSummaryScreen extends ConsumerWidget {
  const ReceiveSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(activeReceiveNotifierProvider);
    if (order == null) {
      return const Scaffold(body: Center(child: Text('No active session')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${order.id} — Summary'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'All items processed',
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Column(
                    children: order.lineItems.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final received = item.received ?? 0;
                      final ok = !item.flagged && received == item.expected;
                      final variance = received - item.expected;
                      final color = item.flagged || received != item.expected
                          ? AppColors.error
                          : AppColors.success;

                      return Column(
                        children: [
                          if (idx > 0) const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.itemName,
                                          style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text('Expected ${item.expected}',
                                          style: AppTextStyles.caption
                                              .copyWith(
                                                  color: AppColors.subtitle)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$received',
                                          style: AppTextStyles.title
                                              .copyWith(color: color),
                                        ),
                                        if (ok) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.check_circle_outline,
                                              size: 14,
                                              color: AppColors.success),
                                        ],
                                      ],
                                    ),
                                    if (item.flagged)
                                      Text('flagged',
                                          style: AppTextStyles.micro
                                              .copyWith(color: color)),
                                    if (!item.flagged &&
                                        received != item.expected)
                                      Text(
                                          variance >= 0
                                              ? '+$variance'
                                              : '$variance',
                                          style: AppTextStyles.micro
                                              .copyWith(color: color)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                if (order.hasFlagged) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      border: Border.all(color: const Color(0xFFFFE082)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_outlined,
                            size: 16, color: Color(0xFF795548)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Discrepancy noted. Supervisor will be notified on submit.',
                            style: AppTextStyles.caption
                                .copyWith(color: const Color(0xFF795548)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(activeReceiveNotifierProvider.notifier)
                      .submitReceive();
                  if (context.mounted) context.go(AppRoutes.dashboard);
                } catch (e) {
                  debugPrint('submitReceive failed: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to submit — please try again'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Close PO & Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
