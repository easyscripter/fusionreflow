import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/language_label.dart';

Future<String?> _label(WidgetTester tester, Locale locale, String? tag) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        LocaleNamesLocalizationsDelegate(),
      ],
      home: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox();
        },
      ),
    ),
  );
  // The CLDR data comes from an asset: real I/O, outside the fake clock.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pumpAndSettle();
  return languageLabel(captured, tag);
}

void main() {
  testWidgets('names known tags', (tester) async {
    const ru = Locale('ru');
    expect(await _label(tester, ru, 'ru'), 'Русский');
    expect(await _label(tester, ru, 'en'), 'Английский');
    expect(await _label(tester, ru, 'EN'), 'Английский');
    expect(await _label(tester, const Locale('en'), 'ru'), 'Russian');
    expect(await _label(tester, ru, 'qq-ZZ'), 'qq-ZZ');
    expect(await _label(tester, ru, null), isNull);
    expect(await _label(tester, ru, ''), isNull);
  });
}
