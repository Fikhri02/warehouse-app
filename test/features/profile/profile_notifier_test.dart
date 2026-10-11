import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/biometrics.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/features/profile/providers/profile_provider.dart';

class FakeBiometrics implements BiometricAuth {
  FakeBiometrics({this.available = true, this.approves = true});

  final bool available;
  final bool approves;

  @override
  Future<bool> canCheck() async => available;

  @override
  Future<bool> authenticate(String reason) async => approves;
}

void main() {
  test('biometric login turns on after a fingerprint, is remembered, and turns off', () async {
    final store = MemoryKeyValueStore();
    final container = ProviderContainer(overrides: [
      biometricAuthProvider.overrideWithValue(FakeBiometrics()),
      settingsStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(container.dispose);
    final notifier = container.read(profileSettingsProvider.notifier);

    expect(await notifier.toggleBiometric(), isTrue);
    expect(container.read(profileSettingsProvider).biometricEnabled, isTrue);
    expect(store.values['settings.biometric'], 'true');

    expect(await notifier.toggleBiometric(), isTrue);
    expect(container.read(profileSettingsProvider).biometricEnabled, isFalse);
    expect(store.values['settings.biometric'], 'false');
  });

  test('a phone without biometrics keeps it off', () async {
    final container = ProviderContainer(overrides: [
      biometricAuthProvider.overrideWithValue(FakeBiometrics(available: false)),
      settingsStoreProvider.overrideWithValue(MemoryKeyValueStore()),
    ]);
    addTearDown(container.dispose);

    expect(await container.read(profileSettingsProvider.notifier).toggleBiometric(), isFalse);
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
