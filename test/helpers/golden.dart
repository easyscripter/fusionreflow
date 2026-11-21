import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Compares the app with `goldens/[name].png` next to the test file.
Future<void> expectGolden(String name) => expectLater(
  find.byType(MaterialApp),
  matchesGoldenFile('goldens/$name.png'),
);

/// Golden test (tag `golden`, skipped in CI) with real shadows: flutter_test
/// draws disabled ones as a hard black outline. The flag is restored before the
/// test ends, otherwise the binding fails. [dark] switches the system theme.
void goldenTest(
  String name,
  Future<void> Function(WidgetTester tester) body, {
  bool dark = false,
}) {
  testWidgets(name, tags: 'golden', (tester) async {
    if (dark) {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    }
    debugDisableShadows = false;
    try {
      await body(tester);
    } finally {
      debugDisableShadows = true;
    }
  });
}
