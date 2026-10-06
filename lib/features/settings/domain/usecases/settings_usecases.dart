import '../../../../core/domain/use_case.dart';
import '../entities/translator_settings.dart';
import '../repositories/settings_repository.dart';

final class GetSettings implements NoParamsUseCase<TranslatorSettings> {
  const GetSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Future<TranslatorSettings> call() => _repository.load();
}

final class WatchSettings implements StreamUseCase<TranslatorSettings> {
  const WatchSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Stream<TranslatorSettings> call() => _repository.watch();
}

/// 대상 언어 변경 (FL-04). 언어 코드는 BCP-47.
final class ChangeTargetLanguage implements UseCase<void, String> {
  const ChangeTargetLanguage(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(String languageCode) =>
      _repository.setTargetLanguage(languageCode);
}

/// 번역 엔진 변경 (FL-06).
final class ChangeEngine implements UseCase<void, EngineType> {
  const ChangeEngine(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(EngineType engine) => _repository.setEngine(engine);
}

/// 기본 캡처 모드 변경 (FL-08).
final class ChangeCaptureMode implements UseCase<void, CaptureMode> {
  const ChangeCaptureMode(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(CaptureMode mode) => _repository.setCaptureMode(mode);
}

/// 결과 표시 방식 변경 (FL-07).
final class ChangeDisplayMode implements UseCase<void, DisplayMode> {
  const ChangeDisplayMode(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(DisplayMode mode) => _repository.setDisplayMode(mode);
}

/// 빠른 언어 목록 변경 (FL-04). 최소 [minQuickLanguages]개, 최대 [maxQuickLanguages]개로 맞추고 중복은 없앤다.
final class ChangeQuickLanguages implements UseCase<void, List<String>> {
  const ChangeQuickLanguages(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(List<String> languageCodes) {
    final codes = languageCodes.toSet().take(maxQuickLanguages).toList();
    if (codes.length < minQuickLanguages) return Future.value();
    return _repository.setQuickLanguages(codes);
  }
}

/// 자동 번역 켜고 끄기 (#23).
final class ChangeAutoTranslate implements UseCase<void, bool> {
  const ChangeAutoTranslate(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(bool enabled) => _repository.setAutoTranslate(enabled);
}

/// 자동 번역이 새 번역을 보여 주는 시점 변경 (#35). 가장 가까운 선택지로 맞춘다.
final class ChangeAutoShowDelay implements UseCase<void, int> {
  const ChangeAutoShowDelay(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(int ms) =>
      _repository.setAutoShowDelayMs(nearestChoice(autoShowDelayChoicesMs, ms));
}

/// 조작 뒤 번역 결과 닫힘 시간 변경 (#29, #35, #76). 음수는 "직접 닫기", 나머지는 가장 가까운 선택지로 맞춘다.
final class ChangeHideAfterInteraction implements UseCase<void, int> {
  const ChangeHideAfterInteraction(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(int ms) => _repository.setHideAfterInteractionMs(
    ms < 0
        ? hideNever
        : nearestChoice(hideAfterInteractionChoicesMs.sublist(0, 4), ms),
  );
}

/// 언어 모델 Wi-Fi 전용 받기 켜고 끄기 (FL-05).
final class ChangeWifiOnlyModelDownload implements UseCase<void, bool> {
  const ChangeWifiOnlyModelDownload(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(bool enabled) =>
      _repository.setWifiOnlyModelDownload(enabled);
}

/// 플로팅 버튼 크기 변경 (FL-07). 범위 안으로 맞추고 [buttonSizeStepDp] 단위로 반올림한다.
final class ChangeButtonSize implements UseCase<void, int> {
  const ChangeButtonSize(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(int dp) {
    final steps = ((dp - minButtonSizeDp) / buttonSizeStepDp).round();
    return _repository.setButtonSizeDp(
      (minButtonSizeDp + steps * buttonSizeStepDp).clamp(
        minButtonSizeDp,
        maxButtonSizeDp,
      ),
    );
  }
}

/// 플로팅 버튼 불투명도 변경 (FL-07). 범위 안으로 맞추고 [buttonOpacityStepPercent] 단위로 반올림한다.
final class ChangeButtonOpacity implements UseCase<void, int> {
  const ChangeButtonOpacity(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(int percent) {
    final steps =
        ((percent - minButtonOpacityPercent) / buttonOpacityStepPercent)
            .round();
    return _repository.setButtonOpacityPercent(
      (minButtonOpacityPercent + steps * buttonOpacityStepPercent).clamp(
        minButtonOpacityPercent,
        maxButtonOpacityPercent,
      ),
    );
  }
}

/// 저장된 고정 영역 지우기 (FL-08).
final class ResetFixedRegion implements NoParamsUseCase<void> {
  const ResetFixedRegion(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call() => _repository.resetFixedRegion();
}

/// 온보딩을 마쳤다고 기록 (FL-01). 다음 실행부터 온보딩을 건너뛴다.
final class CompleteOnboarding implements NoParamsUseCase<void> {
  const CompleteOnboarding(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call() => _repository.setOnboardingCompleted(true);
}

/// 만 18세 이상 확인 저장 · 해제 (FL-09).
final class ChangeAgeConfirmed implements UseCase<void, bool> {
  const ChangeAgeConfirmed(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(bool confirmed) => _repository.setAgeConfirmed(confirmed);
}

/// AI 번역 말투 변경 (FL-11).
final class ChangeAiTone implements UseCase<void, AiTone> {
  const ChangeAiTone(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(AiTone tone) => _repository.setAiTone(tone);
}

/// AI 번역 용어집 변경 (FL-11). 앞뒤 공백을 걷고, 빈 칸 · 같은 원문(대소문자 무시) 중복을 빼고,
/// 길이 · 개수를 제한한 뒤 저장한다. 앞의 항목이 이긴다.
final class ChangeGlossary implements UseCase<void, List<GlossaryEntry>> {
  const ChangeGlossary(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(List<GlossaryEntry> entries) {
    final seen = <String>{};
    final cleaned = <GlossaryEntry>[];
    for (final entry in entries) {
      final source = _limit(entry.source.trim());
      final target = _limit(entry.target.trim());
      if (source.isEmpty || target.isEmpty) continue;
      if (!seen.add(source.toLowerCase())) continue;
      cleaned.add(GlossaryEntry(source: source, target: target));
      if (cleaned.length == maxGlossaryEntries) break;
    }
    return _repository.setGlossary(cleaned);
  }

  static String _limit(String text) => text.length > maxGlossaryTextLength
      ? text.substring(0, maxGlossaryTextLength).trim()
      : text;
}

/// 저장된 AI 번역 API 키 (NA-13). 없으면 null.
final class GetApiKey implements NoParamsUseCase<String?> {
  const GetApiKey(this._repository);

