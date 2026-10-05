import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/translator_settings.dart';

part 'api_key_view_model.g.dart';

/// 저장된 AI 번역 API 키 (NA-13). 없으면 null. 원본은 네이티브 Keystore 저장소다.
/// 화면은 이 값을 가려서 보여 주고, 눌러서 볼 수 있게 한다.
@riverpod
class ApiKeyViewModel extends _$ApiKeyViewModel {
  @override
  Future<String?> build() => ref.watch(getApiKeyProvider)();

  /// 빈 값이면 저장하지 않고 false를 돌려준다. 이미 키가 있으면 바꾼다.
  Future<bool> save(String apiKey) async {
    final key = apiKey.trim();
    if (key.isEmpty) return false;
    await ref.read(saveApiKeyProvider)(key);
    state = AsyncData(key);
    return true;
  }

  /// 키를 지우면 Gemini 엔진을 쓸 수 없으므로 ML Kit으로 되돌린다.
  Future<void> clear() async {
    await ref.read(clearApiKeyProvider)();
    state = const AsyncData(null);
    await ref.read(changeEngineProvider)(EngineType.mlKit);
  }
}
