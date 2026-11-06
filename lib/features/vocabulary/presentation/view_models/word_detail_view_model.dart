import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/usecases/vocabulary_usecases.dart';

part 'word_detail_view_model.g.dart';

/// 단어 상세 (AD-06). 단어가 없으면(이미 지워짐) null.
@riverpod
class WordDetailViewModel extends _$WordDetailViewModel {
  @override
  Future<VocabularyWord?> build(int id) => ref.watch(getWordProvider)(id);

  /// 수정 뒤 새로 읽는다.
  Future<void> reload() async {
    state = AsyncData(await ref.read(getWordProvider)(id));
  }

  Future<void> delete() => ref.read(deleteWordProvider)(id);

  /// 단어가 들어 있는 단어장 id.
  Future<List<int>> wordbookIds() => ref.read(getWordWordbookIdsProvider)(id);

  /// 다른 단어장에도 넣는다. 이미 있거나 그 단어장에 같은 글자의 단어가 있으면 false.
  Future<bool> addTo(int wordbookId) =>
      ref.read(addWordToWordbookProvider)(WordbookLinkParams(id, wordbookId));
}
