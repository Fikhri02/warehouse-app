import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the app gets its data. Built with `--dart-define=WARETRACK_API=https://host/api` it talks to the
/// WareTrack server; without it, it runs on the Sample repositories (demos, UI work), as before.
class AppConfig {
  AppConfig._();

  static const apiBaseUrl = String.fromEnvironment('WARETRACK_API');
  static bool get useApi => apiBaseUrl.isNotEmpty;
}

/// Read this rather than [AppConfig.useApi], so tests can switch modes.
final useApiProvider = Provider<bool>((_) => AppConfig.useApi);
