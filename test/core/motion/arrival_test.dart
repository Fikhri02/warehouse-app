import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/motion/arrival.dart';

void main() {
  double opacityOf(WidgetTester tester, String text) =>
      tester.widget<Opacity>(find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first).opacity;

  testWidgets('without an arrival the child shows as-is', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StaggeredEntrance(order: 2, child: Text('Recent'))));
    expect(opacityOf(tester, 'Recent'), 1.0);
  });

  testWidgets('during an arrival later sections start later', (tester) async {
    final controller = AnimationController(vsync: tester, duration: kArrival)..value = 90 / 450; // 90ms in
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: ArrivalAnimation(
        animation: controller,
        child: const Column(children: [
          StaggeredEntrance(order: 0, child: Text('Greeting')),
          StaggeredEntrance(order: 2, child: Text('Recent')),
        ]),
      ),
    ));
    expect(opacityOf(tester, 'Greeting'), greaterThan(0));
    expect(opacityOf(tester, 'Recent'), 0);

    controller.value = 1;
    await tester.pump();
    expect(opacityOf(tester, 'Recent'), 1);
  });

  testWidgets('the bottom bar slides up from below instead of fading', (tester) async {
    final controller = AnimationController(vsync: tester, duration: kArrival);
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: ArrivalAnimation(
        animation: controller,
        child: const Align(
          alignment: Alignment.bottomCenter,
          child: StaggeredEntrance(order: 1, fromBelow: true, child: SizedBox(height: 80, child: Text('Bar'))),
        ),
      ),
    ));
    expect(opacityOf(tester, 'Bar'), 1);
    expect(tester.getTopLeft(find.text('Bar')).dy, greaterThanOrEqualTo(600)); // below the 600pt test screen

    controller.value = 1;
    await tester.pump();
    expect(tester.getTopLeft(find.text('Bar')).dy, 600 - 80);
  });
}
