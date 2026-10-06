import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/daily_word.dart';
import '../../domain/usecases/vocabulary_usecases.dart';

part 'word_of_the_day_view_model.g.dart';

/// 홈의 오늘의 단어 카드(AD-14) 상태. 저장한 단어가 없으면 [daily]가 null이고 카드를 숨긴다.
class WordOfTheDayState {
  const WordOfTheDayState({
    this.daily,
    this.skip = 0,
    this.picked,
    this.revealed = false,
  });

  final DailyWord? daily;
  final int skip;

  /// 고른 보기. 아직 안 골랐으면 null.
  final String? picked;

  /// 보기 없이 뜻을 확인한 경우.
  final bool revealed;

  /// 답했거나 뜻을 확인해서 뜻을 보여 주는 중.
  bool get answered => picked != null || revealed;

  bool get correct => picked != null && picked == daily?.word.meaning;
}

/// 오늘의 단어 (AD-14).
@riverpod
class WordOfTheDayViewModel extends _$WordOfTheDayViewModel {
  @override
  Future<WordOfTheDayState> build() => _load(0);

  Future<WordOfTheDayState> _load(int skip) async {
    final daily = await ref.read(getWordOfTheDayProvider)(
      GetWordOfTheDayParams(DateTime.now(), skip: skip),
    );
    return WordOfTheDayState(daily: daily, skip: skip);
  }

  void answer(String choice) {
    final current = state.value;
    if (current == null || current.answered || current.daily == null) return;
    state = AsyncData(
      WordOfTheDayState(
        daily: current.daily,
        skip: current.skip,
        picked: choice,
      ),
    );
  }

  void reveal() {
    final current = state.value;
    if (current == null || current.answered || current.daily == null) return;
    state = AsyncData(
      WordOfTheDayState(
        daily: current.daily,
        skip: current.skip,
        revealed: true,
      ),
    );
  }

  /// 다른 단어로 바꾼다.
  Future<void> another() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(await _load(current.skip + 1));
  }
}
