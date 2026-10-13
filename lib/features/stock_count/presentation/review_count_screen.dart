import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/count_session.dart';
import '../../../core/models/staff_task.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/stock_count_provider.dart';
import '../../tasks/widgets/finish_task_prompt.dart';

class ReviewCountScreen extends ConsumerWidget {
  const ReviewCountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(stockCountNotifierProvider);
    final brightness = Theme.of(context).brightness;

    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('No active session')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Submit'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${session.location} · ${session.items.length} items',
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: session.items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 14, endIndent: 14),
                itemBuilder: (context, idx) {
                  final item = session.items[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.itemName,
                                  style: AppTextStyles.body
                                      .copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(item.itemCode,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary(brightness),
                                  )),
                              const SizedBox(height: 2),
                              Text(
                                item.entryMethod == CountEntryMethod.typed
                                    ? 'Entered manually'
                                    : 'Scanned',
                                style: AppTextStyles.micro.copyWith(
                                  color: AppColors.textSecondary(brightness),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${item.counted}',
                          style: AppTextStyles.title.copyWith(color: AppColors.textPrimary(brightness)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(stockCountNotifierProvider.notifier)
                        .submitSession();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ref.read(isOnlineProvider)
                            ? 'Count sent for review.'
                            : "Count saved. It will be sent when you're back online."),
                      ));
                    }
                    if (context.mounted) await offerToFinishTask(context, ref, TaskType.stockCount);
                    if (context.mounted) context.go(AppRoutes.stockCount);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Failed to submit count — please try again'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Submit Count'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
