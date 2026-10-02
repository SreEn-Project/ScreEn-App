import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/usecases/history_usecases.dart';

part 'history_view_model.g.dart';

/// 번역 기록 화면 상태 (FL-13): 검색어 · 기간 필터와 그에 맞는 기록.
class HistoryState {
  const HistoryState({
    this.query = '',
    this.period = HistoryPeriod.all,
    this.entries = const [],
  });

  final String query;
  final HistoryPeriod period;
  final List<HistoryEntry> entries;

  /// 검색어나 기간을 걸어서 비어 보이는 상태인지 (전체가 비어 있는 것과 구분해 안내하려고).
  bool get filtered => query.trim().isNotEmpty || period != HistoryPeriod.all;

  HistoryState copyWith({
    String? query,
    HistoryPeriod? period,
    List<HistoryEntry>? entries,
  }) => HistoryState(
    query: query ?? this.query,
    period: period ?? this.period,
    entries: entries ?? this.entries,
  );
}

@riverpod
class HistoryViewModel extends _$HistoryViewModel {
  // 검색어를 빠르게 바꿀 때 늦게 온 이전 결과가 덮어쓰지 않도록 가장 마지막 요청만 반영한다.
  int _request = 0;

  @override
  Future<HistoryState> build() async {
    final entries = await ref.watch(searchHistoryProvider)(
      const SearchHistoryParams(),
    );
    return HistoryState(entries: entries);
  }

  HistoryState get _current => state.value ?? const HistoryState();

  Future<void> setQuery(String query) =>
      _reload(_current.copyWith(query: query));

  Future<void> setPeriod(HistoryPeriod period) =>
      _reload(_current.copyWith(period: period));

  Future<void> _reload(HistoryState next) async {
    final request = ++_request;
    // 목록은 그대로 두고 조건만 먼저 반영한다 (입력이 끊기지 않게).
    state = AsyncData(next);
    final entries = await ref.read(searchHistoryProvider)(
      SearchHistoryParams(query: next.query, period: next.period),
    );
    if (request != _request) return;
    state = AsyncData(next.copyWith(entries: entries));
  }

  Future<void> delete(int id) async {
    final now = _current;
    state = AsyncData(
      now.copyWith(
        entries: [
          for (final entry in now.entries)
            if (entry.id != id) entry,
        ],
      ),
    );
    await ref.read(deleteHistoryEntryProvider)(id);
  }

  /// 기록을 전부 지운다 (검색 · 기간 조건과 상관없이).
  Future<void> clear() async {
    await ref.read(clearHistoryProvider)();
    state = AsyncData(_current.copyWith(entries: const []));
  }
}

const recentHistoryLimit = 3;

/// 홈 "최근 기록": 기간별 최신 몇 개. 홈이 다시 보일 때 invalidate해서 새로 읽는다.
@riverpod
Future<List<HistoryEntry>> recentHistory(Ref ref, HistoryPeriod period) =>
    ref.watch(searchHistoryProvider)(
      SearchHistoryParams(period: period, limit: recentHistoryLimit),
    );
