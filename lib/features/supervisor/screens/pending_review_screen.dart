import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/supervisor/providers/pending_review_provider.dart';

class PendingReviewScreen extends ConsumerWidget {
  const PendingReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(pendingReviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(pendingReviewProvider.notifier).refresh(),
          ),
        ],
      ),
      body: reviewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reviews) {
          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.rate_review_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Nothing to review',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: reviews.length,
            itemBuilder: (context, i) =>
                _ReviewCard(alert: reviews[i], ref: ref),
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Alert alert;
  final WidgetRef ref;

  const _ReviewCard({required this.alert, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_outlined,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alert.body,
              style:
                  AppTextStyles.bodySmall.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Flagged for follow-up')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning),
                  child: const Text('Flag'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Approved')),
                    );
                    ref
                        .read(pendingReviewProvider.notifier)
                        .refresh();
                  },
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
