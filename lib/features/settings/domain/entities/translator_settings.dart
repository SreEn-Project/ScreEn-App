import 'package:freezed_annotation/freezed_annotation.dart';

part 'translator_settings.freezed.dart';

/// 번역 엔진 (NA-11). AI 엔진은 3단계.
enum EngineType { mlKit, gemini, firebaseAi }

/// 캡처 범위 (NA-06). 1단계는 fullScreen만 동작.
enum CaptureMode { fullScreen, dragRegion, fixedRegion }

/// 결과 표시 방식 (FL-07). 1단계는 list만 동작.
enum DisplayMode { list, paragraph, overlay }

/// 빠른 언어 기본값 (네이티브 `Settings.DEFAULT_QUICK_LANGUAGES`와 같게).
const defaultQuickLanguages = ['ko', 'en', 'ja', 'zh'];

/// 빠른 언어는 최소 1개, 최대 [maxQuickLanguages]개 (버블 옵션 메뉴가 화면을 넘지 않게).
const minQuickLanguages = 1;
const maxQuickLanguages = 8;

/// 번역 설정 (NA-16). 원본은 네이티브 DataStore이며 앱은 읽고 바꾸기만 한다.
@freezed
abstract class TranslatorSettings with _$TranslatorSettings {
  const factory TranslatorSettings({
    /// BCP-47 언어 코드. 예: "ko", "en".
    @Default('ko') String targetLanguage,
    @Default(EngineType.mlKit) EngineType engine,
    @Default(CaptureMode.fullScreen) CaptureMode captureMode,
    @Default(DisplayMode.list) DisplayMode displayMode,
    @Default(false) bool onboardingCompleted,

    /// 플로팅 버튼 "빠른 언어" 버블에 나올 대상 언어 코드들 (사용자 편집, 순서 유지).
    @Default(defaultQuickLanguages) List<String> quickLanguages,
  }) = _TranslatorSettings;
}
