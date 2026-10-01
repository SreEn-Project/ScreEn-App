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

/// 자동 번역 "다시 번역 속도" 변경 (#33). 확인 간격과 조작 후 대기 시간을 함께 저장한다.
final class ChangeAutoSpeed implements UseCase<void, AutoSpeed> {
  const ChangeAutoSpeed(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(AutoSpeed speed) async {
    await _repository.setAutoCheckIntervalMs(speed.checkIntervalMs);
    await _repository.setAutoSettleMs(speed.settleMs);
  }
}

/// 자동 번역 이전 결과 숨김 시간 변경 (#29). 음수는 "숨기지 않음", 나머지는 가장 가까운 선택지로 맞춘다.
final class ChangeAutoHide implements UseCase<void, int> {
  const ChangeAutoHide(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(int ms) => _repository.setAutoHideMs(
    ms < 0 ? autoHideNever : nearestChoice(autoHideChoicesMs.sublist(0, 4), ms),
  );
}

/// 온보딩을 마쳤다고 기록 (FL-01). 다음 실행부터 온보딩을 건너뛴다.
final class CompleteOnboarding implements NoParamsUseCase<void> {
  const CompleteOnboarding(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call() => _repository.setOnboardingCompleted(true);
}
