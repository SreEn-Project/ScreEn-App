import '../../../../core/domain/use_case.dart';
import '../entities/app_info.dart';
import '../repositories/app_info_repository.dart';

/// 앱 버전 조회 (FL-14).
final class GetAppInfo implements NoParamsUseCase<AppInfo> {
  const GetAppInfo(this._repository);

  final AppInfoRepository _repository;

  @override
  Future<AppInfo> call() => _repository.load();
}
