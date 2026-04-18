import 'package:vibration/vibration.dart';

Future<void> vibrateOnScan() async {
  if (await Vibration.hasVibrator()) {
    Vibration.vibrate(duration: 200);
  }
}
