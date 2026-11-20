import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/domain/models/import_update.dart';

import '../../../helpers/library_harness.dart';

const _longName =
    'Очень длинное название книги, которое точно не поместится '
    'в одну строку.epub';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('importing card does not overflow at font scale $scale', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final h = await pumpLibrary(
        tester,
        picked: epubSource.copyWith(name: _longName),
      );

      await startImport(tester);
      h.imports.current.add(const ImportUpdate.progress(done: 1, total: 3));
      await settleImport(tester);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('cancel_import')), findsOneWidget);
    });
  }

  testWidgets('progress indicator has a semantics label', (tester) async {
    final h = await pumpLibrary(tester);
    await startImport(tester);
    h.imports.current.add(const ImportUpdate.progress(done: 1, total: 3));
    await settleImport(tester);

    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.semanticsLabel, 'Конвертация · 1 из 3');
  });
}
