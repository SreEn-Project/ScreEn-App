import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/bridge/bridge_providers.dart';
import 'data/datasources/history_native_data_source.dart';
import 'data/repositories/history_repository_impl.dart';
import 'domain/repositories/history_repository.dart';
import 'domain/usecases/history_usecases.dart';

part 'di.g.dart';

// 번역 기록 기능의 의존성 연결 (D-018). 테스트는 historyRepositoryProvider를 바꿔 끼운다.

@Riverpod(keepAlive: true)
HistoryRepository historyRepository(Ref ref) => HistoryRepositoryImpl(
  HistoryNativeDataSource(ref.watch(historyHostApiProvider)),
);

@riverpod
SearchHistory searchHistory(Ref ref) =>
    SearchHistory(ref.watch(historyRepositoryProvider));

@riverpod
DeleteHistoryEntry deleteHistoryEntry(Ref ref) =>
    DeleteHistoryEntry(ref.watch(historyRepositoryProvider));

@riverpod
ClearHistory clearHistory(Ref ref) =>
    ClearHistory(ref.watch(historyRepositoryProvider));
