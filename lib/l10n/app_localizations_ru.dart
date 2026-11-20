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

  @override
  String libraryBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count книги',
      many: '$count книг',
      few: '$count книги',
      one: '$count книга',
    );
    return '$_temp0';
  }

  @override
  String get librarySortRecent => 'Недавние';

  @override
  String get librarySortTitle => 'Название';

  @override
  String get librarySortAuthor => 'Автор';

  @override
  String get libraryContinueReading => 'Продолжить чтение';

  @override
  String get libraryRead => 'Читать';

  @override
  String get libraryStatusNew => 'Новая';

  @override
  String get libraryStatusFinished => 'Прочитана';

  @override
  String libraryPercent(int percent) {
    return '$percent%';
  }

  @override
  String get libraryUntitled => 'Без названия';

  @override
  String get bookFormatPdf => 'PDF';

  @override
  String get bookFormatEpub => 'EPUB';

  @override
  String get bookFormatFb2 => 'FB2';

  @override
  String get bookFormatFb2Zip => 'FB2.ZIP';

  @override
  String get libraryEmptyTitle => 'Здесь пока нет книг';

  @override
  String get libraryEmptyMessage =>
      'Добавьте файл EPUB или FB2. Книги читаются на устройстве и никуда не отправляются.';

  @override
  String get libraryEmptyHint => 'Нажмите «Добавить» внизу справа';

  @override
  String get libraryEmptyFormats => 'EPUB · FB2 · FB2.ZIP';

  @override
  String get libraryAdd => 'Добавить';

  @override
  String get libraryAddSemantics => 'Добавить книгу';

  @override
  String get libraryLoadError => 'Не удалось загрузить библиотеку';

  @override
  String get libraryRetry => 'Повторить';

  @override
  String get libraryDebugMenu => 'Отладка';

  @override
  String get importBusy => 'Дождитесь окончания добавления книги';

  @override
  String importProgress(int done, int total) {
    return 'Конвертация · $done из $total';
  }

  @override
  String get importCancel => 'Отменить';

  @override
  String get importPdfLaterTitle => 'PDF будет доступен позже';

  @override
  String get importPdfLaterMessage =>
      'Конвертация PDF в книгу появится в одном из следующих обновлений. EPUB и FB2 уже открываются и читаются.';

  @override
  String importPdfLaterFile(String size) {
    return 'PDF · $size · в библиотеку не добавлен';
  }

  @override
  String get importPdfLaterFileNoSize => 'PDF · в библиотеку не добавлен';

  @override
  String get importPickEpubOrFb2 => 'Выбрать EPUB или FB2';

  @override
  String get importGotIt => 'Понятно';

  @override
  String get importUnsupportedTitle => 'Этот формат не поддерживается';

  @override
  String get importUnsupportedMessage =>
      'Приложение читает EPUB, FB2 и FB2.ZIP. PDF появится позже, DOCX и MOBI можно перевести в EPUB.';

  @override
  String get importUnreadableTitle => 'Не удалось открыть файл';

  @override
  String get importUnreadableMessage =>
      'Файл повреждён или скачан не до конца. Скачайте его заново и добавьте ещё раз.';

  @override
  String get importPickOther => 'Выбрать другой файл';

  @override
  String get importNoAccessTitle => 'Нет доступа к файлу';

  @override
  String get importNoAccessMessage =>
      'Файл перенесён или удалён. Выберите его заново.';

  @override
  String get importPickFile => 'Выбрать файл';

  @override
  String get importCancelledTitle => 'Добавление отменено';

  @override
  String get importCancelledMessage =>
      'Книга не сохранена. Её можно добавить снова.';

  @override
  String get importRetry => 'Повторить';

  @override
  String get importClose => 'Закрыть';

  @override
  String fileSizeMb(double size) {
    final intl.NumberFormat sizeNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 1,
        );
    final String sizeString = sizeNumberFormat.format(size);

    return '$sizeString МБ';
  }

  @override
  String get readerPlaceholderTitle => 'Читалка появится позже';

  @override
  String readerPlaceholderPosition(int percent) {
    return 'Откроется на $percent%';
  }

  @override
  String get readerBookNotFound => 'Книга не найдена';
}
