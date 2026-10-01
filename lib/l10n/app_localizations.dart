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

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get commonOpenSettings;

  /// No description provided for @commonAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get commonAllowed;

  /// No description provided for @commonNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonNotAllowed;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// No description provided for @onboardingIntro1Title.
  ///
  /// In en, this message translates to:
  /// **'Translate what you see'**
  String get onboardingIntro1Title;

  /// No description provided for @onboardingIntro1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get onboardingIntro1Highlight;

  /// No description provided for @onboardingIntro1Body.
  ///
  /// In en, this message translates to:
  /// **'Games, comics, social feeds — even text you can\'t copy gets captured and translated.'**
  String get onboardingIntro1Body;

  /// No description provided for @onboardingIntro2Title.
  ///
  /// In en, this message translates to:
  /// **'One button is all it takes'**
  String get onboardingIntro2Title;

  /// No description provided for @onboardingIntro2Highlight.
  ///
  /// In en, this message translates to:
  /// **'button'**
  String get onboardingIntro2Highlight;

  /// No description provided for @onboardingIntro2Body.
  ///
  /// In en, this message translates to:
  /// **'Tap the button floating over any app to read and translate the text on screen.'**
  String get onboardingIntro2Body;

  /// No description provided for @onboardingIntro3Title.
  ///
  /// In en, this message translates to:
  /// **'Private, on your device'**
  String get onboardingIntro3Title;

  /// No description provided for @onboardingIntro3Highlight.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get onboardingIntro3Highlight;

  /// No description provided for @onboardingIntro3Body.
  ///
  /// In en, this message translates to:
  /// **'Basic translation runs on your device. Screenshots are never saved or sent.'**
  String get onboardingIntro3Body;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Which language should we translate into?'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingLanguageHighlight.
  ///
  /// In en, this message translates to:
  /// **'language'**
  String get onboardingLanguageHighlight;

  /// No description provided for @onboardingLanguageBody.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings.'**
  String get onboardingLanguageBody;

  /// No description provided for @languageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search languages'**
  String get languageSearchHint;

  /// No description provided for @languageOcrUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Can\'t read as source'**
  String get languageOcrUnsupported;

  /// No description provided for @languageEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching language'**
  String get languageEmpty;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Target language'**
  String get languagePickerTitle;

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Just two permissions'**
  String get permissionTitle;

  /// No description provided for @permissionHighlight.
  ///
  /// In en, this message translates to:
  /// **'permissions'**
  String get permissionHighlight;

  /// No description provided for @permissionBody.
  ///
  /// In en, this message translates to:
  /// **'Needed to show the translate button and let you know it\'s running.'**
  String get permissionBody;

  /// No description provided for @permissionOverlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Display over other apps'**
  String get permissionOverlayTitle;

  /// No description provided for @permissionOverlayBody.
  ///
  /// In en, this message translates to:
  /// **'Shows the translate button and results on top of any app.'**
  String get permissionOverlayBody;

  /// No description provided for @permissionNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permissionNotificationTitle;

  /// No description provided for @permissionNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Lets you know while the service is on, and lets you stop it from there.'**
  String get permissionNotificationBody;

  /// No description provided for @permissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permissionAllow;

  /// No description provided for @permissionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get permissionContinue;

  /// No description provided for @permissionPending.
  ///
  /// In en, this message translates to:
  /// **'Allow both to continue'**
  String get permissionPending;

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

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// No description provided for @homeServiceStopped.
  ///
  /// In en, this message translates to:
  /// **'Translation service is off'**
  String get homeServiceStopped;

  /// No description provided for @homeServiceRunning.
  ///
  /// In en, this message translates to:
  /// **'Translation service is on'**
  String get homeServiceRunning;

  /// No description provided for @homeServiceHint.
  ///
  /// In en, this message translates to:
  /// **'When started, a translate button floats over other apps'**
  String get homeServiceHint;

  /// No description provided for @homeServiceRunningHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the translate button in any app'**
  String get homeServiceRunningHint;

  /// No description provided for @homeStart.
  ///
  /// In en, this message translates to:
  /// **'Start translating'**
  String get homeStart;

  /// No description provided for @homeStop.
  ///
  /// In en, this message translates to:
  /// **'Stop translating'**
  String get homeStop;

  /// No description provided for @homeStatusOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get homeStatusOff;

  /// No description provided for @homeStatusOn.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get homeStatusOn;

  /// No description provided for @homeStarting.
  ///
  /// In en, this message translates to:
  /// **'Reopen consent prompt'**
  String get homeStarting;

  /// No description provided for @homeStatusStarting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get homeStatusStarting;

  /// No description provided for @homeStatusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get homeStatusError;

  /// No description provided for @homeServiceStartingHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Start now\" on the screen capture prompt'**
  String get homeServiceStartingHint;

  /// No description provided for @homeServiceErrorHint.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start. Please try again'**
  String get homeServiceErrorHint;

  /// No description provided for @homePermissionsNeeded.
  ///
  /// In en, this message translates to:
  /// **'Allow permissions to start'**
  String get homePermissionsNeeded;

  /// No description provided for @homeSourceAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect'**
  String get homeSourceAuto;

  /// No description provided for @homeSectionSetup.
  ///
  /// In en, this message translates to:
  /// **'Translation setup'**
  String get homeSectionSetup;

  /// No description provided for @homeTargetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Target language'**
  String get homeTargetLanguage;

  /// No description provided for @homeModels.
  ///
  /// In en, this message translates to:
  /// **'Language models'**
  String get homeModels;

  /// No description provided for @homeModelsReady.
  ///
  /// In en, this message translates to:
  /// **'{count} ready'**
  String homeModelsReady(int count);

  /// No description provided for @homeModelsDownloading.
  ///
  /// In en, this message translates to:
  /// **'{count} downloading'**
  String homeModelsDownloading(int count);

  /// No description provided for @homeEngine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get homeEngine;

  /// No description provided for @homeAreaHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press the floating button to change the capture area'**
  String get homeAreaHint;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get navLanguages;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @languagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languagesTitle;

  /// No description provided for @languagesSectionTarget.
  ///
  /// In en, this message translates to:
  /// **'Translate into'**
  String get languagesSectionTarget;

  /// No description provided for @languagesSectionDownload.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get languagesSectionDownload;

  /// No description provided for @homeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homeRecent;

  /// No description provided for @homeRecentSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeRecentSeeAll;

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

  /// No description provided for @engineMlKit.
  ///
  /// In en, this message translates to:
  /// **'On-device'**
  String get engineMlKit;

  /// No description provided for @engineMlKitDetail.
  ///
  /// In en, this message translates to:
  /// **'ML Kit · offline · free'**
  String get engineMlKitDetail;

  /// No description provided for @engineGemini.
  ///
  /// In en, this message translates to:
  /// **'My Gemini key'**
  String get engineGemini;

  /// No description provided for @engineGeminiDetail.
  ///
  /// In en, this message translates to:
  /// **'More natural AI translation · API key needed'**
  String get engineGeminiDetail;

  /// No description provided for @engineFirebase.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in AI'**
  String get engineFirebase;

  /// No description provided for @engineFirebaseDetail.
  ///
  /// In en, this message translates to:
  /// **'AI translation with just a sign-in'**
  String get engineFirebaseDetail;

  /// No description provided for @engineNeedsKey.
  ///
  /// In en, this message translates to:
  /// **'Add an API key to use this'**
  String get engineNeedsKey;

  /// No description provided for @engineNeedsLogin.
  ///
  /// In en, this message translates to:
  /// **'Requires Google sign-in and age check'**
  String get engineNeedsLogin;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get settingsSectionTranslation;

  /// No description provided for @settingsTargetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Target language'**
  String get settingsTargetLanguage;

  /// No description provided for @settingsLanguageModels.
  ///
  /// In en, this message translates to:
  /// **'Language models'**
  String get settingsLanguageModels;

  /// No description provided for @settingsLanguageModelsDetail.
  ///
  /// In en, this message translates to:
  /// **'Language files for on-device translation'**
  String get settingsLanguageModelsDetail;

  /// No description provided for @settingsSectionEngine.
  ///
  /// In en, this message translates to:
  /// **'Translation engine'**
  String get settingsSectionEngine;

  /// No description provided for @settingsAiSetup.
  ///
  /// In en, this message translates to:
  /// **'AI translation setup'**
  String get settingsAiSetup;

  /// No description provided for @settingsAiSetupDetail.
  ///
  /// In en, this message translates to:
  /// **'API key · Google sign-in'**
  String get settingsAiSetupDetail;

  /// No description provided for @settingsSectionCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get settingsSectionCapture;

  /// No description provided for @settingsDefaultCaptureMode.
  ///
  /// In en, this message translates to:
  /// **'Default capture mode'**
  String get settingsDefaultCaptureMode;

  /// No description provided for @settingsResetFixedRegion.
  ///
  /// In en, this message translates to:
  /// **'Reset fixed area'**
  String get settingsResetFixedRegion;

  /// No description provided for @settingsSectionDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsSectionDisplay;

  /// No description provided for @settingsDisplayMode.
  ///
  /// In en, this message translates to:
  /// **'Show results as'**
  String get settingsDisplayMode;

  /// No description provided for @displayModeList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get displayModeList;

  /// No description provided for @displayModeParagraph.
  ///
  /// In en, this message translates to:
  /// **'Paragraph'**
  String get displayModeParagraph;

  /// No description provided for @displayModeOverlay.
  ///
  /// In en, this message translates to:
  /// **'Over original'**
  String get displayModeOverlay;

  /// No description provided for @settingsButtonSize.
  ///
  /// In en, this message translates to:
  /// **'Floating button size'**
  String get settingsButtonSize;

  /// No description provided for @settingsButtonOpacity.
  ///
  /// In en, this message translates to:
  /// **'Floating button opacity'**
  String get settingsButtonOpacity;

  /// No description provided for @settingsQuickLanguages.
  ///
  /// In en, this message translates to:
  /// **'Quick languages'**
  String get settingsQuickLanguages;

  /// No description provided for @settingsQuickLanguagesDetail.
  ///
  /// In en, this message translates to:
  /// **'Languages shown in the floating button\'s long-press menu'**
  String get settingsQuickLanguagesDetail;

  /// No description provided for @quickLanguagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit quick languages'**
  String get quickLanguagesTitle;

  /// No description provided for @quickLanguagesHint.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max} selected, at least {min}. Tap to toggle.'**
  String quickLanguagesHint(int count, int max, int min);

  /// No description provided for @settingsSectionAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto translate'**
  String get settingsSectionAuto;

  /// No description provided for @settingsAutoTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate automatically when the screen changes'**
  String get settingsAutoTranslate;

  /// No description provided for @settingsAutoTranslateDetail.
  ///
  /// In en, this message translates to:
  /// **'After a translation, lightly watches the screen and translates again when the text changes or scrolling stops. Leaving it on uses more battery and may warm the device.'**
  String get settingsAutoTranslateDetail;

  /// No description provided for @settingsAutoSpeed.
  ///
  /// In en, this message translates to:
  /// **'Re-translate speed (slower saves battery)'**
  String get settingsAutoSpeed;

  /// No description provided for @autoSpeedFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get autoSpeedFast;

  /// No description provided for @autoSpeedNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get autoSpeedNormal;

  /// No description provided for @autoSpeedSaver.
  ///
  /// In en, this message translates to:
  /// **'Saver'**
  String get autoSpeedSaver;

  /// No description provided for @autoSpeedBatterySaver.
  ///
  /// In en, this message translates to:
  /// **'Max saver'**
  String get autoSpeedBatterySaver;

  /// No description provided for @settingsAutoHide.
  ///
  /// In en, this message translates to:
  /// **'Hide the old translation after the screen changes'**
  String get settingsAutoHide;

  /// No description provided for @settingsAutoInstant.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get settingsAutoInstant;

  /// No description provided for @settingsAutoNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get settingsAutoNever;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{value}s'**
  String secondsShort(String value);

  /// No description provided for @settingsSectionEtc.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get settingsSectionEtc;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @modelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Language models'**
  String get modelsTitle;

  /// No description provided for @modelsHeadline.
  ///
  /// In en, this message translates to:
  /// **'On-device languages'**
  String get modelsHeadline;

  /// No description provided for @modelsHighlight.
  ///
  /// In en, this message translates to:
  /// **'On-device'**
  String get modelsHighlight;

  /// No description provided for @modelsBody.
  ///
  /// In en, this message translates to:
  /// **'About 30MB per language. Once downloaded, translation works offline.'**
  String get modelsBody;

  /// No description provided for @modelsWifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Download on Wi-Fi only'**
  String get modelsWifiOnly;

  /// No description provided for @modelsWifiOnlyDetail.
  ///
  /// In en, this message translates to:
  /// **'Won\'t use mobile data'**
  String get modelsWifiOnlyDetail;

  /// No description provided for @modelsInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get modelsInstalled;

  /// No description provided for @modelsNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded'**
  String get modelsNotInstalled;

  /// No description provided for @modelsDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading {percent}%'**
  String modelsDownloading(int percent);

  /// No description provided for @modelsSize.
  ///
  /// In en, this message translates to:
  /// **'About {size}MB'**
  String modelsSize(int size);

  /// No description provided for @modelsDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get modelsDownload;

  /// No description provided for @modelsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get modelsDelete;

  /// No description provided for @modelsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get modelsCancel;

  /// No description provided for @modelsSectionInstalled.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get modelsSectionInstalled;

  /// No description provided for @modelsSectionAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get modelsSectionAvailable;

  /// No description provided for @modelsTargetOnly.
  ///
  /// In en, this message translates to:
  /// **'Target only'**
  String get modelsTargetOnly;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get aboutPrivacy;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutPending.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get aboutPending;
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
