import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/datasources/package_info_data_source.dart';
import 'data/repositories/app_info_repository_impl.dart';
import 'domain/repositories/app_info_repository.dart';
import 'domain/usecases/get_app_info.dart';

part 'di.g.dart';

// 정보 화면의 의존성 연결 (D-018). 테스트는 appInfoRepositoryProvider를 바꿔 끼운다.

@Riverpod(keepAlive: true)
AppInfoRepository appInfoRepository(Ref ref) =>
    const AppInfoRepositoryImpl(PackageInfoDataSource());

@riverpod
GetAppInfo getAppInfo(Ref ref) =>
    GetAppInfo(ref.watch(appInfoRepositoryProvider));
