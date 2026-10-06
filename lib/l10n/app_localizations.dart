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

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search original or translation'**
  String get historySearchHint;

  /// No description provided for @historyNoResult.
  ///
  /// In en, this message translates to:
  /// **'No matching translations'**
  String get historyNoResult;

  /// No description provided for @historyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get historyDelete;

  /// No description provided for @historyClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get historyClearAll;

  /// No description provided for @historyClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all?'**
  String get historyClearConfirm;

  /// No description provided for @historyDetailTranslated.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get historyDetailTranslated;

  /// No description provided for @historyDetailOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get historyDetailOriginal;

  /// No description provided for @historyCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get historyCopy;

  /// No description provided for @historyCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get historyCopied;

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

  /// No description provided for @engineNeedsKey.
  ///
  /// In en, this message translates to:
  /// **'Add an API key to use this'**
  String get engineNeedsKey;

  /// No description provided for @engineNeedsAge.
  ///
  /// In en, this message translates to:
  /// **'Confirm you are 18 or older in AI translation setup'**
  String get engineNeedsAge;

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
  /// **'Gemini API key'**
  String get settingsAiSetupDetail;

  /// No description provided for @apiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'AI translation setup'**
  String get apiKeyTitle;

  /// No description provided for @apiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your Gemini API key'**
  String get apiKeyHint;

  /// No description provided for @apiKeyIntro.
  ///
  /// In en, this message translates to:
  /// **'Get your own key from Google AI Studio and paste it here. It is encrypted and stored only on this device. Translated text is sent to Google; if anything fails, ML Kit takes over.'**
  String get apiKeyIntro;

  /// No description provided for @apiKeySave.
  ///
  /// In en, this message translates to:
  /// **'Save key'**
  String get apiKeySave;

  /// No description provided for @apiKeyRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove key'**
  String get apiKeyRemove;

  /// No description provided for @apiKeyRegistered.
  ///
  /// In en, this message translates to:
  /// **'A key is registered'**
  String get apiKeyRegistered;

  /// No description provided for @apiKeyShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get apiKeyShow;

  /// No description provided for @apiKeyHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get apiKeyHide;

  /// No description provided for @apiKeyTest.
  ///
  /// In en, this message translates to:
  /// **'Test key'**
  String get apiKeyTest;

  /// No description provided for @apiKeyTestOk.
  ///
  /// In en, this message translates to:
  /// **'The key works'**
  String get apiKeyTestOk;

  /// No description provided for @apiKeyTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Rejected: {reason}'**
  String apiKeyTestFailed(String reason);

  /// No description provided for @apiKeyGet.
  ///
  /// In en, this message translates to:
  /// **'Get a key from Google AI Studio'**
  String get apiKeyGet;

  /// No description provided for @apiKeyPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Key PIN lock'**
  String get apiKeyPinTitle;

  /// No description provided for @apiKeyPinDetail.
  ///
  /// In en, this message translates to:
  /// **'Ask for a 4-digit PIN before viewing, editing or deleting the key'**
  String get apiKeyPinDetail;

  /// No description provided for @apiKeyPinChange.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get apiKeyPinChange;

  /// No description provided for @apiKeyLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'API key is locked'**
  String get apiKeyLockedTitle;

  /// No description provided for @apiKeyLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to view or edit the key.'**
  String get apiKeyLockedBody;

  /// No description provided for @apiKeyUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get apiKeyUnlock;

  /// No description provided for @apiKeyPinForgot.
  ///
  /// In en, this message translates to:
  /// **'I forgot my PIN'**
  String get apiKeyPinForgot;

  /// No description provided for @pinEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get pinEnterTitle;

  /// No description provided for @pinEnterBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your 4-digit PIN.'**
  String get pinEnterBody;

  /// No description provided for @pinCurrentTitle.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get pinCurrentTitle;

  /// No description provided for @pinNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new PIN'**
  String get pinNewTitle;

  /// No description provided for @pinNewBody.
  ///
  /// In en, this message translates to:
  /// **'4 digits to lock the key.'**
  String get pinNewBody;

  /// No description provided for @pinConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN again'**
  String get pinConfirmTitle;

  /// No description provided for @pinWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get pinWrong;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t match the first PIN'**
  String get pinMismatch;

  /// No description provided for @pinResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the key and reset?'**
  String get pinResetTitle;

  /// No description provided for @pinResetBody.
  ///
  /// In en, this message translates to:
  /// **'If you forgot the PIN, the saved API key and the PIN are deleted. You\'ll need to add the key again, and the AI engine goes back to ML Kit.'**
  String get pinResetBody;

  /// No description provided for @pinResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete key and reset'**
  String get pinResetConfirm;

  /// No description provided for @pinCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pinCancel;

  /// No description provided for @aiAgeTitle.
  ///
  /// In en, this message translates to:
  /// **'I am 18 or older'**
  String get aiAgeTitle;

  /// No description provided for @aiAgeDetail.
  ///
  /// In en, this message translates to:
  /// **'Under the Gemini API terms, AI translation is only for people 18 or older. Confirm to turn it on.'**
  String get aiAgeDetail;

  /// No description provided for @aiNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'About data sent'**
  String get aiNoticeTitle;

  /// No description provided for @aiNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'When AI translation is on, the text read from your screen is sent to the AI provider you chose (Google Gemini). On the free tier, Google may use it to improve and review its services. Don\'t translate screens that show passwords or personal information.'**
  String get aiNoticeBody;

  /// No description provided for @aiOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Translation options'**
  String get aiOptionsTitle;

  /// No description provided for @aiToneTitle.
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get aiToneTitle;

  /// No description provided for @aiToneHint.
  ///
  /// In en, this message translates to:
  /// **'Applies to AI translation only. Works best when the target language has formal and casual speech.'**
  String get aiToneHint;

  /// No description provided for @aiToneStandard.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get aiToneStandard;

  /// No description provided for @aiToneFormal.
  ///
  /// In en, this message translates to:
  /// **'Formal'**
  String get aiToneFormal;

  /// No description provided for @aiToneInformal.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get aiToneInformal;

  /// No description provided for @aiGlossaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Glossary'**
  String get aiGlossaryTitle;

  /// No description provided for @aiGlossaryDetail.
  ///
  /// In en, this message translates to:
  /// **'Always translates a term the way you set it. Only terms found in the text are sent to the AI.'**
  String get aiGlossaryDetail;

  /// No description provided for @aiGlossarySourceHint.
  ///
  /// In en, this message translates to:
  /// **'Original (e.g. Mana)'**
  String get aiGlossarySourceHint;

  /// No description provided for @aiGlossaryTargetHint.
  ///
  /// In en, this message translates to:
  /// **'Translation (e.g. 마나)'**
  String get aiGlossaryTargetHint;

  /// No description provided for @aiGlossaryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add term'**
  String get aiGlossaryAdd;

  /// No description provided for @aiGlossaryRemove.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get aiGlossaryRemove;

  /// No description provided for @aiGlossaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No terms yet'**
  String get aiGlossaryEmpty;

  /// No description provided for @aiGlossaryFull.
  ///
  /// In en, this message translates to:
  /// **'You can add up to {max} terms'**
  String aiGlossaryFull(int max);

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

  /// No description provided for @settingsResetFixedRegionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No fixed area saved'**
  String get settingsResetFixedRegionEmpty;

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
  /// **'After a translation, lightly watches the screen and starts translating as soon as the text changes or scrolling stops. Unchanged text is skipped. Leaving it on uses more battery and may warm the device.'**
  String get settingsAutoTranslateDetail;

  /// No description provided for @settingsAutoTranslateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Only available when results are shown over the text and the capture area is full screen or a fixed area.'**
  String get settingsAutoTranslateUnavailable;

  /// No description provided for @settingsHideOverlayOnly.
  ///
  /// In en, this message translates to:
  /// **'Over-text display only'**
  String get settingsHideOverlayOnly;

  /// No description provided for @settingsAutoShowDelay.
  ///
  /// In en, this message translates to:
  /// **'Show the new translation (after you stop)'**
  String get settingsAutoShowDelay;

  /// No description provided for @settingsHideAfterInteraction.
  ///
  /// In en, this message translates to:
  /// **'Close the result after you touch the screen'**
  String get settingsHideAfterInteraction;

  /// No description provided for @settingsAutoInstant.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get settingsAutoInstant;

  /// No description provided for @settingsAutoNever.
  ///
  /// In en, this message translates to:
  /// **'Close manually'**
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
  /// **'Downloading'**
  String get modelsDownloading;

  /// No description provided for @modelsDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check your connection'**
  String get modelsDownloadFailed;

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

  /// No description provided for @vocabTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabTitle;

  /// No description provided for @vocabHomeHint.
  ///
  /// In en, this message translates to:
  /// **'Browse the words you saved'**
  String get vocabHomeHint;

  /// No description provided for @vocabEmpty.
  ///
  /// In en, this message translates to:
  /// **'No word lists yet'**
  String get vocabEmpty;

  /// No description provided for @vocabEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Create one to save words while you translate'**
  String get vocabEmptyHint;

  /// No description provided for @vocabNewBook.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get vocabNewBook;

  /// No description provided for @vocabNameHint.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get vocabNameHint;

  /// No description provided for @vocabCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get vocabCreate;

  /// No description provided for @vocabRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get vocabRename;

  /// No description provided for @vocabDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get vocabDelete;

  /// No description provided for @vocabCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get vocabCancel;

  /// No description provided for @vocabSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get vocabSave;

  /// No description provided for @vocabNameTaken.
  ///
  /// In en, this message translates to:
  /// **'A list with this name already exists'**
  String get vocabNameTaken;

  /// No description provided for @vocabWordCount.
  ///
  /// In en, this message translates to:
  /// **'Words: {count}'**
  String vocabWordCount(int count);

  /// No description provided for @vocabMemorizedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} memorized'**
  String vocabMemorizedCount(int count);

  /// No description provided for @vocabDeleteBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String vocabDeleteBookTitle(String name);

  /// No description provided for @vocabDeleteBookBody.
  ///
  /// In en, this message translates to:
  /// **'Words inside will be deleted too ({count}).'**
  String vocabDeleteBookBody(int count);

  /// No description provided for @vocabSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search words or meanings'**
  String get vocabSearchHint;

  /// No description provided for @vocabSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get vocabSortNewest;

  /// No description provided for @vocabSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get vocabSortOldest;

  /// No description provided for @vocabSortAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'A–Z'**
  String get vocabSortAlphabetical;

  /// No description provided for @vocabNoWords.
  ///
  /// In en, this message translates to:
  /// **'This list is empty'**
  String get vocabNoWords;

  /// No description provided for @vocabNoResult.
  ///
  /// In en, this message translates to:
  /// **'No matching words'**
  String get vocabNoResult;

  /// No description provided for @vocabMove.
  ///
  /// In en, this message translates to:
  /// **'Move to another list'**
  String get vocabMove;

  /// No description provided for @vocabMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get vocabMoveTitle;

  /// No description provided for @vocabMoveNoOther.
  ///
  /// In en, this message translates to:
  /// **'There is no other list to move to'**
  String get vocabMoveNoOther;

  /// No description provided for @vocabMemorizedLabel.
  ///
  /// In en, this message translates to:
  /// **'Memorized'**
  String get vocabMemorizedLabel;

  /// No description provided for @vocabWordDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get vocabWordDetailTitle;

  /// No description provided for @vocabMeaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get vocabMeaning;

  /// No description provided for @vocabPronunciation.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get vocabPronunciation;

  /// No description provided for @vocabPartOfSpeech.
  ///
  /// In en, this message translates to:
  /// **'Part of speech'**
  String get vocabPartOfSpeech;

  /// No description provided for @vocabContextMeaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning in context'**
  String get vocabContextMeaning;

  /// No description provided for @vocabSentence.
  ///
  /// In en, this message translates to:
  /// **'Example from the screen'**
  String get vocabSentence;

  /// No description provided for @vocabSourceApp.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get vocabSourceApp;

  /// No description provided for @vocabSavedAt.
  ///
  /// In en, this message translates to:
  /// **'Saved on'**
  String get vocabSavedAt;

  /// No description provided for @vocabDeleteWord.
  ///
  /// In en, this message translates to:
  /// **'Delete word'**
  String get vocabDeleteWord;

  /// No description provided for @vocabDeleteWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this word?'**
  String get vocabDeleteWordTitle;

  /// No description provided for @vocabWordGone.
  ///
  /// In en, this message translates to:
  /// **'This word was already deleted'**
  String get vocabWordGone;

  /// No description provided for @vocabAddWord.
  ///
  /// In en, this message translates to:
  /// **'Add word'**
  String get vocabAddWord;

  /// No description provided for @vocabAddToBook.
  ///
  /// In en, this message translates to:
  /// **'Add to wordbook'**
  String get vocabAddToBook;

  /// No description provided for @vocabWordHint.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get vocabWordHint;

  /// No description provided for @vocabMeaningHint.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get vocabMeaningHint;

  /// No description provided for @vocabPronunciationHint.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation (optional)'**
  String get vocabPronunciationHint;

  /// No description provided for @vocabPartOfSpeechHint.
  ///
  /// In en, this message translates to:
  /// **'Part of speech (optional)'**
  String get vocabPartOfSpeechHint;

  /// No description provided for @vocabContextMeaningHint.
  ///
  /// In en, this message translates to:
  /// **'Meaning in context (optional)'**
  String get vocabContextMeaningHint;

  /// No description provided for @vocabSentenceHint.
  ///
  /// In en, this message translates to:
  /// **'Example sentence (optional)'**
  String get vocabSentenceHint;

  /// No description provided for @vocabSaveTo.
  ///
  /// In en, this message translates to:
  /// **'Save to'**
  String get vocabSaveTo;

  /// No description provided for @vocabSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to ‘{name}’'**
  String vocabSavedTo(String name);

  /// No description provided for @vocabSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check the word and meaning'**
  String get vocabSaveFailed;

  /// No description provided for @vocabHistoryAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a word from history'**
  String get vocabHistoryAddTitle;

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get learnTitle;

  /// No description provided for @learnPickBook.
  ///
  /// In en, this message translates to:
  /// **'Word list to study'**
  String get learnPickBook;

  /// No description provided for @learnNoBooks.
  ///
  /// In en, this message translates to:
  /// **'No word lists yet'**
  String get learnNoBooks;

  /// No description provided for @learnNoBooksHint.
  ///
  /// In en, this message translates to:
  /// **'Save words from a translation result or history and you can study them here'**
  String get learnNoBooksHint;

  /// No description provided for @learnBook.
  ///
  /// In en, this message translates to:
  /// **'Word list'**
  String get learnBook;

  /// No description provided for @learnBookStats.
  ///
  /// In en, this message translates to:
  /// **'Words: {count} · {memorized} memorized'**
  String learnBookStats(int count, int memorized);

  /// No description provided for @learnTypes.
  ///
  /// In en, this message translates to:
  /// **'Study type'**
  String get learnTypes;

  /// No description provided for @learnTest.
  ///
  /// In en, this message translates to:
  /// **'Word test'**
  String get learnTest;

  /// No description provided for @learnTestHint.
  ///
  /// In en, this message translates to:
  /// **'Type the word from its meaning, or pick from choices'**
  String get learnTestHint;

  /// No description provided for @learnTestNeedWords.
  ///
  /// In en, this message translates to:
  /// **'Save at least one word to take it'**
  String get learnTestNeedWords;

  /// No description provided for @learnCards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get learnCards;

  /// No description provided for @learnGames.
  ///
  /// In en, this message translates to:
  /// **'Mini games'**
  String get learnGames;

  /// No description provided for @learnMatch.
  ///
  /// In en, this message translates to:
  /// **'Line match'**
  String get learnMatch;

  /// No description provided for @learnCardsHint.
  ///
  /// In en, this message translates to:
  /// **'Flip cards to see meanings and swipe to sort what you know'**
  String get learnCardsHint;

  /// No description provided for @cardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get cardsTitle;

  /// No description provided for @cardsProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String cardsProgress(int current, int total);

  /// No description provided for @cardsUnknownCount.
  ///
  /// In en, this message translates to:
  /// **'Not yet {count}'**
  String cardsUnknownCount(int count);

  /// No description provided for @cardsKnownCount.
  ///
  /// In en, this message translates to:
  /// **'Known {count}'**
  String cardsKnownCount(int count);

  /// No description provided for @cardsFlipHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the card to flip it'**
  String get cardsFlipHint;

  /// No description provided for @cardsSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe left if not yet, right if you know it'**
  String get cardsSwipeHint;

  /// No description provided for @cardsKnown.
  ///
  /// In en, this message translates to:
  /// **'I know it'**
  String get cardsKnown;

  /// No description provided for @cardsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get cardsUnknown;

  /// No description provided for @cardsResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Flashcard results'**
  String get cardsResultTitle;

  /// No description provided for @cardsResultSummary.
  ///
  /// In en, this message translates to:
  /// **'{known} known, {unknown} to review'**
  String cardsResultSummary(int known, int unknown);

  /// No description provided for @cardsAllKnown.
  ///
  /// In en, this message translates to:
  /// **'You know them all!'**
  String get cardsAllKnown;

  /// No description provided for @cardsReviewUnknown.
  ///
  /// In en, this message translates to:
  /// **'Review only the ones I missed'**
  String get cardsReviewUnknown;

  /// No description provided for @cardsRestart.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get cardsRestart;

  /// No description provided for @cardsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get cardsDone;

  /// No description provided for @cardsUnknownWords.
  ///
  /// In en, this message translates to:
  /// **'Words to review'**
  String get cardsUnknownWords;

  /// No description provided for @learnMatchHint.
  ///
  /// In en, this message translates to:
  /// **'Drag lines from words to meanings'**
  String get learnMatchHint;

  /// No description provided for @learnFall.
  ///
  /// In en, this message translates to:
  /// **'Falling words'**
  String get learnFall;

  /// No description provided for @learnAssemble.
  ///
  /// In en, this message translates to:
  /// **'Word assembly'**
  String get learnAssemble;

  /// No description provided for @matchTitle.
  ///
  /// In en, this message translates to:
  /// **'Line match'**
  String get matchTitle;

  /// No description provided for @matchScore.
  ///
  /// In en, this message translates to:
  /// **'Score {score}'**
  String matchScore(int score);

  /// No description provided for @matchRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} words left'**
  String matchRemaining(int count);

  /// No description provided for @matchHint.
  ///
  /// In en, this message translates to:
  /// **'Drag a word onto its meaning'**
  String get matchHint;

  /// No description provided for @matchResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Line match results'**
  String get matchResultTitle;

  /// No description provided for @matchRetry.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get matchRetry;

  /// No description provided for @learnFallHint.
  ///
  /// In en, this message translates to:
  /// **'Type to destroy the falling words'**
  String get learnFallHint;

  /// No description provided for @fallTitle.
  ///
  /// In en, this message translates to:
  /// **'Falling words'**
  String get fallTitle;

  /// No description provided for @fallRules.
  ///
  /// In en, this message translates to:
  /// **'You lose a life when a block hits the bottom. 3 lives, and it speeds up'**
  String get fallRules;

  /// No description provided for @fallModeMeaning.
  ///
  /// In en, this message translates to:
  /// **'Word → meaning'**
  String get fallModeMeaning;

  /// No description provided for @fallModeSpelling.
  ///
  /// In en, this message translates to:
  /// **'Meaning → spelling'**
  String get fallModeSpelling;

  /// No description provided for @fallModeMeaningHint.
  ///
  /// In en, this message translates to:
  /// **'Type the meaning of the falling word. For meanings split by commas, one is enough'**
  String get fallModeMeaningHint;

  /// No description provided for @fallModeSpellingHint.
  ///
  /// In en, this message translates to:
  /// **'Type the word for the falling meaning. Case is ignored'**
  String get fallModeSpellingHint;

  /// No description provided for @fallInputMeaning.
  ///
  /// In en, this message translates to:
  /// **'Type the meaning'**
  String get fallInputMeaning;

  /// No description provided for @fallInputSpelling.
  ///
  /// In en, this message translates to:
  /// **'Type the word'**
  String get fallInputSpelling;

  /// No description provided for @fallResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Falling words results'**
  String get fallResultTitle;

  /// No description provided for @fallDestroyed.
  ///
  /// In en, this message translates to:
  /// **'{count} destroyed'**
  String fallDestroyed(int count);

  /// No description provided for @fallMissedWords.
  ///
  /// In en, this message translates to:
  /// **'Missed words'**
  String get fallMissedWords;

  /// No description provided for @learnComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get learnComingSoon;

  /// No description provided for @testTitle.
  ///
  /// In en, this message translates to:
  /// **'Word test'**
  String get testTitle;

  /// No description provided for @testStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get testStart;

  /// No description provided for @testQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'Questions: {count}'**
  String testQuestionCount(int count);

  /// No description provided for @testMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get testMode;

  /// No description provided for @testModeChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get testModeChoice;

  /// No description provided for @testModeTyping.
  ///
  /// In en, this message translates to:
  /// **'Type it'**
  String get testModeTyping;

  /// No description provided for @testModeChoiceHint.
  ///
  /// In en, this message translates to:
  /// **'See a word and pick its meaning from 4 choices'**
  String get testModeChoiceHint;

  /// No description provided for @testModeTypingHint.
  ///
  /// In en, this message translates to:
  /// **'See a meaning and type the word. Case and surrounding spaces are ignored'**
  String get testModeTypingHint;

  /// No description provided for @testChoiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice needs at least {min} words across your word lists'**
  String testChoiceUnavailable(int min);

  /// No description provided for @testCannotStart.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t make questions. Save more words first'**
  String get testCannotStart;

  /// No description provided for @testProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String testProgress(int current, int total);

  /// No description provided for @testCorrectSoFar.
  ///
  /// In en, this message translates to:
  /// **'Correct: {count}'**
  String testCorrectSoFar(int count);

  /// No description provided for @testPromptMeaning.
  ///
  /// In en, this message translates to:
  /// **'Which word means this?'**
  String get testPromptMeaning;

  /// No description provided for @testPromptWord.
  ///
  /// In en, this message translates to:
  /// **'What does this word mean?'**
  String get testPromptWord;

  /// No description provided for @testAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Type the word'**
  String get testAnswerHint;

  /// No description provided for @testSubmit.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get testSubmit;

  /// No description provided for @testNext.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get testNext;

  /// No description provided for @testSeeResult.
  ///
  /// In en, this message translates to:
  /// **'See result'**
  String get testSeeResult;

  /// No description provided for @testCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get testCorrect;

  /// No description provided for @testWrong.
  ///
  /// In en, this message translates to:
  /// **'Answer: {answer}'**
  String testWrong(String answer);

  /// No description provided for @testResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Test result'**
  String get testResultTitle;

  /// No description provided for @testScore.
  ///
  /// In en, this message translates to:
  /// **'{correct} / {total}'**
  String testScore(int correct, int total);

  /// No description provided for @testPerfect.
  ///
  /// In en, this message translates to:
  /// **'You got them all!'**
  String get testPerfect;

  /// No description provided for @testWrongCount.
  ///
  /// In en, this message translates to:
  /// **'Missed words: {count}'**
  String testWrongCount(int count);

  /// No description provided for @testWrongWords.
  ///
  /// In en, this message translates to:
  /// **'Missed words'**
  String get testWrongWords;

  /// No description provided for @testYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer: {answer}'**
  String testYourAnswer(String answer);

  /// No description provided for @testRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get testRetry;

  /// No description provided for @testDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get testDone;

  /// No description provided for @vocabStudy.
  ///
  /// In en, this message translates to:
  /// **'Study words'**
  String get vocabStudy;

  /// No description provided for @vocabStudyHint.
  ///
  /// In en, this message translates to:
  /// **'Check what you know with a word test'**
  String get vocabStudyHint;
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
