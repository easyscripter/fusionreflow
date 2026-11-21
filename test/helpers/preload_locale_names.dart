import 'package:flutter/widgets.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the language names (CLDR) of [locales] in real time.
///
/// They come from an asset, and the fake clock of a widget test does not wait
/// for file I/O. `rootBundle` caches the result, so the delegate inside the
/// pumped app then finishes within `pumpAndSettle`.
Future<void> preloadLocaleNames(
  WidgetTester tester, [
  List<Locale> locales = const [Locale('ru'), Locale('en')],
]) async {
  await tester.runAsync(() async {
    for (final locale in locales) {
      await const LocaleNamesLocalizationsDelegate().load(locale);
    }
  });
}
