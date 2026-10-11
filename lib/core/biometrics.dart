import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Fingerprint or face check, wrapped so tests can stand in for the phone.
class BiometricAuth {
  BiometricAuth([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> canCheck() async => await _auth.canCheckBiometrics && await _auth.isDeviceSupported();

  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, options: const AuthenticationOptions(biometricOnly: true));
    } on Exception {
      return false; // cancelled, locked out, or not enrolled
    }
  }
}

final biometricAuthProvider = Provider<BiometricAuth>((_) => BiometricAuth());
