import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';

/// What is waiting to be sent, and what the server did not accept and why.
class SyncIssuesScreen extends ConsumerWidget {
  const SyncIssuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingChangesProvider).valueOrNull ?? 0;
    final issues = ref.watch(syncIssuesProvider).valueOrNull ?? const <SyncIssue>[];
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(title: const Text('Sync')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            pending == 0
                ? 'Everything on this phone has been sent.'
                : '$pending ${pending == 1 ? 'change is' : 'changes are'} waiting to be sent.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => ref.read(syncCoordinatorProvider).syncNow(),
            icon: const Icon(Icons.sync),
            label: const Text('Send now'),
          ),
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Not accepted', style: AppTextStyles.title),
            const SizedBox(height: 8),
            for (final issue in issues)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.error_outline, color: AppColors.error),
                  title: Text(issue.title, style: AppTextStyles.bodyMedium),
                  subtitle: Text(issue.message, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(brightness))),
                  trailing: TextButton(
                    onPressed: () => ref.read(appDatabaseProvider).syncQueueDao.dismiss(issue.id),
                    child: const Text('Dismiss'),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
