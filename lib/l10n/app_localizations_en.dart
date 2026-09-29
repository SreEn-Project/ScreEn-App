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
  String get homeGreeting => 'Hello';

  @override
  String get homeHeadline => 'Translate any screen';

  @override
  String get homeHeadlineHighlight => 'Translate';

  @override
  String get homeNotifications => 'Notifications';

  @override
  String get homeServiceStopped => 'Translation service is off';

  @override
  String get homeServiceHint =>
      'When started, a translate button floats over other apps';

  @override
  String get homeStart => 'Start translating';

  @override
  String get homeStatusTargetLanguage => 'Target language';

  @override
  String get homeStatusEngine => 'Engine';

  @override
  String get homeStatusCaptureMode => 'Capture mode';

  @override
  String get homeCaptureModes => 'Capture modes';

  @override
  String get captureModeFull => 'Full screen';

  @override
  String get captureModeRegion => 'Select area';

  @override
  String get captureModeFixed => 'Fixed area';

  @override
  String get homeRecent => 'Recent';

  @override
  String get homeRecentFilterAll => 'All';

  @override
  String get homeRecentFilterToday => 'Today';

  @override
  String get homeRecentFilterWeek => 'This week';

  @override
  String get homeRecentEmpty => 'No translations yet';

  @override
  String get languageKorean => 'Korean';

  @override
  String get engineMlKit => 'On-device (ML Kit)';
}
