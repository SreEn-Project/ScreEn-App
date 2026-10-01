import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';

part 'hide_after_interaction_view_model.g.dart';

/// 조작 뒤 이전 번역 숨김 시간 (ms, #35). 자동 번역과 무관하게 덮어쓰기 결과에 적용된다.
/// 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
@riverpod
class HideAfterInteractionViewModel extends _$HideAfterInteractionViewModel {
  @override
  Stream<int> build() async* {
    yield (await ref.watch(getSettingsProvider)()).hideAfterInteractionMs;
    yield* ref
        .watch(watchSettingsProvider)()
        .map((s) => s.hideAfterInteractionMs);
  }

  Future<void> setHide(int ms) =>
      ref.read(changeHideAfterInteractionProvider)(ms);
}
