import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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
    Locale('ko'),
  ];

  /// Temporary app name until the final name is decided
  ///
  /// In en, this message translates to:
  /// **'Screen Translate'**
  String get appTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get homeGreeting;

  /// Home title. homeHeadlineHighlight inside it is shown in the primary color.
  ///
  /// In en, this message translates to:
  /// **'Translate any screen'**
  String get homeHeadline;

  /// No description provided for @homeHeadlineHighlight.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get homeHeadlineHighlight;

  /// No description provided for @homeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeNotifications;

  /// No description provided for @homeServiceStopped.
  ///
  /// In en, this message translates to:
  /// **'Translation service is off'**
  String get homeServiceStopped;

  /// No description provided for @homeServiceHint.
  ///
  /// In en, this message translates to:
  /// **'When started, a translate button floats over other apps'**
  String get homeServiceHint;

  /// No description provided for @homeStart.
  ///
  /// In en, this message translates to:
  /// **'Start translating'**
  String get homeStart;

  /// No description provided for @homeStatusTargetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Target language'**
  String get homeStatusTargetLanguage;

  /// No description provided for @homeStatusEngine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get homeStatusEngine;

  /// No description provided for @homeStatusCaptureMode.
  ///
  /// In en, this message translates to:
  /// **'Capture mode'**
  String get homeStatusCaptureMode;

  /// No description provided for @homeCaptureModes.
  ///
  /// In en, this message translates to:
  /// **'Capture modes'**
  String get homeCaptureModes;

  /// No description provided for @captureModeFull.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get captureModeFull;

  /// No description provided for @captureModeRegion.
  ///
  /// In en, this message translates to:
  /// **'Select area'**
  String get captureModeRegion;

  /// No description provided for @captureModeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed area'**
  String get captureModeFixed;

  /// No description provided for @homeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homeRecent;

  /// No description provided for @homeRecentFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get homeRecentFilterAll;

  /// No description provided for @homeRecentFilterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeRecentFilterToday;

  /// No description provided for @homeRecentFilterWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get homeRecentFilterWeek;

  /// No description provided for @homeRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No translations yet'**
  String get homeRecentEmpty;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageKorean;

  /// No description provided for @engineMlKit.
  ///
  /// In en, this message translates to:
  /// **'On-device (ML Kit)'**
  String get engineMlKit;
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
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
