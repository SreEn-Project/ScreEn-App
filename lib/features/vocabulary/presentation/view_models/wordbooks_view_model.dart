import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/usecases/vocabulary_usecases.dart';

part 'wordbooks_view_model.g.dart';

/// 단어장 목록 (AD-04): 만들기 · 이름 변경 · 삭제.
/// 오버레이에서 단어를 저장해도 이 화면은 열릴 때 다시 읽는다 ([refresh]).
@riverpod
class WordbooksViewModel extends _$WordbooksViewModel {
  @override
  Future<List<Wordbook>> build() => ref.watch(getWordbooksProvider)();

  Future<void> refresh() async {
    state = AsyncData(await ref.read(getWordbooksProvider)());
  }

  /// 만들고 목록을 다시 읽는다. 이름이 비어 만들지 못하면 null.
  Future<Wordbook?> create(String name) async {
    final created = await ref.read(createWordbookProvider)(name);
    if (created != null) await refresh();
    return created;
  }

  /// 이름이 비었거나 다른 단어장과 겹치면 false.
  Future<bool> rename(int id, String name) async {
    final done = await ref.read(renameWordbookProvider)(
      RenameWordbookParams(id, name),
    );
    if (done) await refresh();
    return done;
  }

  Future<void> delete(int id) async {
    final current = state.value ?? const [];
    state = AsyncData([
      for (final book in current)
        if (book.id != id) book,
    ]);
    await ref.read(deleteWordbookProvider)(id);
  }
}
