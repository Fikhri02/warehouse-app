import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none));
});

/// true = currently online
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).valueOrNull ?? true;
});
