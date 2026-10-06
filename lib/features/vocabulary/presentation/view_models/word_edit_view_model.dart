import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/usecases/vocabulary_usecases.dart';

part 'word_edit_view_model.g.dart';

/// 단어 편집 시트(AD-03)의 저장 동작. 직접 추가 · 기록에서 추가가 같이 쓴다.
@riverpod
class WordEditViewModel extends _$WordEditViewModel {
  @override
  void build() {}

  /// [wordbookId] 단어장에 저장한다. 단어 · 뜻이 비어 저장하지 못하면 false.
  Future<bool> save(int wordbookId, WordDraft draft) async =>
      await ref.read(saveWordProvider)(SaveWordParams(wordbookId, draft)) !=
      null;
}
