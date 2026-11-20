import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens the debug menu ⋮ of the library and taps the hyphen spike item.
Future<void> openHyphenSpike(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('library_debug_menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('open_hyphen_spike')));
  await tester.pumpAndSettle();
}
