import '../../../../core/domain/use_case.dart';
import '../repositories/model_repository.dart';

final class GetDownloadedModels implements NoParamsUseCase<Set<String>> {
  const GetDownloadedModels(this._repository);

  final ModelRepository _repository;

  @override
  Future<Set<String>> call() => _repository.downloaded();
}

/// 언어 모델 받기 (FL-05).
final class DownloadModel implements UseCase<void, DownloadModelParams> {
  const DownloadModel(this._repository);

  final ModelRepository _repository;

  @override
  Future<void> call(DownloadModelParams params) =>
      _repository.download(params.languageCode, wifiOnly: params.wifiOnly);
}

class DownloadModelParams {
  const DownloadModelParams(this.languageCode, {required this.wifiOnly});

  final String languageCode;
  final bool wifiOnly;
}

/// 언어 모델 삭제 (FL-05).
final class DeleteModel implements UseCase<void, String> {
  const DeleteModel(this._repository);

  final ModelRepository _repository;

  @override
  Future<void> call(String languageCode) => _repository.delete(languageCode);
}
