import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/di.dart';
import '../../../settings/domain/entities/translator_settings.dart';

part 'gemma_assist_view_model.g.dart';

/// Gemma 도우미 설정 (#176): 번역 후 단어 · 말투 검토. 원본은 네이티브 설정이라
/// 바꾸면 이벤트로 돌아와 화면이 갱신된다.
@riverpod
class GemmaAssistViewModel extends _$GemmaAssistViewModel {
  @override
  Stream<GemmaAssistOptions> build() async* {
    yield GemmaAssistOptions.of(await ref.watch(getSettingsProvider)());
    yield* ref.watch(watchSettingsProvider)().map(GemmaAssistOptions.of);
  }

  Future<void> setPolish(bool enabled) =>
      ref.read(changeGemmaPolishProvider)(enabled);
}

/// 화면이 쓰는 Gemma 도우미 옵션.
class GemmaAssistOptions {
  const GemmaAssistOptions({this.polish = false});

  factory GemmaAssistOptions.of(TranslatorSettings s) =>
      GemmaAssistOptions(polish: s.gemmaPolish);

  final bool polish;
}
