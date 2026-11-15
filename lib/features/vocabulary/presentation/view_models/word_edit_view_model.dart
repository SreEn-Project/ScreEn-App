import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/usecases/vocabulary_usecases.dart';

part 'word_edit_view_model.g.dart';

/// 단어 편집 시트(AD-03)의 저장 동작. 직접 추가 · 기록에서 추가가 같이 쓴다.
/// 시트가 닫히는 동안에도 여러 번 await 하며 쓰므로 살려 둔다 (상태가 없는 동작 모음이라 비용이 없다).
@Riverpod(keepAlive: true)
class WordEditViewModel extends _$WordEditViewModel {
  @override
  void build() {}

  /// [wordbookId] 단어장에 저장하고 단어 id를 돌려준다. 단어 · 뜻이 비어 저장하지 못하면 null.
  Future<int?> save(int wordbookId, WordDraft draft) =>
      ref.read(saveWordProvider)(SaveWordParams(wordbookId, draft));

  /// 같은 단어(글자 · 언어쌍)가 이미 저장돼 있으면 그 단어. 저장 전에 뜻을 더할지 물을 때 쓴다.
  Future<VocabularyWord?> findSame(WordDraft draft) =>
      ref.read(findSameWordProvider)(FindSameWordParams(draft));

  /// 단어가 들어 있는 단어장 id.
  Future<List<int>> wordbookIds(int id) =>
      ref.read(getWordWordbookIdsProvider)(id);

  /// 단어 [wordId]에 뜻을 더한다. 비었거나 같은 뜻이 이미 있으면 false.
  Future<bool> addMeaning(int wordId, WordDraft draft) =>
      ref.read(addWordMeaningProvider)(MeaningParams(wordId, draft));

  /// 뜻 [meaningId]를 고친다. 비었거나 같은 단어의 다른 뜻과 겹치면 false.
  Future<bool> updateMeaning(int meaningId, WordDraft draft) =>
      ref.read(updateWordMeaningProvider)(MeaningParams(meaningId, draft));

  /// 저장된 단어 [id]의 내용을 고친다. 비었거나 같은 단어장의 다른 단어와 겹쳐 못 고치면 false.
  Future<bool> update(int id, WordDraft draft) =>
      ref.read(updateWordProvider)(UpdateWordParams(id, draft));
}
