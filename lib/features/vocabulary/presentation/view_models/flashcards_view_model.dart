import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/usecases/vocabulary_usecases.dart';

part 'flashcards_view_model.g.dart';

/// 카드 학습 화면(L-02)의 상태.
class FlashcardsState {
  const FlashcardsState({
    required this.bookName,
    required this.deck,
    this.known = const [],
    this.unknown = const [],
  });

  final String bookName;

  /// 이번 회차에 넘길 카드 (무작위 순서).
  final List<VocabularyWord> deck;

  /// 이번 회차에 "외움"으로 넘긴 단어 · "못 외움"으로 넘긴 단어.
  final List<VocabularyWord> known;
  final List<VocabularyWord> unknown;

  int get doneCount => known.length + unknown.length;
  bool get finished => deck.isNotEmpty && doneCount >= deck.length;

  /// 지금 맨 위에 보이는 카드. 다 넘겼으면 null.
  VocabularyWord? get current =>
      finished || deck.isEmpty ? null : deck[doneCount];

  FlashcardsState copyWith({
    List<VocabularyWord>? deck,
    List<VocabularyWord>? known,
    List<VocabularyWord>? unknown,
  }) => FlashcardsState(
    bookName: bookName,
    deck: deck ?? this.deck,
    known: known ?? this.known,
    unknown: unknown ?? this.unknown,
  );
}

/// 카드 학습 (AD-08): 카드를 한 장씩 넘기며 외움 · 못 외움을 기록하고, 결과에서 못 외운 단어만 다시 본다.
@riverpod
class FlashcardsViewModel extends _$FlashcardsViewModel {
  @override
  Future<FlashcardsState> build(int wordbookId) async {
    final books = await ref.watch(getWordbooksProvider)();
    final book = books.where((b) => b.id == wordbookId).firstOrNull;
    final deck = await ref.read(createFlashcardDeckProvider)(
      CreateFlashcardDeckParams(wordbookId),
    );
    return FlashcardsState(bookName: book?.name ?? '', deck: deck);
  }

  /// 맨 위 카드를 넘기며 [memorized]로 기록한다 (단어장 상세의 외운 표시에도 반영).
  Future<void> mark({required bool memorized}) async {
    final current = state.value;
    final word = current?.current;
    if (current == null || word == null) return;
    state = AsyncData(
      memorized
          ? current.copyWith(known: [...current.known, word])
          : current.copyWith(unknown: [...current.unknown, word]),
    );
    await ref.read(setWordMemorizedProvider)(
      SetMemorizedParams(word.id, memorized: memorized),
    );
  }

  /// 못 외운 단어만 다시 본다.
  void reviewUnknown() {
    final current = state.value;
    if (current == null || current.unknown.isEmpty) return;
    state = AsyncData(
      FlashcardsState(
        bookName: current.bookName,
        deck: [...current.unknown]..shuffle(),
      ),
    );
  }

  /// 단어장 전체를 처음부터 다시 본다.
  Future<void> restart() async {
    final current = state.value;
    if (current == null) return;
    final deck = await ref.read(createFlashcardDeckProvider)(
      CreateFlashcardDeckParams(wordbookId),
    );
    state = AsyncData(FlashcardsState(bookName: current.bookName, deck: deck));
  }
}
