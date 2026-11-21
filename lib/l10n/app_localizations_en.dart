// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FusionReflow';

  @override
  String get spikeHyphenTitle => 'Soft hyphen spike';

  @override
  String spikeWidthLabel(int width) {
    return 'Width: $width px';
  }

  @override
  String get spikeJustify => 'Justify text';

  @override
  String get spikeOpenButton => 'Hyphenation spike (debug)';

  @override
  String get navLibrary => 'Library';

  @override
  String get navBookmarks => 'Bookmarks';

  @override
  String get navSettings => 'Settings';

  @override
  String get sectionComingSoon => 'Coming soon';

  @override
  String get startupErrorTitle => 'Couldn\'t start the app';

  @override
  String get startupErrorMessage => 'Please try again. Your books are safe.';

  @override
  String get startupRetry => 'Try again';

  @override
  String libraryBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books',
      one: '$count book',
    );
    return '$_temp0';
  }

  @override
  String get librarySortRecent => 'Recent';

  @override
  String get librarySortTitle => 'Title';

  @override
  String get librarySortAuthor => 'Author';

  @override
  String get libraryContinueReading => 'Continue reading';

  @override
  String get libraryRead => 'Read';

  @override
  String get libraryStatusNew => 'New';

  @override
  String get libraryStatusFinished => 'Finished';

  @override
  String libraryPercent(int percent) {
    return '$percent%';
  }

  @override
  String get libraryUntitled => 'Untitled';

  @override
  String get bookFormatPdf => 'PDF';

  @override
  String get bookFormatEpub => 'EPUB';

  @override
  String get bookFormatFb2 => 'FB2';

  @override
  String get bookFormatFb2Zip => 'FB2.ZIP';

  @override
  String get libraryEmptyTitle => 'No books yet';

  @override
  String get libraryEmptyMessage =>
      'Add an EPUB or FB2 file. Books are read on your device and never sent anywhere.';

  @override
  String get libraryEmptyHint => 'Tap “Add” in the bottom right';

  @override
  String get libraryEmptyFormats => 'EPUB · FB2 · FB2.ZIP';

  @override
  String get libraryAdd => 'Add';

  @override
  String get libraryAddSemantics => 'Add a book';

  @override
  String get libraryLoadError => 'Couldn’t load the library';

  @override
  String get libraryRetry => 'Retry';

  @override
  String get libraryDebugMenu => 'Debug';

  @override
  String get importBusy => 'Wait until the book is added';

  @override
  String importProgress(int done, int total) {
    return 'Converting · $done of $total';
  }

  @override
  String get importCancel => 'Cancel';

  @override
  String get importPdfLaterTitle => 'PDF will be available later';

  @override
  String get importPdfLaterMessage =>
      'PDF to book conversion is coming in a future update. EPUB and FB2 already open and read.';

  @override
  String importPdfLaterFile(String size) {
    return 'PDF · $size · not added to the library';
  }

  @override
  String get importPdfLaterFileNoSize => 'PDF · not added to the library';

  @override
  String get importPickEpubOrFb2 => 'Choose EPUB or FB2';

  @override
  String get importGotIt => 'Got it';

  @override
  String get importUnsupportedTitle => 'This format is not supported';

  @override
  String get importUnsupportedMessage =>
      'The app reads EPUB, FB2 and FB2.ZIP. PDF is coming later; DOCX and MOBI can be converted to EPUB.';

  @override
  String get importUnreadableTitle => 'Couldn’t open the file';

  @override
  String get importUnreadableMessage =>
      'The file is damaged or not fully downloaded. Download it again and add it once more.';

  @override
  String get importPickOther => 'Choose another file';

  @override
  String get importNoAccessTitle => 'No access to the file';

  @override
  String get importNoAccessMessage =>
      'The file was moved or deleted. Choose it again.';

  @override
  String get importPickFile => 'Choose file';

  @override
  String get importCancelledTitle => 'Adding cancelled';

  @override
  String get importCancelledMessage =>
      'The book was not saved. You can add it again.';

  @override
  String get importRetry => 'Retry';

  @override
  String get importClose => 'Close';

  @override
  String fileSizeMb(double size) {
    final intl.NumberFormat sizeNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 1,
        );
    final String sizeString = sizeNumberFormat.format(size);

    return '$sizeString MB';
  }

  @override
  String get readerOpenFailed => 'Couldn\'t open the book';

  @override
  String get readerBack => 'Back';

  @override
  String readerChapterOf(int index, int count) {
    return 'Chapter $index of $count';
  }

  @override
  String readerPageOf(int index, int count) {
    return '$index of $count';
  }

  @override
  String readerPercent(int percent) {
    return '$percent%';
  }

  @override
  String get readerSavePositionFailed => 'Couldn\'t save your reading position';

  @override
  String get readerBookNotFound => 'Book not found';

  @override
  String get importSheetTitle => 'Add a book';

  @override
  String get importSheetFormats => 'EPUB, FB2, FB2.ZIP';

  @override
  String get importSheetNote =>
      'The book is stored in the app; the original file isn\'t needed after adding.';

  @override
  String get importPickFailed => 'Couldn’t open the file picker';

  @override
  String get bookActionsTitle => 'Book actions';

  @override
  String get bookActionDetails => 'Book info';

  @override
  String get bookActionDelete => 'Delete book';

  @override
  String get bookActionClose => 'Close';

  @override
  String get bookDeleteTitle => 'Delete the book?';

  @override
  String bookDeleteMessage(String title) {
    return '“$title” will be removed from the library along with reading progress. The original file on your phone stays unchanged.';
  }

  @override
  String get bookDeleteCancel => 'Cancel';

  @override
  String get bookDeleteConfirm => 'Delete';

  @override
  String get bookDeleted => 'Book deleted';

  @override
  String get bookDeleteFailed => 'Couldn’t delete the book';

  @override
  String get bookBack => 'Back';

  @override
  String get bookNoAuthor => 'Author unknown';

  @override
  String get bookNotStarted => 'Not started';

  @override
  String bookReadPercent(int percent) {
    return '$percent% read';
  }

  @override
  String get bookFinished => 'Finished';

  @override
  String get bookStartReading => 'Start reading';

  @override
  String get bookContinueReading => 'Continue reading';

  @override
  String get bookAbout => 'About this book';

  @override
  String get bookReadMore => 'Read more';

  @override
  String get bookNoDescription => 'The file has no description.';

  @override
  String get bookDescriptionNote =>
      'Taken from the file’s metadata and shown as is.';

  @override
  String get bookDescriptionClose => 'Close';

  @override
  String get bookDetailsTitle => 'Details';

  @override
  String get bookDetailFormat => 'Format';

  @override
  String get bookDetailSize => 'File size';

  @override
  String get bookDetailLanguage => 'Language';

  @override
  String get bookDetailAdded => 'Added';

  @override
  String get bookLanguageUnknown => 'Unknown';
}
