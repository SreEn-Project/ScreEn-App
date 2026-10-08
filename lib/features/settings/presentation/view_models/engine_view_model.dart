import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/translator_settings.dart';
import 'api_key_view_model.dart';

part 'engine_view_model.g.dart';

/// 번역 엔진 선택 (FL-06). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
/// Gemini · Groq는 만 18세 확인(FL-09)과 API 키(NA-13)가 있어야 고를 수 있다.
@riverpod
class EngineViewModel extends _$EngineViewModel {
  @override
  Stream<EngineType> build() async* {
    yield (await ref.watch(getSettingsProvider)()).engine;
    yield* ref.watch(watchSettingsProvider)().map((s) => s.engine);
  }

  Future<void> select(EngineType engine) async {
    switch (engine) {
      case EngineType.mlKit:
        break;
      case EngineType.gemini || EngineType.groq:
        // 만 18세 확인(FL-09)과 그 엔진의 API 키(NA-13)가 모두 있어야 고를 수 있다.
        final settings = await ref.read(getSettingsProvider)();
        if (!settings.ageConfirmed) return;
        if (await ref.read(apiKeyViewModelProvider(engine).future) == null) {
          return;
        }
    }
    await ref.read(changeEngineProvider)(engine);
  }
}
