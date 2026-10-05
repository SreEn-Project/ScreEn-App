import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/translator_settings.dart';

part 'api_key_view_model.g.dart';

/// AI 번역 API 키 등록 상태 (NA-13). 값은 네이티브 Keystore에만 있고, 여기선 저장 여부(bool)만 다룬다.
@riverpod
class ApiKeyViewModel extends _$ApiKeyViewModel {
  @override
  Future<bool> build() => ref.watch(hasApiKeyProvider)();

  /// 빈 값이면 저장하지 않고 false를 돌려준다.
  Future<bool> save(String apiKey) async {
    if (apiKey.trim().isEmpty) return false;
    await ref.read(saveApiKeyProvider)(apiKey);
    state = const AsyncData(true);
    return true;
  }

  /// 키를 지우면 Gemini 엔진을 쓸 수 없으므로 ML Kit으로 되돌린다.
  Future<void> clear() async {
    await ref.read(clearApiKeyProvider)();
    state = const AsyncData(false);
    await ref.read(changeEngineProvider)(EngineType.mlKit);
  }
}
