import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';

void main() {
  test('the app is set in IBM Plex Sans, light and dark', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      expect(theme.textTheme.bodyMedium?.fontFamily, AppTextStyles.sans);
      expect(theme.textTheme.titleLarge?.fontFamily, AppTextStyles.sans);
      expect(theme.textTheme.labelLarge?.fontFamily, AppTextStyles.sans); // buttons
    }
  });

  test('codes are set in IBM Plex Mono with figures that line up', () {
    expect(AppTextStyles.code.fontFamily, AppTextStyles.mono);
    expect(AppTextStyles.code.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  testWidgets('a plain Text picks up Plex Sans from the theme', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const Scaffold(body: Text('PO-2041'))));
    final style = DefaultTextStyle.of(tester.element(find.text('PO-2041'))).style;
    expect(style.fontFamily, AppTextStyles.sans);
  });
}
