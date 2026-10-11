import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/supervisor/providers/pending_review_provider.dart';

class PendingReviewScreen extends ConsumerWidget {
  const PendingReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(pendingReviewProvider);
    final brightness = Theme.of(context).brightness;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go(AppRoutes.dashboard);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.go(AppRoutes.dashboard),
          ),
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
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary(brightness),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: reviews.length,
              itemBuilder: (context, i) =>
                  _ReviewCard(count: reviews[i]),
            );
          },
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final CountSummary count;

  const _ReviewCard({required this.count});

  @override
  Widget build(BuildContext context) {
    final secondaryText = AppColors.textSecondary(Theme.of(context).brightness);
    final submitted = count.submittedAt == null ? null : MaterialLocalizations.of(context).formatMediumDate(count.submittedAt!);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fact_check_outlined, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(count.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              [
                '${count.lineCount} ${count.lineCount == 1 ? 'item' : 'items'} counted',
                if (submitted != null) 'submitted $submitted',
              ].join(' · '),
              style: AppTextStyles.bodySmall.copyWith(color: secondaryText),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.pendingReviewDetail, extra: count.id),
                child: const Text('Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
