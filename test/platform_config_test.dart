import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Settings the app needs on real phones that no Dart test can exercise.
void main() {
  test('release builds may use the network', () {
    expect(File('android/app/src/main/AndroidManifest.xml').readAsStringSync(), contains('android.permission.INTERNET'));
  });

  test('biometric prompts can show on Android and iOS', () {
    final activity = Directory('android/app/src/main/kotlin')
        .listSync(recursive: true)
        .whereType<File>()
        .firstWhere((f) => f.path.endsWith('MainActivity.kt'))
        .readAsStringSync();
    expect(activity, contains('FlutterFragmentActivity')); // local_auth needs a fragment activity
    expect(File('ios/Runner/Info.plist').readAsStringSync(), contains('NSFaceIDUsageDescription'));
  });
}
