import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/features/history/di.dart';
import 'package:translation_poc_app/features/history/domain/entities/history_entry.dart';
import 'package:translation_poc_app/features/history/presentation/view_models/history_view_model.dart';

import '../../fakes.dart';

HistoryEntry _entry(int id, String original, String translated, DateTime at) =>
    HistoryEntry(
      id: id,
      original: original,
      translated: translated,
      sourceLanguage: 'en',
      targetLanguage: 'ko',
      translatedAt: at,
    );

void main() {
  late FakeHistoryRepository repository;
  late ProviderContainer container;

  setUp(() {
    final now = DateTime.now();
    repository = FakeHistoryRepository([
      _entry(3, 'Hello', '안녕', now),
      _entry(2, 'Apple', '사과', now.subtract(const Duration(days: 3))),
      _entry(1, 'Old', '옛날', now.subtract(const Duration(days: 30))),
    ]);
    container = ProviderContainer(
      overrides: [historyRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen(historyViewModelProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  Future<HistoryState> ready() =>
      container.read(historyViewModelProvider.future);
  HistoryState now() => container.read(historyViewModelProvider).requireValue;
  HistoryViewModel viewModel() =>
      container.read(historyViewModelProvider.notifier);

  test('처음에는 기록 전체를 최신순으로 보여 준다', () async {
    expect((await ready()).entries.map((e) => e.id), [3, 2, 1]);
  });

  test('검색어는 원문과 번역 모두에서 찾는다', () async {
    await ready();
    await viewModel().setQuery('사과');
    expect(now().entries.map((e) => e.id), [2]);
    await viewModel().setQuery('hello');
    expect(now().entries.map((e) => e.id), [3]);
    expect(now().filtered, isTrue);
  });

  test('기간 필터: 오늘 · 이번 주', () async {
    await ready();
    await viewModel().setPeriod(HistoryPeriod.today);
    expect(now().entries.map((e) => e.id), [3]);
    await viewModel().setPeriod(HistoryPeriod.week);
    expect(now().entries.map((e) => e.id), [3, 2]);
  });

  test('한 줄 삭제는 목록과 저장소에서 지운다', () async {
    await ready();
    await viewModel().delete(3);
    expect(now().entries.map((e) => e.id), [2, 1]);
    expect(repository.entries.map((e) => e.id), [2, 1]);
  });

  test('전체 삭제는 조건과 상관없이 모두 지운다', () async {
    await ready();
    await viewModel().setQuery('사과');
    await viewModel().clear();
    expect(now().entries, isEmpty);
    expect(repository.entries, isEmpty);
  });
}
