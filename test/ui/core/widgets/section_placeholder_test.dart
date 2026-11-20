import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/widgets/section_placeholder.dart';

Widget _host(Widget child, Size size) => MaterialApp(
  locale: const Locale('ru'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: MediaQuery(
    data: MediaQueryData(size: size),
    child: child,
  ),
);

void main() {
  testWidgets('shows title and coming soon', (tester) async {
    await tester.pumpWidget(
      _host(const SectionPlaceholder(title: 'X'), const Size(390, 844)),
    );

    expect(find.text('X'), findsOneWidget);
    expect(find.text('Раздел появится позже'), findsOneWidget);
  });

  testWidgets('shows footer when given', (tester) async {
    await tester.pumpWidget(
      _host(
        const SectionPlaceholder(title: 'X', footer: Text('foot')),
        const Size(820, 1180),
      ),
    );

    expect(find.text('foot'), findsOneWidget);
  });
}
