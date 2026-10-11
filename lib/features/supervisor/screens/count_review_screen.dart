import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/features/supervisor/providers/pending_review_provider.dart';

/// A submitted count with live stock figures. Approve applies each difference on top of what is there now;
/// reject sends the counter a reason. Both are queued commands, so they also work offline.
class CountReviewScreen extends ConsumerWidget {
  const CountReviewScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final review = ref.watch(countReviewProvider(sessionId));
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Count')),
      body: review.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Couldn't load this count. Reviewing needs a connection.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary(brightness)),
                ),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: () => ref.invalidate(countReviewProvider(sessionId)), child: const Text('Try Again')),
              ],
            ),
          ),
        ),
        data: (count) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(count.title, style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(
                    'Counted by ${count.countedBy} · ${MaterialLocalizations.of(context).formatMediumDate(count.submittedAt)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary(brightness)),
                  ),
                  if (count.movedLines > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Stock moved in ${count.movedLines} ${count.movedLines == 1 ? 'bin' : 'bins'} since this count.',
                      style: AppTextStyles.body.copyWith(color: AppColors.warning),
                    ),
                  ],
                  const SizedBox(height: 12),
                  for (final line in count.lines)
                    Card(
                      child: ListTile(
                        title: Text(line.itemName, style: AppTextStyles.bodyMedium),
                        subtitle: Text('${line.sku} · ${line.locationCode}\nCounted ${formatQty(line.counted)} · system ${formatQty(line.systemAtSubmit)} · now ${formatQty(line.current)}'),
                        isThreeLine: true,
                        trailing: Text(
                          line.difference > 0 ? '+${formatQty(line.difference)}' : formatQty(line.difference),
                          style: AppTextStyles.title.copyWith(
                            color: line.difference == 0 ? AppColors.textSecondary(brightness) : AppColors.textPrimary(brightness),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (count.status == 'Submitted')
              SafeArea(
                top: false,
                minimum: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                        onPressed: () => _reject(context, ref),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(onPressed: () => _approve(context, ref, count), child: const Text('Approve')),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref, CountReview count) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve this count?'),
        content: Text(
          "Stock in ${count.changingLines} ${count.changingLines == 1 ? 'bin' : 'bins'} changes by the differences shown. This can't be undone; a later count corrects it.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Approve Count')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(stockCountRepositoryProvider).approveCount(sessionId);
    if (!context.mounted) return;
    _done(context, ref, 'Approval sent.');
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(context: context, builder: (_) => const _RejectDialog());
    if (reason == null) return;
    await ref.read(stockCountRepositoryProvider).rejectCount(sessionId, reason);
    if (!context.mounted) return;
    _done(context, ref, 'Rejection sent.');
  }

  void _done(BuildContext context, WidgetRef ref, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    ref.invalidate(pendingReviewProvider);
    Navigator.of(context).maybePop(); // back to the list (works with or without go_router above)
  }
}

class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _reason = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _reason.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'Say why, so the counter knows what to recount.');
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Reject this count?'),
        content: TextField(
          controller: _reason,
          maxLength: 500,
          maxLines: 3,
          decoration: InputDecoration(labelText: 'Reason', errorText: _error),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: _submit, child: const Text('Reject Count')),
        ],
      );
}
