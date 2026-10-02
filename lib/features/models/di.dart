import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/bridge/bridge_providers.dart';
import 'data/datasources/model_native_data_source.dart';
import 'data/repositories/model_repository_impl.dart';
import 'domain/repositories/model_repository.dart';
import 'domain/usecases/model_usecases.dart';

part 'di.g.dart';

// 언어 모델 기능의 의존성 연결 (D-018). 테스트는 modelRepositoryProvider를 바꿔 끼운다.

@Riverpod(keepAlive: true)
ModelRepository modelRepository(Ref ref) =>
    ModelRepositoryImpl(ModelNativeDataSource(ref.watch(modelHostApiProvider)));

@riverpod
GetDownloadedModels getDownloadedModels(Ref ref) =>
    GetDownloadedModels(ref.watch(modelRepositoryProvider));

@riverpod
DownloadModel downloadModel(Ref ref) =>
    DownloadModel(ref.watch(modelRepositoryProvider));

@riverpod
DeleteModel deleteModel(Ref ref) =>
    DeleteModel(ref.watch(modelRepositoryProvider));
