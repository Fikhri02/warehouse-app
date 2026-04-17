import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class ProfileSettingsNotifier extends Notifier<ProfileSettings> {
  @override
  ProfileSettings build() => const ProfileSettings();

  void toggleBiometric() =>
      state = state.copyWith(biometricEnabled: !state.biometricEnabled);

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
