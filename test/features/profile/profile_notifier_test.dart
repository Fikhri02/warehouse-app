import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/features/profile/providers/profile_provider.dart';

void main() {
  test('toggleBiometric flips biometric setting', () {
    final container = ProviderContainer(
      overrides: [
        profileSettingsProvider.overrideWith(() => ProfileSettingsNotifier()),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(profileSettingsProvider.notifier);
    expect(container.read(profileSettingsProvider).biometricEnabled, isFalse);

    notifier.toggleBiometric();
    expect(container.read(profileSettingsProvider).biometricEnabled, isTrue);

    notifier.toggleBiometric();
    expect(container.read(profileSettingsProvider).biometricEnabled, isFalse);
  });

  test('toggleDarkMode flips dark mode setting', () {
    final container = ProviderContainer(
      overrides: [
        profileSettingsProvider.overrideWith(() => ProfileSettingsNotifier()),
      ],
    );
    addTearDown(container.dispose);

    container.read(profileSettingsProvider.notifier).toggleDarkMode();
    expect(container.read(profileSettingsProvider).darkModeEnabled, isTrue);
  });

  test('toggleNotifications flips notification setting', () {
    final container = ProviderContainer(
      overrides: [
        profileSettingsProvider.overrideWith(() => ProfileSettingsNotifier()),
      ],
    );
    addTearDown(container.dispose);

    container.read(profileSettingsProvider.notifier).toggleNotifications();
    expect(container.read(profileSettingsProvider).notificationsEnabled, isFalse);
  });
}