  final SettingsRepository _repository;

  @override
  Future<String?> call() => _repository.getApiKey();
}

/// AI 번역 API 키 저장 (NA-13). 공백은 걷어 낸다.
final class SaveApiKey implements UseCase<void, String> {
  const SaveApiKey(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(String apiKey) => _repository.setApiKey(apiKey.trim());
}

/// AI 번역 API 키 삭제 (NA-13).
final class ClearApiKey implements NoParamsUseCase<void> {
  const ClearApiKey(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call() => _repository.clearApiKey();
}

/// 입력한 AI 번역 API 키를 실제로 호출해 본다 (NA-13). 성공이면 null, 실패면 이유.
final class TestApiKey implements UseCase<String?, String> {
  const TestApiKey(this._repository);

  final SettingsRepository _repository;

  @override
  Future<String?> call(String apiKey) => _repository.testApiKey(apiKey.trim());
}

/// API 키 접근 PIN이 켜져 있는지 (NA-13).
final class IsApiKeyPinEnabled implements NoParamsUseCase<bool> {
  const IsApiKeyPinEnabled(this._repository);

  final SettingsRepository _repository;

  @override
  Future<bool> call() => _repository.isApiKeyPinEnabled();
}

/// 4자리 PIN 확인 (NA-13). 맞으면 true.
final class VerifyApiKeyPin implements UseCase<bool, String> {
  const VerifyApiKeyPin(this._repository);

  final SettingsRepository _repository;

  @override
  Future<bool> call(String pin) => _repository.verifyApiKeyPin(pin);
}

/// [SetApiKeyPin] 입력: 새 PIN과 (이미 PIN이 있을 때) 현재 PIN.
typedef SetApiKeyPinParams = ({String newPin, String? currentPin});

/// API 키 접근 PIN 켜기 · 바꾸기 (NA-13). 현재 PIN이 틀리거나 4자리 숫자가 아니면 false.
final class SetApiKeyPin implements UseCase<bool, SetApiKeyPinParams> {
  const SetApiKeyPin(this._repository);

  final SettingsRepository _repository;

  @override
  Future<bool> call(SetApiKeyPinParams params) =>
      _repository.setApiKeyPin(params.newPin, params.currentPin);
}

/// API 키 접근 PIN 끄기 (NA-13). 현재 PIN이 틀리면 false.
final class ClearApiKeyPin implements UseCase<bool, String> {
  const ClearApiKeyPin(this._repository);

  final SettingsRepository _repository;

  @override
  Future<bool> call(String currentPin) =>
      _repository.clearApiKeyPin(currentPin);
}

/// PIN 분실 시 초기화 (NA-13): 키와 PIN을 함께 지운다.
final class ResetApiKeyProtection implements NoParamsUseCase<void> {
  const ResetApiKeyProtection(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call() => _repository.resetApiKeyProtection();
}
