import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/translator_settings.dart';

part 'api_key_view_model.g.dart';

/// 키를 쓰는 AI 엔진들.
final aiKeyEngines = [
  for (final e in EngineType.values)
    if (e.needsApiKey) e,
];

/// 모든 AI 엔진의 키를 저장소에서 다시 읽고, 다 읽을 때까지 기다린다.
/// 키가 밖에서(PIN 초기화 등) 바뀐 뒤, 화면이 갱신 중인 옛 값을 보지 않게 한다.
Future<void> reloadApiKeys(Ref ref) => Future.wait([
  for (final e in aiKeyEngines) ref.refresh(apiKeyViewModelProvider(e).future),
]);

/// 엔진([engine])별로 저장된 AI 번역 API 키 (NA-13). 없으면 null. 원본은 네이티브 Keystore 저장소다.
/// 화면은 이 값을 가려서 보여 주고, 눌러서 볼 수 있게 한다.
@riverpod
class ApiKeyViewModel extends _$ApiKeyViewModel {
  @override
  Future<String?> build(EngineType engine) =>
      ref.watch(getApiKeyProvider)(engine);

  /// 빈 값이면 저장하지 않고 false를 돌려준다. 이미 키가 있으면 바꾼다.
  Future<bool> save(String apiKey) async {
    final key = apiKey.trim();
    if (key.isEmpty) return false;
    await ref.read(saveApiKeyProvider)((engine: engine, apiKey: key));
    state = AsyncData(key);
    return true;
  }

  /// 입력한 키를 실제로 호출해 본다. 성공이면 null, 실패면 이유.
  Future<String?> test(String apiKey) =>
      ref.read(testApiKeyProvider)((engine: engine, apiKey: apiKey));

  /// 키를 지우면 이 엔진을 쓸 수 없으므로, 지금 이 엔진을 쓰고 있으면 ML Kit으로 되돌린다.
  Future<void> clear() async {
    await ref.read(clearApiKeyProvider)(engine);
    state = const AsyncData(null);
    final current = (await ref.read(getSettingsProvider)()).engine;
    if (current == engine) {
      await ref.read(changeEngineProvider)(EngineType.mlKit);
    }
  }
}
