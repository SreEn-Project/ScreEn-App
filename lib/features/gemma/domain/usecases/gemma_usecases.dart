import '../../../../core/domain/use_case.dart';
import '../entities/gemma_status.dart';
import '../repositories/gemma_repository.dart';

final class GetGemmaStatus implements NoParamsUseCase<GemmaStatus> {
  const GetGemmaStatus(this._repository);

  final GemmaRepository _repository;

  @override
  Future<GemmaStatus> call() => _repository.status();
}

final class StartGemmaDownload implements UseCase<void, bool> {
  const StartGemmaDownload(this._repository);

  final GemmaRepository _repository;

  /// [wifiOnly]가 true면 데이터 요금이 드는 망에서는 받지 않는다.
  @override
  Future<void> call(bool wifiOnly) =>
      _repository.startDownload(wifiOnly: wifiOnly);
}

final class CancelGemmaDownload implements NoParamsUseCase<void> {
  const CancelGemmaDownload(this._repository);

  final GemmaRepository _repository;

  @override
  Future<void> call() => _repository.cancelDownload();
}

final class DeleteGemmaModel implements NoParamsUseCase<void> {
  const DeleteGemmaModel(this._repository);

  final GemmaRepository _repository;

  @override
  Future<void> call() => _repository.deleteModel();
}

/// Hugging Face 토큰 저장. 빈 문자열이면 지운다.
final class SaveHuggingFaceToken implements UseCase<void, String> {
  const SaveHuggingFaceToken(this._repository);

  final GemmaRepository _repository;

  @override
  Future<void> call(String token) {
    final trimmed = token.trim();
    return trimmed.isEmpty
        ? _repository.clearToken()
        : _repository.setToken(trimmed);
  }
}
