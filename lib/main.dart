import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse_app/core/config/app_config.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/router/app_router.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/api/api_auth_repository.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_providers.dart';
import 'package:warehouse_app/data/api/api_receiving_repository.dart';
import 'package:warehouse_app/data/api/api_stock_count_repository.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/data/api/token_store.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide UserSession;
import 'package:warehouse_app/data/repositories/alerts_repository.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';
import 'package:warehouse_app/data/repositories/receiving_repository.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/data/sample/sample_alerts_repository.dart';
import 'package:warehouse_app/data/sample/sample_auth_repository.dart';
import 'package:warehouse_app/data/sample/sample_receiving_repository.dart';
import 'package:warehouse_app/data/sample/sample_stock_count_repository.dart';
import 'package:warehouse_app/data/sample/sample_tasks_repository.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';
import 'package:warehouse_app/features/profile/providers/profile_provider.dart';
import 'package:warehouse_app/features/stock_count/providers/stock_count_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  final database = AppDatabase();
  // Built with --dart-define=WARETRACK_API=https://host/api: the server. Otherwise: Sample data, as before.
  final ApiClient? client = AppConfig.useApi
      ? ApiClient(baseUrl: AppConfig.apiBaseUrl, httpClient: http.Client(), tokens: TokenStore(SecureKeyValueStore(storage)))
      : null;
  final AuthRepository authRepository = client != null ? ApiAuthRepository(client: client, db: database) : SampleAuthRepository(storage);
  UserSession? initialSession;
  try {
    initialSession = await authRepository.getStoredSession();
  } on Exception {
    initialSession = null; // anything unexpected on the way in: start at sign-in rather than not at all
  }
  final settingsStore = SecureKeyValueStore(storage);
  final biometricOn = await settingsStore.read('settings.biometric') == 'true';
  final locked = biometricOn && initialSession != null; // ask for a fingerprint before opening a stored session

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        if (client != null) apiClientProvider.overrideWithValue(client),
        alertsRepositoryProvider.overrideWith((_) => SampleAlertsRepository()),
        authBootstrapStateProvider.overrideWith((_) => AuthBootstrapState.hydrated(locked ? null : initialSession)),
        settingsStoreProvider.overrideWithValue(settingsStore),
        biometricPreferenceProvider.overrideWithValue(biometricOn),
        lockedSessionProvider.overrideWith((_) => locked ? initialSession : null),
        authRepositoryProvider.overrideWith((_) => authRepository),
        ordersRepositoryProvider.overrideWith((_) => SampleOrdersRepository()),
        receivingRepositoryProvider.overrideWith(
          (ref) => client == null
              ? SampleReceivingRepository()
              : ApiReceivingRepository(
                  db: database,
                  session: () => ref.read(authNotifierProvider).valueOrNull,
                  onQueued: () => unawaited(ref.read(syncCoordinatorProvider).syncNow()),
                ),
        ),
        stockCountRepositoryProvider.overrideWith(
          (ref) => client == null
              ? SampleStockCountRepository()
              : ApiStockCountRepository(
                  client: client,
                  db: database,
                  session: () => ref.read(authNotifierProvider).valueOrNull,
                  onQueued: () => unawaited(ref.read(syncCoordinatorProvider).syncNow()),
                ),
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
    if (ref.read(useApiProvider)) {
      // The server refused the refresh token (revoked, deactivated): back to sign-in with nothing left behind.
      ref.read(apiClientProvider).onSessionExpired = () => ref.read(authNotifierProvider.notifier).logout();
    }
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
