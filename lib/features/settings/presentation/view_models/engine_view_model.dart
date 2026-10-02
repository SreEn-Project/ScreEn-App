import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/translator_settings.dart';

part 'engine_view_model.g.dart';

/// 번역 엔진 선택 (FL-06). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
/// AI 엔진은 보류라 선택할 수 없다 ([selectable]).
@riverpod
class EngineViewModel extends _$EngineViewModel {
  /// 지금 고를 수 있는 엔진. AI 엔진(Gemini · Firebase)은 3단계 + 보류.
  static const selectable = {EngineType.mlKit};

  @override
  Stream<EngineType> build() async* {
    yield (await ref.watch(getSettingsProvider)()).engine;
    yield* ref.watch(watchSettingsProvider)().map((s) => s.engine);
  }

  Future<void> select(EngineType engine) async {
    if (!selectable.contains(engine)) return;
    await ref.read(changeEngineProvider)(engine);
  }
}
