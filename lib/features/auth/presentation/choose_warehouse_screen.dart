import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';

/// For people who work in more than one warehouse: the phone syncs one at a time.
class ChooseWarehouseScreen extends ConsumerWidget {
  const ChooseWarehouseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authNotifierProvider).valueOrNull;
    if (session == null) return const SizedBox.shrink();
    final brightness = Theme.of(context).brightness;
    final switching = session.warehouseId != null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: switching,
        title: const Text('Choose warehouse'),
        actions: [
          if (!switching)
            TextButton(
              onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Sign out'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'You work in more than one warehouse. Counts and tasks on this phone belong to the one you choose.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary(brightness)),
            ),
          ),
          for (final w in session.warehouses)
            ListTile(
              leading: const Icon(Icons.warehouse_outlined, color: AppColors.primary),
              title: Text(w.name, style: AppTextStyles.bodyMedium),
              subtitle: Text('${w.code} · ${w.role == UserRole.supervisor ? 'Supervisor' : 'Worker'}'),
              trailing: w.warehouseId == session.warehouseId ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () async {
                await ref.read(authNotifierProvider.notifier).selectWarehouse(w.warehouseId);
                if (context.mounted) context.go(AppRoutes.dashboard);
              },
            ),
        ],
      ),
    );
  }
}
