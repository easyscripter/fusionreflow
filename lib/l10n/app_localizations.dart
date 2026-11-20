import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// Application name shown in the app bar and task switcher.
  ///
  /// In en, this message translates to:
  /// **'FusionReflow'**
  String get appTitle;

  /// Title of the debug-only hyphenation spike screen.
  ///
  /// In en, this message translates to:
  /// **'Soft hyphen spike'**
  String get spikeHyphenTitle;

  /// Label of the width slider on the debug spike screen.
  ///
  /// In en, this message translates to:
  /// **'Width: {width} px'**
  String spikeWidthLabel(int width);

  /// No description provided for @spikeJustify.
  ///
  /// In en, this message translates to:
  /// **'Justify text'**
  String get spikeJustify;

  /// No description provided for @spikeOpenButton.
  ///
  /// In en, this message translates to:
  /// **'Hyphenation spike (debug)'**
  String get spikeOpenButton;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get navBookmarks;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @sectionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get sectionComingSoon;

  /// No description provided for @startupErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the app'**
  String get startupErrorTitle;

  /// No description provided for @startupErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please try again. Your books are safe.'**
  String get startupErrorMessage;

  /// No description provided for @startupRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get startupRetry;

  /// Book counter in the library header.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} book} other{{count} books}}'**
  String libraryBookCount(int count);

  /// No description provided for @librarySortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get librarySortRecent;

  /// No description provided for @librarySortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get librarySortTitle;

  /// No description provided for @librarySortAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get librarySortAuthor;

  /// No description provided for @libraryContinueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get libraryContinueReading;

  /// No description provided for @libraryRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get libraryRead;

  /// No description provided for @libraryStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get libraryStatusNew;

  /// No description provided for @libraryStatusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get libraryStatusFinished;

  /// No description provided for @libraryPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String libraryPercent(int percent);

  /// Shown instead of an empty book title.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get libraryUntitled;

  /// No description provided for @bookFormatPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get bookFormatPdf;

  /// No description provided for @bookFormatEpub.
  ///
  /// In en, this message translates to:
  /// **'EPUB'**
  String get bookFormatEpub;

  /// No description provided for @bookFormatFb2.
  ///
  /// In en, this message translates to:
  /// **'FB2'**
  String get bookFormatFb2;

  /// No description provided for @bookFormatFb2Zip.
  ///
  /// In en, this message translates to:
  /// **'FB2.ZIP'**
  String get bookFormatFb2Zip;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No books yet'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add an EPUB or FB2 file. Books are read on your device and never sent anywhere.'**
  String get libraryEmptyMessage;

  /// No description provided for @libraryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap “Add” in the bottom right'**
  String get libraryEmptyHint;

  /// No description provided for @libraryEmptyFormats.
  ///
  /// In en, this message translates to:
  /// **'EPUB · FB2 · FB2.ZIP'**
  String get libraryEmptyFormats;

  /// No description provided for @libraryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get libraryAdd;

  /// No description provided for @libraryAddSemantics.
  ///
  /// In en, this message translates to:
  /// **'Add a book'**
  String get libraryAddSemantics;

  /// No description provided for @libraryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load the library'**
  String get libraryLoadError;

  /// No description provided for @libraryRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get libraryRetry;

  /// No description provided for @libraryDebugMenu.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get libraryDebugMenu;

  /// No description provided for @importBusy.
  ///
  /// In en, this message translates to:
  /// **'Wait until the book is added'**
  String get importBusy;

  /// No description provided for @importProgress.
  ///
  /// In en, this message translates to:
  /// **'Converting · {done} of {total}'**
  String importProgress(int done, int total);

  /// No description provided for @importCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get importCancel;

  /// No description provided for @importPdfLaterTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF will be available later'**
  String get importPdfLaterTitle;

  /// No description provided for @importPdfLaterMessage.
  ///
  /// In en, this message translates to:
  /// **'PDF to book conversion is coming in a future update. EPUB and FB2 already open and read.'**
  String get importPdfLaterMessage;

  /// Skipped PDF: size and a note that it was not added.
  ///
  /// In en, this message translates to:
  /// **'PDF · {size} · not added to the library'**
  String importPdfLaterFile(String size);

  /// No description provided for @importPdfLaterFileNoSize.
  ///
  /// In en, this message translates to:
  /// **'PDF · not added to the library'**
  String get importPdfLaterFileNoSize;

  /// No description provided for @importPickEpubOrFb2.
  ///
  /// In en, this message translates to:
  /// **'Choose EPUB or FB2'**
  String get importPickEpubOrFb2;

  /// No description provided for @importGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get importGotIt;

  /// No description provided for @importUnsupportedTitle.
  ///
  /// In en, this message translates to:
  /// **'This format is not supported'**
  String get importUnsupportedTitle;

  /// No description provided for @importUnsupportedMessage.
  ///
  /// In en, this message translates to:
  /// **'The app reads EPUB, FB2 and FB2.ZIP. PDF is coming later; DOCX and MOBI can be converted to EPUB.'**
  String get importUnsupportedMessage;

  /// No description provided for @importUnreadableTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the file'**
  String get importUnreadableTitle;

  /// No description provided for @importUnreadableMessage.
  ///
  /// In en, this message translates to:
  /// **'The file is damaged or not fully downloaded. Download it again and add it once more.'**
  String get importUnreadableMessage;

  /// No description provided for @importPickOther.
  ///
  /// In en, this message translates to:
  /// **'Choose another file'**
  String get importPickOther;

  /// No description provided for @importNoAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'No access to the file'**
  String get importNoAccessTitle;

  /// No description provided for @importNoAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'The file was moved or deleted. Choose it again.'**
  String get importNoAccessMessage;

  /// No description provided for @importPickFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get importPickFile;

  /// No description provided for @importCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Adding cancelled'**
  String get importCancelledTitle;

  /// No description provided for @importCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'The book was not saved. You can add it again.'**
  String get importCancelledMessage;

  /// No description provided for @importRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get importRetry;

  /// No description provided for @importClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get importClose;

  /// File size in mebibytes, one decimal digit.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String fileSizeMb(double size);

  /// No description provided for @readerPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'The reader is coming later'**
  String get readerPlaceholderTitle;

  /// No description provided for @readerPlaceholderPosition.
  ///
  /// In en, this message translates to:
  /// **'Opens at {percent}%'**
  String readerPlaceholderPosition(int percent);

  /// No description provided for @readerBookNotFound.
  ///
  /// In en, this message translates to:
  /// **'Book not found'**
  String get readerBookNotFound;

  /// No description provided for @importSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a book'**
  String get importSheetTitle;

  /// No description provided for @importSheetFormats.
  ///
  /// In en, this message translates to:
  /// **'EPUB, FB2, FB2.ZIP'**
  String get importSheetFormats;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
