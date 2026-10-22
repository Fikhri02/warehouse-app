import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/biometrics.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';

class ProfileSettings {
  final bool biometricEnabled;
  final bool darkModeEnabled;
  final bool notificationsEnabled;
  final bool hapticFeedbackEnabled;

  const ProfileSettings({
    this.biometricEnabled = false,
    this.darkModeEnabled = false,
    this.notificationsEnabled = true,
    this.hapticFeedbackEnabled = true,
  });

  ProfileSettings copyWith({
    bool? biometricEnabled,
    bool? darkModeEnabled,
    bool? notificationsEnabled,
    bool? hapticFeedbackEnabled,
  }) {
    return ProfileSettings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
    );
  }
}

/// Settings kept between launches. main.dart overrides it with secure storage.
final settingsStoreProvider = Provider<KeyValueStore>((_) => MemoryKeyValueStore());

/// Whether biometric login was on when the app started (read in main.dart).
final biometricPreferenceProvider = Provider<bool>((_) => false);

class ProfileSettingsNotifier extends Notifier<ProfileSettings> {
  @override
  ProfileSettings build() => ProfileSettings(biometricEnabled: ref.read(biometricPreferenceProvider));

  /// Turning it on asks for a fingerprint first, so nobody switches it on for a phone that can't check one.
  /// Returns false when that check is unavailable or fails.
  Future<bool> toggleBiometric() async {
    final turningOn = !state.biometricEnabled;
    if (turningOn) {
      final biometrics = ref.read(biometricAuthProvider);
      if (!await biometrics.canCheck() || !await biometrics.authenticate('Turn on biometric login for Atura')) return false;
    }
    await ref.read(settingsStoreProvider).write('settings.biometric', '$turningOn');
    state = state.copyWith(biometricEnabled: turningOn);
    return true;
  }

  void toggleDarkMode() =>
      state = state.copyWith(darkModeEnabled: !state.darkModeEnabled);

  void toggleNotifications() =>
      state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);

  void toggleHapticFeedback() =>
      state = state.copyWith(
          hapticFeedbackEnabled: !state.hapticFeedbackEnabled);
}

final profileSettingsProvider =
    NotifierProvider<ProfileSettingsNotifier, ProfileSettings>(
  ProfileSettingsNotifier.new,
);
