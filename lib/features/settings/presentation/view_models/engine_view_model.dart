import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/translator_settings.dart';
import 'api_key_view_model.dart';

part 'engine_view_model.g.dart';

/// 번역 엔진 선택 (FL-06). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
/// Gemini는 API 키가 등록돼 있어야 고를 수 있다 (NA-13). Firebase AI는 보류.
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
      case EngineType.gemini:
        if (await ref.read(apiKeyViewModelProvider.future) == null) return;
      case EngineType.firebaseAi:
        return;
    }
    await ref.read(changeEngineProvider)(engine);
  }
}
