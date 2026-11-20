import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/routing/app_routes.dart';

import 'package:fusionreflow/ui/library/widgets/book_card.dart';

import '../../../helpers/book_entry.dart';
import '../../../helpers/library_harness.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('untitled book shows placeholder title', (tester) async {
    await pumpLibrary(
      tester,
      books: [bookEntry(id: 'x', title: '')],
    );
    await tester.tap(find.byType(BookCard));
    await tester.pumpAndSettle();

    expect(find.text('Без названия'), findsWidgets);
  });

  testWidgets('unknown id shows not found', (tester) async {
    await pumpApp(tester, location: AppRoutes.readerOf('nope'));

    expect(find.byKey(const Key('reader_placeholder')), findsOneWidget);
    expect(find.text('Книга не найдена'), findsOneWidget);
  });
}
