import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('app starts and shows the library screen', (tester) async {
    await pumpApp(tester);

    expect(find.byKey(const Key('library_screen')), findsOneWidget);
    expect(find.text('Библиотека'), findsWidgets);
  });
}
