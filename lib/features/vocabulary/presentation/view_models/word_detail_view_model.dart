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

  /// 다른 단어장으로 옮기고 새로 읽는다.
  Future<void> move(int toWordbookId) async {
    await ref.read(moveWordProvider)(MoveWordParams(id, toWordbookId));
    state = AsyncData(await ref.read(getWordProvider)(id));
  }
}
