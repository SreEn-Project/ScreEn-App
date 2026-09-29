// Flutter ↔ 네이티브 통신 정의 (NA-01).
// 수정 후 재생성: dart run pigeon --input pigeons/translator_api.dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/bridge/translator_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/app/src/main/kotlin/com/example/translation_poc_app/bridge/TranslatorApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.example.translation_poc_app.bridge',
    ),
    dartPackageName: 'translation_poc_app',
  ),
)
/// 번역 엔진 (NA-11). AI 엔진은 3단계.
enum EngineType { mlKit, gemini, firebaseAi }

/// 캡처 범위 (NA-06). 1단계는 fullScreen만 동작.
enum CaptureMode { fullScreen, dragRegion, fixedRegion }

/// 결과 표시 방식 (FL-07). 1단계는 list만 동작.
enum DisplayMode { list, overlay }

/// 포그라운드 서비스 상태 (NA-02).
enum ServiceState { stopped, starting, running }

/// DataStore에 저장되는 설정 (NA-16).
class AppSettings {
  AppSettings({
    required this.targetLanguage,
    required this.engine,
    required this.captureMode,
    required this.displayMode,
    required this.onboardingCompleted,
  });

  /// BCP-47 언어 코드. 예: "ko", "en", "ja".
  String targetLanguage;
  EngineType engine;
  CaptureMode captureMode;
  DisplayMode displayMode;
  bool onboardingCompleted;
}

@HostApi()
abstract class SettingsHostApi {
  @async
  AppSettings getSettings();

  @async
  void setTargetLanguage(String languageCode);

  @async
  void setEngine(EngineType engine);

  @async
  void setCaptureMode(CaptureMode mode);

  @async
  void setDisplayMode(DisplayMode mode);

  @async
  void setOnboardingCompleted(bool completed);
}

@HostApi()
abstract class ServiceHostApi {
  ServiceState getServiceState();
}

/// 네이티브 → Flutter 이벤트. 구독 시 현재 상태를 먼저 한 번씩 보낸다.
sealed class TranslatorEvent {}

class ServiceStateChanged extends TranslatorEvent {
  ServiceStateChanged(this.state);
  ServiceState state;
}

class SettingsChanged extends TranslatorEvent {
  SettingsChanged(this.settings);
  AppSettings settings;
}

@EventChannelApi()
abstract class TranslatorEventApi {
  TranslatorEvent events();
}
