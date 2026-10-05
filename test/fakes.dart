import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:translation_poc_app/features/about/di.dart';
import 'package:translation_poc_app/features/about/domain/entities/app_info.dart';
import 'package:translation_poc_app/features/about/domain/repositories/app_info_repository.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:translation_poc_app/features/history/di.dart';
import 'package:translation_poc_app/features/history/domain/entities/history_entry.dart';
import 'package:translation_poc_app/features/history/domain/repositories/history_repository.dart';
import 'package:translation_poc_app/features/models/di.dart';
import 'package:translation_poc_app/features/models/domain/repositories/model_repository.dart';
import 'package:translation_poc_app/features/permission/di.dart';
import 'package:translation_poc_app/features/permission/domain/entities/app_permissions.dart';
import 'package:translation_poc_app/features/permission/domain/repositories/permission_repository.dart';
import 'package:translation_poc_app/features/service/di.dart';
import 'package:translation_poc_app/features/service/domain/entities/service_status.dart';
import 'package:translation_poc_app/features/service/domain/repositories/service_repository.dart';

/// 네이티브 없이 화면을 띄우는 위젯 · 스크린샷 테스트용 가짜 서비스.
class FakeServiceRepository implements ServiceRepository {
  FakeServiceRepository([this._state = ServiceStatus.stopped]);

  ServiceStatus _state;

  @override
  Future<ServiceStatus> currentStatus() async => _state;

  @override
  Stream<ServiceStatus> watchStatus() => const Stream.empty();

  @override
  Future<void> start() async => _state = ServiceStatus.running;

  @override
  Future<void> stop() async => _state = ServiceStatus.stopped;
}

/// 요청하면 바로 허용되는 가짜 권한.
class FakePermissionRepository implements PermissionRepository {
  FakePermissionRepository({this.overlay = false, this.notification = false});

  bool overlay;
  bool notification;

  @override
  Future<AppPermissions> check() async =>
      AppPermissions(overlay: overlay, notification: notification);

  @override
  Future<void> requestNotification() async => notification = true;

  @override
  Future<void> requestOverlay() async => overlay = true;
}

/// 기본 설정을 돌려주는 가짜 설정 저장소 (바꾸면 기억만 한다).
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this.settings = const TranslatorSettings()]);

  TranslatorSettings settings;

  @override
  Future<TranslatorSettings> load() async => settings;

  @override
  Stream<TranslatorSettings> watch() => const Stream.empty();

  @override
  Future<void> setTargetLanguage(String languageCode) async =>
      settings = settings.copyWith(targetLanguage: languageCode);

  @override
  Future<void> setEngine(EngineType engine) async =>
      settings = settings.copyWith(engine: engine);

  @override
  Future<void> setCaptureMode(CaptureMode mode) async =>
      settings = settings.copyWith(captureMode: mode);

  @override
  Future<void> setDisplayMode(DisplayMode mode) async =>
      settings = settings.copyWith(displayMode: mode);

  @override
  Future<void> setQuickLanguages(List<String> languageCodes) async =>
      settings = settings.copyWith(quickLanguages: languageCodes);

  @override
  Future<void> setAutoTranslate(bool enabled) async =>
      settings = settings.copyWith(autoTranslate: enabled);

  @override
  Future<void> setAutoShowDelayMs(int ms) async =>
      settings = settings.copyWith(autoShowDelayMs: ms);

  @override
  Future<void> setHideAfterInteractionMs(int ms) async =>
      settings = settings.copyWith(hideAfterInteractionMs: ms);

  @override
  Future<void> setWifiOnlyModelDownload(bool enabled) async =>
      settings = settings.copyWith(wifiOnlyModelDownload: enabled);

  @override
  Future<void> setButtonSizeDp(int dp) async =>
      settings = settings.copyWith(buttonSizeDp: dp);

  @override
  Future<void> setButtonOpacityPercent(int percent) async =>
      settings = settings.copyWith(buttonOpacityPercent: percent);

  @override
  Future<void> resetFixedRegion() async =>
      settings = settings.copyWith(hasFixedRegion: false);

  @override
  Future<void> setOnboardingCompleted(bool completed) async =>
      settings = settings.copyWith(onboardingCompleted: completed);

  String? apiKey;

  @override
  Future<String?> getApiKey() async => apiKey;

  @override
  Future<void> setApiKey(String apiKey) async => this.apiKey = apiKey;

  @override
  Future<void> clearApiKey() async => apiKey = null;
}

/// 받은 모델을 기억만 하는 가짜 모델 저장소.
class FakeModelRepository implements ModelRepository {
  FakeModelRepository([Set<String> installed = const {'ko', 'en'}])
    : installed = {...installed};

  final Set<String> installed;

  @override
  Future<Set<String>> downloaded() async => {...installed};

  @override
  Future<void> download(String languageCode, {required bool wifiOnly}) async =>
      installed.add(languageCode);

  @override
  Future<void> delete(String languageCode) async =>
      installed.remove(languageCode);
}

/// 기록을 메모리에 들고 있는 가짜 번역 기록 저장소 (최신순).
class FakeHistoryRepository implements HistoryRepository {
  FakeHistoryRepository([List<HistoryEntry> entries = const []])
    : entries = [...entries];

  final List<HistoryEntry> entries;

  @override
  Future<List<HistoryEntry>> search({
    String query = '',
    DateTime? since,
    required int limit,
  }) async {
    final q = query.toLowerCase();
    return entries
        .where(
          (e) =>
              (since == null || !e.translatedAt.isBefore(since)) &&
              (q.isEmpty ||
                  e.original.toLowerCase().contains(q) ||
                  e.translated.toLowerCase().contains(q)),
        )
        .take(limit)
        .toList();
  }

  @override
  Future<void> delete(int id) async => entries.removeWhere((e) => e.id == id);

  @override
  Future<void> clear() async => entries.clear();
}

/// 고정된 앱 버전을 돌려주는 가짜 앱 정보.
class FakeAppInfoRepository implements AppInfoRepository {
  const FakeAppInfoRepository();

  @override
  Future<AppInfo> load() async =>
      const AppInfo(version: '1.2.3', buildNumber: '45');
}

/// 네이티브 연결 provider를 가짜로 바꾼다.
List<Override> fakeNativeOverrides({
  ServiceStatus service = ServiceStatus.stopped,
  bool permissionsGranted = false,
  bool onboardingCompleted = false,
  FakeSettingsRepository? settings,
}) => [
  serviceRepositoryProvider.overrideWithValue(FakeServiceRepository(service)),
  settingsRepositoryProvider.overrideWithValue(
    settings ??
        FakeSettingsRepository(
          TranslatorSettings(onboardingCompleted: onboardingCompleted),
        ),
  ),
  appInfoRepositoryProvider.overrideWithValue(const FakeAppInfoRepository()),
  modelRepositoryProvider.overrideWithValue(FakeModelRepository()),
  historyRepositoryProvider.overrideWithValue(FakeHistoryRepository()),
  permissionRepositoryProvider.overrideWithValue(
    FakePermissionRepository(
      overlay: permissionsGranted,
      notification: permissionsGranted,
    ),
  ),
];
