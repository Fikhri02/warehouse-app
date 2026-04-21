import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/widgets/scan_mode_panel.dart';

void main() {
  const surfaceKey = Key('surface-body');

  Widget buildSubject(ScanModeController controller) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(
          child: ScanModeSurface(
            controller: controller,
            child: Column(
              children: [
                ScanModePanel(
                  controller: controller,
                  collapsedHeight: 160,
                  expandedHeight: 240,
                  onDetect: (_) async {},
                  preview: const SizedBox(
                    height: 160,
                    child: ColoredBox(color: Colors.black),
                  ),
                ),
                const Expanded(
                  child: ColoredBox(
                    key: surfaceKey,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> swipeSurface(
    WidgetTester tester, {
    required Offset offset,
  }) async {
    final rect = tester.getRect(find.byKey(surfaceKey));
    await tester.flingFrom(rect.center, offset, 1200);
    await tester.pump(const Duration(milliseconds: 200));
  }

  group('ScanModeSurface', () {
    testWidgets('changes modes when swiping below the preview',
        (WidgetTester tester) async {
      final controller = ScanModeController();

      await tester.pumpWidget(buildSubject(controller));
      await tester.pump();

      expect(find.text('BULK'), findsOneWidget);

      await swipeSurface(tester, offset: const Offset(-400, 0));
      expect(find.text('3S DELAY'), findsOneWidget);

      await swipeSurface(tester, offset: const Offset(400, 0));
      expect(find.text('BULK'), findsOneWidget);
    });

    testWidgets('surface swipe still works while one-snap overlay is active',
        (WidgetTester tester) async {
      final controller = ScanModeController();

      await tester.pumpWidget(buildSubject(controller));
      await tester.pump();

      await swipeSurface(tester, offset: const Offset(400, 0));
      expect(find.text('ONE-SNAP'), findsOneWidget);
      expect(find.text('TAP TO SCAN NEXT'), findsOneWidget);

      await swipeSurface(tester, offset: const Offset(-400, 0));
      expect(find.text('BULK'), findsOneWidget);
      expect(find.text('TAP TO SCAN NEXT'), findsNothing);
    });
  });
}
