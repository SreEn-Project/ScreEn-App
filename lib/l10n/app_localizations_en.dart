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
  String get historyDetailTranslated => 'Translation';

  @override
  String get historyDetailOriginal => 'Original';

  @override
  String get historyCopy => 'Copy';

  @override
  String get historyCopied => 'Copied';

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
  String get engineNeedsKey => 'Add an API key to use this';

  @override
  String get engineNeedsAge =>
      'Confirm you are 18 or older in AI translation setup';

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
      'Get your own key from Google AI Studio and paste it here. It is encrypted and stored only on this device. Translated text is sent to Google; if anything fails, ML Kit takes over.';

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
  String get apiKeyTest => 'Test key';

  @override
  String get apiKeyTestOk => 'The key works';

  @override
  String apiKeyTestFailed(String reason) {
    return 'Rejected: $reason';
  }

  @override
  String get apiKeyGet => 'Get a key from Google AI Studio';

  @override
  String get apiKeyPinTitle => 'Key PIN lock';

  @override
  String get apiKeyPinDetail =>
      'Ask for a 4-digit PIN before viewing, editing or deleting the key';

  @override
  String get apiKeyPinChange => 'Change PIN';

  @override
  String get apiKeyLockedTitle => 'API key is locked';

  @override
  String get apiKeyLockedBody => 'Enter your PIN to view or edit the key.';

  @override
  String get apiKeyUnlock => 'Enter PIN';

  @override
  String get apiKeyPinForgot => 'I forgot my PIN';

  @override
  String get pinEnterTitle => 'Enter PIN';

  @override
  String get pinEnterBody => 'Enter your 4-digit PIN.';

  @override
  String get pinCurrentTitle => 'Current PIN';

  @override
  String get pinNewTitle => 'Create a new PIN';

  @override
  String get pinNewBody => '4 digits to lock the key.';

  @override
  String get pinConfirmTitle => 'Enter PIN again';

  @override
  String get pinWrong => 'Wrong PIN';

  @override
  String get pinMismatch => 'Doesn\'t match the first PIN';

  @override
  String get pinResetTitle => 'Delete the key and reset?';

  @override
  String get pinResetBody =>
      'If you forgot the PIN, the saved API key and the PIN are deleted. You\'ll need to add the key again, and the AI engine goes back to ML Kit.';

  @override
  String get pinResetConfirm => 'Delete key and reset';

  @override
  String get pinCancel => 'Cancel';

  @override
  String get aiAgeTitle => 'I am 18 or older';

  @override
  String get aiAgeDetail =>
      'Under the Gemini API terms, AI translation is only for people 18 or older. Confirm to turn it on.';

  @override
  String get aiNoticeTitle => 'About data sent';

  @override
  String get aiNoticeBody =>
      'When AI translation is on, the text read from your screen is sent to the AI provider you chose (Google Gemini). On the free tier, Google may use it to improve and review its services. Don\'t translate screens that show passwords or personal information.';

  @override
  String get aiOptionsTitle => 'Translation options';

  @override
  String get aiToneTitle => 'Tone';

  @override
  String get aiToneHint =>
      'Applies to AI translation only. Works best when the target language has formal and casual speech.';

  @override
  String get aiToneStandard => 'Default';

  @override
  String get aiToneFormal => 'Formal';

  @override
  String get aiToneInformal => 'Casual';

  @override
  String get aiGlossaryTitle => 'Glossary';

  @override
  String get aiGlossaryDetail =>
      'Always translates a term the way you set it. Only terms found in the text are sent to the AI.';

  @override
  String get aiGlossarySourceHint => 'Original (e.g. Mana)';

  @override
  String get aiGlossaryTargetHint => 'Translation (e.g. 마나)';

  @override
  String get aiGlossaryAdd => 'Add term';

  @override
  String get aiGlossaryRemove => 'Delete';

  @override
  String get aiGlossaryEmpty => 'No terms yet';

  @override
  String aiGlossaryFull(int max) {
    return 'You can add up to $max terms';
  }

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

  @override
  String get vocabTitle => 'Vocabulary';

  @override
  String get vocabHomeHint => 'Browse the words you saved';

  @override
  String get vocabEmpty => 'No word lists yet';

  @override
  String get vocabEmptyHint => 'Create one to save words while you translate';

  @override
  String get vocabNewBook => 'New list';

  @override
  String get vocabNameHint => 'List name';

  @override
  String get vocabCreate => 'Create';

  @override
  String get vocabRename => 'Rename';

  @override
  String get vocabDelete => 'Delete';

  @override
  String get vocabCancel => 'Cancel';

  @override
  String get vocabSave => 'Save';

  @override
  String get vocabNameTaken => 'A list with this name already exists';

  @override
  String vocabWordCount(int count) {
    return 'Words: $count';
  }

  @override
  String vocabMemorizedCount(int count) {
    return '$count memorized';
  }

  @override
  String vocabDeleteBookTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String vocabDeleteBookBody(int count) {
    return 'Words inside will be deleted too ($count).';
  }

  @override
  String get vocabSearchHint => 'Search words or meanings';

  @override
  String get vocabSortNewest => 'Newest';

  @override
  String get vocabSortOldest => 'Oldest';

  @override
  String get vocabSortAlphabetical => 'A–Z';

  @override
  String get vocabNoWords => 'This list is empty';

  @override
  String get vocabNoResult => 'No matching words';

  @override
  String get vocabMove => 'Move to another list';

  @override
  String get vocabMoveTitle => 'Move to';

  @override
  String get vocabMoveNoOther => 'There is no other list to move to';

  @override
  String get vocabMemorizedLabel => 'Memorized';

  @override
  String get vocabWordDetailTitle => 'Word';

  @override
  String get vocabMeaning => 'Meaning';

  @override
  String get vocabPronunciation => 'Pronunciation';

  @override
  String get vocabPartOfSpeech => 'Part of speech';

  @override
  String get vocabContextMeaning => 'Meaning in context';

  @override
  String get vocabSentence => 'Example from the screen';

  @override
  String get vocabSourceApp => 'Source';

  @override
  String get vocabSavedAt => 'Saved on';

  @override
  String get vocabDeleteWord => 'Delete word';

  @override
  String get vocabDeleteWordTitle => 'Delete this word?';

  @override
  String get vocabWordGone => 'This word was already deleted';

  @override
  String get vocabAddWord => 'Add word';

  @override
  String get vocabAddToBook => 'Add to wordbook';

  @override
  String get vocabWordHint => 'Word';

  @override
  String get vocabMeaningHint => 'Meaning';

  @override
  String get vocabPronunciationHint => 'Pronunciation (optional)';

  @override
  String get vocabPartOfSpeechHint => 'Part of speech (optional)';

  @override
  String get vocabContextMeaningHint => 'Meaning in context (optional)';

  @override
  String get vocabSentenceHint => 'Example sentence (optional)';

  @override
  String get vocabSaveTo => 'Save to';

  @override
  String vocabSavedTo(String name) {
    return 'Saved to ‘$name’';
  }

  @override
  String get vocabSaveFailed => 'Could not save. Check the word and meaning';

  @override
  String get vocabHistoryAddTitle => 'Add a word from history';

  @override
  String get learnTitle => 'Study';

  @override
  String get learnPickBook => 'Word list to study';

  @override
  String get learnNoBooks => 'No word lists yet';

  @override
  String get learnNoBooksHint =>
      'Save words from a translation result or history and you can study them here';

  @override
  String get learnBook => 'Word list';

  @override
  String learnBookStats(int count, int memorized) {
    return 'Words: $count · $memorized memorized';
  }

  @override
  String get learnTypes => 'Study type';

  @override
  String get learnTest => 'Word test';

  @override
  String get learnTestHint =>
      'Type the word from its meaning, or pick from choices';

  @override
  String get learnTestNeedWords => 'Save at least one word to take it';

  @override
  String get learnCards => 'Flashcards';

  @override
  String get learnGames => 'Mini games';

  @override
  String get learnMatch => 'Line match';

  @override
  String get learnCardsHint =>
      'Flip cards to see meanings and swipe to sort what you know';

  @override
  String get cardsTitle => 'Flashcards';

  @override
  String cardsProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String cardsUnknownCount(int count) {
    return 'Not yet $count';
  }

  @override
  String cardsKnownCount(int count) {
    return 'Known $count';
  }

  @override
  String get cardsFlipHint => 'Tap the card to flip it';

  @override
  String get cardsSwipeHint => 'Swipe left if not yet, right if you know it';

  @override
  String get cardsKnown => 'I know it';

  @override
  String get cardsUnknown => 'Not yet';

  @override
  String get cardsResultTitle => 'Flashcard results';

  @override
  String cardsResultSummary(int known, int unknown) {
    return '$known known, $unknown to review';
  }

  @override
  String get cardsAllKnown => 'You know them all!';

  @override
  String get cardsReviewUnknown => 'Review only the ones I missed';

  @override
  String get cardsRestart => 'Start over';

  @override
  String get cardsDone => 'Done';

  @override
  String get cardsUnknownWords => 'Words to review';

  @override
  String get learnMatchHint => 'Drag lines from words to meanings';

  @override
  String get learnFall => 'Falling words';

  @override
  String get learnAssemble => 'Word assembly';

  @override
  String get matchTitle => 'Line match';

  @override
  String matchScore(int score) {
    return 'Score $score';
  }

  @override
  String matchRemaining(int count) {
    return '$count words left';
  }

  @override
  String get matchHint => 'Drag a word onto its meaning';

  @override
  String get matchResultTitle => 'Line match results';

  @override
  String get matchRetry => 'Play again';

  @override
  String get learnFallHint => 'Type to destroy the falling words';

  @override
  String get fallTitle => 'Falling words';

  @override
  String get fallRules =>
      'You lose a life when a block hits the bottom. 3 lives, and it speeds up';

  @override
  String get fallModeMeaning => 'Word → meaning';

  @override
  String get fallModeSpelling => 'Meaning → spelling';

  @override
  String get fallModeMeaningHint =>
      'Type the meaning of the falling word. For meanings split by commas, one is enough';

  @override
  String get fallModeSpellingHint =>
      'Type the word for the falling meaning. Case is ignored';

  @override
  String get fallInputMeaning => 'Type the meaning';

  @override
  String get fallInputSpelling => 'Type the word';

  @override
  String get fallResultTitle => 'Falling words results';

  @override
  String fallDestroyed(int count) {
    return '$count destroyed';
  }

  @override
  String get fallMissedWords => 'Missed words';

  @override
  String get learnComingSoon => 'Coming soon';

  @override
  String get testTitle => 'Word test';

  @override
  String get testStart => 'Start';

  @override
  String testQuestionCount(int count) {
    return 'Questions: $count';
  }

  @override
  String get testMode => 'Mode';

  @override
  String get testModeChoice => 'Multiple choice';

  @override
  String get testModeTyping => 'Type it';

  @override
  String get testModeChoiceHint =>
      'See a word and pick its meaning from 4 choices';

  @override
  String get testModeTypingHint =>
      'See a meaning and type the word. Case and surrounding spaces are ignored';

  @override
  String testChoiceUnavailable(int min) {
    return 'Multiple choice needs at least $min words across your word lists';
  }

  @override
  String get testCannotStart =>
      'Couldn’t make questions. Save more words first';

  @override
  String testProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String testCorrectSoFar(int count) {
    return 'Correct: $count';
  }

  @override
  String get testPromptMeaning => 'Which word means this?';

  @override
  String get testPromptWord => 'What does this word mean?';

  @override
  String get testAnswerHint => 'Type the word';

  @override
  String get testSubmit => 'Check';

  @override
  String get testNext => 'Next question';

  @override
  String get testSeeResult => 'See result';

  @override
  String get testCorrect => 'Correct!';

  @override
  String testWrong(String answer) {
    return 'Answer: $answer';
  }

  @override
  String get testResultTitle => 'Test result';

  @override
  String testScore(int correct, int total) {
    return '$correct / $total';
  }

  @override
  String get testPerfect => 'You got them all!';

  @override
  String testWrongCount(int count) {
    return 'Missed words: $count';
  }

  @override
  String get testWrongWords => 'Missed words';

  @override
  String testYourAnswer(String answer) {
    return 'Your answer: $answer';
  }

  @override
  String get testRetry => 'Try again';

  @override
  String get testDone => 'Done';

  @override
  String get vocabStudy => 'Study words';

  @override
  String get vocabStudyHint => 'Check what you know with a word test';
}
