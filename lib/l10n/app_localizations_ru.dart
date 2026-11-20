// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'FusionReflow';

  @override
  String get spikeHyphenTitle => 'Проверка мягкого переноса';

  @override
  String spikeWidthLabel(int width) {
    return 'Ширина: $width px';
  }

  @override
  String get spikeJustify => 'Выравнивание по ширине';

  @override
  String get spikeOpenButton => 'Проверка переноса (debug)';

  @override
  String get navLibrary => 'Библиотека';

  @override
  String get navBookmarks => 'Закладки';

  @override
  String get navSettings => 'Настройки';

  @override
  String get sectionComingSoon => 'Раздел появится позже';

  @override
  String get startupErrorTitle => 'Не удалось запустить приложение';

  @override
  String get startupErrorMessage => 'Попробуйте ещё раз. Ваши книги на месте.';

  @override
  String get startupRetry => 'Повторить';
}
