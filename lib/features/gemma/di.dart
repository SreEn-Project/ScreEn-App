import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/bridge/bridge_providers.dart';
import 'data/datasources/gemma_native_data_source.dart';
import 'data/repositories/gemma_repository_impl.dart';
import 'domain/repositories/gemma_repository.dart';
import 'domain/usecases/gemma_usecases.dart';

part 'di.g.dart';

// Gemma 온디바이스 모델 기능의 의존성 연결 (D-018, #174). 테스트는 gemmaRepositoryProvider를 바꿔 끼운다.

@Riverpod(keepAlive: true)
GemmaRepository gemmaRepository(Ref ref) =>
    GemmaRepositoryImpl(GemmaNativeDataSource(ref.watch(gemmaHostApiProvider)));

@riverpod
GetGemmaStatus getGemmaStatus(Ref ref) =>
    GetGemmaStatus(ref.watch(gemmaRepositoryProvider));

@riverpod
StartGemmaDownload startGemmaDownload(Ref ref) =>
    StartGemmaDownload(ref.watch(gemmaRepositoryProvider));

@riverpod
CancelGemmaDownload cancelGemmaDownload(Ref ref) =>
    CancelGemmaDownload(ref.watch(gemmaRepositoryProvider));

@riverpod
DeleteGemmaModel deleteGemmaModel(Ref ref) =>
    DeleteGemmaModel(ref.watch(gemmaRepositoryProvider));

@riverpod
SaveHuggingFaceToken saveHuggingFaceToken(Ref ref) =>
    SaveHuggingFaceToken(ref.watch(gemmaRepositoryProvider));
