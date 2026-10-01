import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/translator_settings.dart';

part 'quick_languages_view_model.g.dart';

/// 플로팅 버튼 "빠른 언어" 목록 편집 (FL-04). 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
@riverpod
class QuickLanguagesViewModel extends _$QuickLanguagesViewModel {
  @override
  Stream<List<String>> build() async* {
    yield (await ref.watch(getSettingsProvider)()).quickLanguages;
    yield* ref.watch(watchSettingsProvider)().map((s) => s.quickLanguages);
  }

  /// 목록에 있으면 빼고 없으면 끝에 넣는다. 최소 · 최대 개수를 넘는 변경은 무시한다.
  Future<void> toggle(String code) async {
    final current = state.value ?? defaultQuickLanguages;
    final next = current.contains(code)
        ? current.where((c) => c != code).toList()
        : [...current, code];
    if (next.length < minQuickLanguages || next.length > maxQuickLanguages) {
      return;
    }
    await ref.read(changeQuickLanguagesProvider)(next);
  }
}
