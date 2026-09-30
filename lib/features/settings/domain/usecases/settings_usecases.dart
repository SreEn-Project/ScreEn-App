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

/// 온보딩을 마쳤다고 기록 (FL-01). 다음 실행부터 온보딩을 건너뛴다.
final class CompleteOnboarding implements NoParamsUseCase<void> {
  const CompleteOnboarding(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call() => _repository.setOnboardingCompleted(true);
}
