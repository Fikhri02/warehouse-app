import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

const int _scanVibrationDurationMs = 700;
const int _scanVibrationAmplitude = 180;

Future<void> triggerScanHapticFeedback() async {
  final hasVibrator = await Vibration.hasVibrator();
  if (hasVibrator != true) {
    await HapticFeedback.selectionClick();
    return;
  }

  final hasCustomSupport = await Vibration.hasCustomVibrationsSupport();
  if (hasCustomSupport == true) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final hasAmplitudeControl = await Vibration.hasAmplitudeControl();
        await Vibration.vibrate(
          duration: _scanVibrationDurationMs,
          amplitude: hasAmplitudeControl == true ? _scanVibrationAmplitude : -1,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        await Vibration.vibrate(duration: _scanVibrationDurationMs);
      default:
        await Vibration.vibrate(duration: _scanVibrationDurationMs);
    }
    return;
  }

  await switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.macOS => HapticFeedback.heavyImpact(),
    TargetPlatform.android => HapticFeedback.vibrate(),
    _ => HapticFeedback.selectionClick(),
  };
}
