// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Screen Translate';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonDone => 'Done';

  @override
  String get commonOpenSettings => 'Open settings';

  @override
  String get commonAllowed => 'Allowed';

  @override
  String get commonNotAllowed => 'Required';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingIntro1Title => 'Translate what you see';

  @override
  String get onboardingIntro1Highlight => 'Translate';

  @override
  String get onboardingIntro1Body =>
      'Games, comics, social feeds — even text you can\'t copy gets captured and translated.';

  @override
  String get onboardingIntro2Title => 'One button is all it takes';

  @override
  String get onboardingIntro2Highlight => 'button';

  @override
  String get onboardingIntro2Body =>
      'Tap the button floating over any app to read and translate the text on screen.';

  @override
  String get onboardingIntro3Title => 'Private, on your device';

  @override
  String get onboardingIntro3Highlight => 'Private';

  @override
  String get onboardingIntro3Body =>
      'Basic translation runs on your device. Screenshots are never saved or sent.';

  @override
  String get onboardingLanguageTitle =>
      'Which language should we translate into?';

  @override
  String get onboardingLanguageHighlight => 'language';

  @override
  String get onboardingLanguageBody => 'You can change this later in Settings.';

  @override
  String get languageSearchHint => 'Search languages';

  @override
  String get languageOcrUnsupported => 'Can\'t read as source';

  @override
  String get languageEmpty => 'No matching language';

  @override
  String get languagePickerTitle => 'Target language';

  @override
  String get permissionTitle => 'Just two permissions';

  @override
  String get permissionHighlight => 'permissions';

  @override
  String get permissionBody =>
      'Needed to show the translate button and let you know it\'s running.';

  @override
  String get permissionOverlayTitle => 'Display over other apps';

  @override
  String get permissionOverlayBody =>
      'Shows the translate button and results on top of any app.';

  @override
  String get permissionNotificationTitle => 'Notifications';

  @override
  String get permissionNotificationBody =>
      'Lets you know while the service is on, and lets you stop it from there.';

  @override
  String get permissionAllow => 'Allow';

  @override
  String get permissionContinue => 'Continue';

  @override
  String get permissionPending => 'Allow both to continue';

  @override
  String get homeGreeting => 'Hello';

  @override
  String get homeHeadline => 'Translate any screen';

  @override
  String get homeHeadlineHighlight => 'Translate';

  @override
  String get homeNotifications => 'Notifications';

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeServiceStopped => 'Translation service is off';

  @override
  String get homeServiceRunning => 'Translation service is on';

  @override
  String get homeServiceHint =>
      'When started, a translate button floats over other apps';

  @override
  String get homeServiceRunningHint => 'Tap the translate button in any app';

  @override
  String get homeStart => 'Start translating';

  @override
  String get homeStop => 'Stop translating';

  @override
  String get homeStatusOff => 'Off';

  @override
  String get homeStatusOn => 'Running';

  @override
  String get homeStarting => 'Reopen consent prompt';

  @override
  String get homeStatusStarting => 'Waiting';

  @override
  String get homeStatusError => 'Error';

  @override
  String get homeServiceStartingHint =>
      'Tap \"Start now\" on the screen capture prompt';

  @override
  String get homeServiceErrorHint => 'Couldn\'t start. Please try again';

  @override
  String get homePermissionsNeeded => 'Allow permissions to start';

  @override
  String get homeSourceAuto => 'Auto-detect';

  @override
  String get homeSectionSetup => 'Translation setup';

  @override
  String get homeTargetLanguage => 'Target language';

  @override
  String get homeModels => 'Language models';

  @override
  String homeModelsReady(int count) {
    return '$count ready';
  }

  @override
  String homeModelsDownloading(int count) {
    return '$count downloading';
  }

  @override
  String get homeEngine => 'Engine';

  @override
  String get homeAreaHint =>
      'Long-press the floating button to change the capture area';

  @override
  String get navHome => 'Home';

  @override
  String get navLanguages => 'Languages';

  @override
  String get navSettings => 'Settings';

  @override
  String get languagesTitle => 'Languages';

  @override
  String get languagesSectionTarget => 'Translate into';

  @override
  String get languagesSectionDownload => 'Downloads';

  @override
  String get homeRecent => 'Recent';

  @override
  String get homeRecentSeeAll => 'See all';

  @override
  String get homeRecentFilterAll => 'All';

  @override
  String get homeRecentFilterToday => 'Today';

  @override
  String get homeRecentFilterWeek => 'This week';

  @override
  String get homeRecentEmpty => 'No translations yet';

  @override
  String get historyTitle => 'History';

  @override
  String get historySearchHint => 'Search original or translation';

  @override
  String get historyNoResult => 'No matching translations';

  @override
  String get historyDelete => 'Delete';

  @override
  String get historyClearAll => 'Clear all';

  @override
  String get historyClearConfirm => 'Delete all?';

  @override
  String get captureModeFull => 'Full screen';

  @override
  String get captureModeRegion => 'Select area';

  @override
  String get captureModeFixed => 'Fixed area';

  @override
  String get engineMlKit => 'On-device';

  @override
  String get engineMlKitDetail => 'ML Kit · offline · free';

  @override
  String get engineGemini => 'My Gemini key';

  @override
  String get engineGeminiDetail =>
      'More natural AI translation · API key needed';

  @override
  String get engineFirebase => 'Google sign-in AI';

  @override
  String get engineFirebaseDetail => 'AI translation with just a sign-in';

  @override
  String get engineNeedsKey => 'Add an API key to use this';

  @override
  String get engineNeedsLogin => 'Requires Google sign-in and age check';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionTranslation => 'Translation';

  @override
  String get settingsTargetLanguage => 'Target language';

  @override
  String get settingsLanguageModels => 'Language models';

  @override
  String get settingsLanguageModelsDetail =>
      'Language files for on-device translation';

  @override
  String get settingsSectionEngine => 'Translation engine';

  @override
  String get settingsAiSetup => 'AI translation setup';

  @override
  String get settingsAiSetupDetail => 'Gemini API key';

  @override
  String get apiKeyTitle => 'AI translation setup';

  @override
  String get apiKeyHint => 'Paste your Gemini API key';

  @override
  String get apiKeyIntro =>
      'Get your own key from Google AI Studio and paste it here. It is encrypted and stored only on this device. Gemini API terms require you to be 18 or older. Translated text is sent to Google; if anything fails, ML Kit takes over.';

  @override
  String get apiKeySave => 'Save key';

  @override
  String get apiKeyRemove => 'Remove key';

  @override
  String get apiKeyRegistered => 'A key is registered';

  @override
  String get apiKeyShow => 'Show';

  @override
  String get apiKeyHide => 'Hide';

  @override
  String get settingsSectionCapture => 'Capture';

  @override
  String get settingsDefaultCaptureMode => 'Default capture mode';

  @override
  String get settingsResetFixedRegion => 'Reset fixed area';

  @override
  String get settingsResetFixedRegionEmpty => 'No fixed area saved';

  @override
  String get settingsSectionDisplay => 'Display';

  @override
  String get settingsDisplayMode => 'Show results as';

  @override
  String get displayModeList => 'List';

  @override
  String get displayModeParagraph => 'Paragraph';

  @override
  String get displayModeOverlay => 'Over original';

  @override
  String get settingsButtonSize => 'Floating button size';

  @override
  String get settingsButtonOpacity => 'Floating button opacity';

  @override
  String get settingsQuickLanguages => 'Quick languages';

  @override
  String get settingsQuickLanguagesDetail =>
      'Languages shown in the floating button\'s long-press menu';

  @override
  String get quickLanguagesTitle => 'Edit quick languages';

  @override
  String quickLanguagesHint(int count, int max, int min) {
    return '$count/$max selected, at least $min. Tap to toggle.';
  }

  @override
  String get settingsSectionAuto => 'Auto translate';

  @override
  String get settingsAutoTranslate =>
      'Translate automatically when the screen changes';

  @override
  String get settingsAutoTranslateDetail =>
      'After a translation, lightly watches the screen and starts translating as soon as the text changes or scrolling stops. Unchanged text is skipped. Leaving it on uses more battery and may warm the device.';

  @override
  String get settingsAutoTranslateUnavailable =>
      'Only available when results are shown over the text and the capture area is full screen or a fixed area.';

  @override
  String get settingsHideOverlayOnly => 'Over-text display only';

  @override
  String get settingsAutoShowDelay =>
      'Show the new translation (after you stop)';

  @override
  String get settingsHideAfterInteraction =>
      'Close the result after you touch the screen';

  @override
  String get settingsAutoInstant => 'Now';

  @override
  String get settingsAutoNever => 'Close manually';

  @override
  String secondsShort(String value) {
    return '${value}s';
  }

  @override
  String get settingsSectionEtc => 'More';

  @override
  String get settingsAbout => 'About';

  @override
  String get modelsTitle => 'Language models';

  @override
  String get modelsHeadline => 'On-device languages';

  @override
  String get modelsHighlight => 'On-device';

  @override
  String get modelsBody =>
      'About 30MB per language. Once downloaded, translation works offline.';

  @override
  String get modelsWifiOnly => 'Download on Wi-Fi only';

  @override
  String get modelsWifiOnlyDetail => 'Won\'t use mobile data';

  @override
  String get modelsInstalled => 'Installed';

  @override
  String get modelsNotInstalled => 'Not downloaded';

  @override
  String get modelsDownloading => 'Downloading';

  @override
  String get modelsDownloadFailed => 'Download failed. Check your connection';

  @override
  String modelsSize(int size) {
    return 'About ${size}MB';
  }

  @override
  String get modelsDownload => 'Download';

  @override
  String get modelsDelete => 'Delete';

  @override
  String get modelsCancel => 'Cancel';

  @override
  String get modelsSectionInstalled => 'Downloaded';

  @override
  String get modelsSectionAvailable => 'Available';

  @override
  String get modelsTargetOnly => 'Target only';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutPrivacy => 'Privacy policy';

  @override
  String get aboutLicenses => 'Open source licenses';

  @override
  String get aboutPending => 'Coming soon';
}
