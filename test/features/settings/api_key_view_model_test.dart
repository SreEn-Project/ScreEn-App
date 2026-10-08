import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:translation_poc_app/features/settings/presentation/view_models/api_key_view_model.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository repository;
  late ProviderContainer container;

  setUpAll(() => registerFallbackValue(EngineType.mlKit));

  setUp(() {
    repository = _MockSettingsRepository();
    when(() => repository.getApiKey(any())).thenAnswer((_) async => null);
    when(() => repository.setApiKey(any(), any())).thenAnswer((_) async {});
    when(() => repository.clearApiKey(any())).thenAnswer((_) async {});
    when(() => repository.setEngine(any())).thenAnswer((_) async {});
    when(() => repository.load()).thenAnswer(
      (_) async => const TranslatorSettings(engine: EngineType.gemini),
    );
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen(apiKeyViewModelProvider(EngineType.gemini), (_, _) {});
  });

  tearDown(() => container.dispose());

  test('저장된 키가 없으면 null', () async {
    expect(
      await container.read(apiKeyViewModelProvider(EngineType.gemini).future),
      isNull,
    );
  });

  test('키를 저장하면 앞뒤 공백을 걷어 전달하고 그 값이 보인다', () async {
    await container.read(apiKeyViewModelProvider(EngineType.gemini).future);

    final saved = await container
        .read(apiKeyViewModelProvider(EngineType.gemini).notifier)
        .save('  abc ');

    expect(saved, isTrue);
    verify(() => repository.setApiKey(EngineType.gemini, 'abc')).called(1);
    expect(
      container.read(apiKeyViewModelProvider(EngineType.gemini)).value,
      equals("abc"),
    );
  });

  test('빈 키는 저장하지 않는다', () async {
    await container.read(apiKeyViewModelProvider(EngineType.gemini).future);

    final saved = await container
        .read(apiKeyViewModelProvider(EngineType.gemini).notifier)
        .save('   ');

    expect(saved, isFalse);
    verifyNever(() => repository.setApiKey(any(), any()));
  });

  test('키를 지우면 엔진을 ML Kit으로 되돌린다', () async {
    await container.read(apiKeyViewModelProvider(EngineType.gemini).future);

    await container
        .read(apiKeyViewModelProvider(EngineType.gemini).notifier)
        .clear();

    verify(() => repository.clearApiKey(EngineType.gemini)).called(1);
    verify(() => repository.setEngine(EngineType.mlKit)).called(1);
    expect(
      container.read(apiKeyViewModelProvider(EngineType.gemini)).value,
      isNull,
    );
  });

  test('Groq 키는 Gemini 키와 따로 저장하고, 지울 때 Gemini 엔진은 그대로 둔다', () async {
    final groq = apiKeyViewModelProvider(EngineType.groq);
    container.listen(groq, (_, _) {});
    await container.read(groq.future);

    await container.read(groq.notifier).save('gsk_abc');
    verify(() => repository.setApiKey(EngineType.groq, 'gsk_abc')).called(1);

    await container.read(groq.notifier).clear();
    verify(() => repository.clearApiKey(EngineType.groq)).called(1);
    verifyNever(() => repository.setEngine(any()));
  });

  test('키 테스트는 앞뒤 공백을 걷어 저장소에 묻고 이유를 돌려준다', () async {
    when(() => repository.testApiKey(any(), any()))
        .thenAnswer((_) async => '(400) API key not valid');
    await container.read(apiKeyViewModelProvider(EngineType.gemini).future);

    final reason = await container
        .read(apiKeyViewModelProvider(EngineType.gemini).notifier)
        .test(' abc ');

    expect(reason, '(400) API key not valid');
    verify(() => repository.testApiKey(EngineType.gemini, 'abc')).called(1);
  });
}
