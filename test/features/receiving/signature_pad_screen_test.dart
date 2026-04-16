import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/features/receiving/presentation/signature_pad_screen.dart';

// Minimal GoRouter that places SignaturePadScreen as the only route.
GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SignaturePadScreen(),
      ),
    ],
  );
}

Widget _buildApp({GoRouter? router}) {
  return MaterialApp.router(
    routerConfig: router ?? _buildRouter(),
  );
}

void main() {
  group('SignaturePadScreen', () {
    testWidgets(
        'renders correctly — AppBar shows "Sign PO", Cancel and Confirm Signature buttons are visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // AppBar title
      expect(find.text('Sign PO'), findsOneWidget);

      // Bottom-bar buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm Signature'), findsOneWidget);
    });

    testWidgets('"Confirm Signature" button is disabled when canvas is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Find the FilledButton by its child text
      final confirmButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirm Signature'),
      );

      expect(confirmButton.onPressed, isNull,
          reason:
              'onPressed should be null (disabled) when no signature has been drawn');
    });

    testWidgets(
        'AppBar contains a clear (delete_outline) icon button with tooltip "Clear"',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // The IconButton wraps an Icon with Icons.delete_outline
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      // Tooltip is set to 'Clear'
      final tooltip = tester.widget<Tooltip>(
        find.ancestor(
          of: find.byIcon(Icons.delete_outline),
          matching: find.byType(Tooltip),
        ),
      );
      expect(tooltip.message, 'Clear');
    });

    testWidgets('"Cancel" button pops the route with no result',
        (WidgetTester tester) async {
      // Build a two-route GoRouter: /home -> /signature.
      // After tapping Cancel, GoRouter pops back to /home.
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.push('/signature'),
                child: const Text('Open Signature'),
              ),
            ),
          ),
          GoRoute(
            path: '/signature',
            builder: (context, state) => const SignaturePadScreen(),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Navigate to the signature screen.
      await tester.tap(find.text('Open Signature'));
      await tester.pumpAndSettle();

      expect(find.text('Sign PO'), findsOneWidget,
          reason: 'Should be on SignaturePadScreen now');

      // Tap Cancel — GoRouter should pop back to /home.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // After pop, we should be back on the home screen.
      expect(find.text('Open Signature'), findsOneWidget,
          reason: 'Tapping Cancel should pop back to /home');
      expect(find.text('Sign PO'), findsNothing);
    });
  });
}
