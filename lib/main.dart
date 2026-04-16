import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:warehouse_app/core/router/app_router.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/repositories/alerts_repository.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';
import 'package:warehouse_app/data/repositories/receiving_repository.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/data/sample/sample_alerts_repository.dart';
import 'package:warehouse_app/data/sample/sample_auth_repository.dart';
import 'package:warehouse_app/data/sample/sample_receiving_repository.dart';
import 'package:warehouse_app/data/sample/sample_stock_count_repository.dart';
import 'package:warehouse_app/data/sample/sample_tasks_repository.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';
import 'package:warehouse_app/features/stock_count/providers/stock_count_provider.dart';
import 'package:warehouse_app/features/profile/providers/profile_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        alertsRepositoryProvider.overrideWith((_) => SampleAlertsRepository()),
        authRepositoryProvider.overrideWith(
          (_) => SampleAuthRepository(const FlutterSecureStorage()),
        ),
        receivingRepositoryProvider.overrideWith(
          (_) => SampleReceivingRepository(),
        ),
        stockCountRepositoryProvider.overrideWith(
          (_) => SampleStockCountRepository(),
        ),
        tasksRepositoryProvider.overrideWith((_) => SampleTasksRepository()),
      ],
      child: const WarehouseApp(),
    ),
  );
}

class WarehouseApp extends ConsumerStatefulWidget {
  const WarehouseApp({super.key});

  @override
  ConsumerState<WarehouseApp> createState() => _WarehouseAppState();
}

class _WarehouseAppState extends ConsumerState<WarehouseApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(stockCountNotifierProvider.notifier).tryResumeSession(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Activate sync watcher — reads provider to start the listener
    ref.watch(syncWatcherProvider);

    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(profileSettingsProvider);
    return MaterialApp.router(
      title: 'WareTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
