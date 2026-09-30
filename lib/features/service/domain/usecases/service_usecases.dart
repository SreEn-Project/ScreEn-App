import '../../../../core/domain/use_case.dart';
import '../entities/service_status.dart';
import '../repositories/service_repository.dart';

/// 현재 서비스 상태 (앱을 다시 열었을 때 등).
final class GetServiceStatus implements NoParamsUseCase<ServiceStatus> {
  const GetServiceStatus(this._repository);

  final ServiceRepository _repository;

  @override
  Future<ServiceStatus> call() => _repository.currentStatus();
}

/// 서비스 상태 변화 구독.
final class WatchServiceStatus implements StreamUseCase<ServiceStatus> {
  const WatchServiceStatus(this._repository);

  final ServiceRepository _repository;

  @override
  Stream<ServiceStatus> call() => _repository.watchStatus();
}

/// 번역 서비스 시작 (캡처 동의부터). 동의 대기 중에 다시 부르면 동의 창을 다시 띄운다.
final class StartTranslationService implements NoParamsUseCase<void> {
  const StartTranslationService(this._repository);

  final ServiceRepository _repository;

  @override
  Future<void> call() => _repository.start();
}

/// 번역 서비스 중지.
final class StopTranslationService implements NoParamsUseCase<void> {
  const StopTranslationService(this._repository);

  final ServiceRepository _repository;

  @override
  Future<void> call() => _repository.stop();
}
