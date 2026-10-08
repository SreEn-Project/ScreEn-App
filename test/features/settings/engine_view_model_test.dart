import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:translation_poc_app/features/settings/presentation/view_models/engine_view_model.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository repository;
  late ProviderContainer container;

  setUpAll(() => registerFallbackValue(EngineType.mlKit));

  setUp(() {
    repository = _MockSettingsRepository();
    when(() => repository.watch()).thenAnswer((_) => const Stream.empty());
    when(() => repository.setEngine(any())).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  Future<EngineType> ready([
    TranslatorSettings saved = const TranslatorSettings(),
  ]) {
    when(() => repository.load()).thenAnswer((_) async => saved);
    container.listen(engineViewModelProvider, (_, _) {});
    return container.read(engineViewModelProvider.future);
  }

  test('기본값은 ML Kit', () async {
    expect(await ready(), EngineType.mlKit);
  });

  test('저장된 엔진을 보여 준다', () async {
    expect(
      await ready(const TranslatorSettings(engine: EngineType.gemini)),
      EngineType.gemini,
    );
  });

  test('ML Kit 선택은 저장소로 전달된다', () async {
    await ready();

    await container
        .read(engineViewModelProvider.notifier)
        .select(EngineType.mlKit);

    verify(() => repository.setEngine(EngineType.mlKit)).called(1);
  });

  test('Gemini는 키가 없으면 선택해도 저장하지 않는다', () async {
    when(() => repository.getApiKey(any())).thenAnswer((_) async => null);
    await ready(const TranslatorSettings(ageConfirmed: true));
    final viewModel = container.read(engineViewModelProvider.notifier);

    await viewModel.select(EngineType.gemini);

    verifyNever(() => repository.setEngine(any()));
  });

  test('Gemini는 연령 확인이 없으면 키가 있어도 저장하지 않는다 (FL-09)', () async {
    when(() => repository.getApiKey(any())).thenAnswer((_) async => 'k');
    await ready();

    await container
        .read(engineViewModelProvider.notifier)
        .select(EngineType.gemini);

    verifyNever(() => repository.setEngine(any()));
  });

  test('Groq는 자기 키가 없으면 Gemini 키가 있어도 저장하지 않는다', () async {
    when(() => repository.getApiKey(any())).thenAnswer((_) async => null);
    when(() => repository.getApiKey(EngineType.gemini))
        .thenAnswer((_) async => 'k');
    await ready(const TranslatorSettings(ageConfirmed: true));

    await container
        .read(engineViewModelProvider.notifier)
        .select(EngineType.groq);

    verifyNever(() => repository.setEngine(any()));
  });

  test('Groq는 연령 확인과 키가 있으면 선택된다', () async {
    when(() => repository.getApiKey(any())).thenAnswer((_) async => 'gsk_k');
    await ready(const TranslatorSettings(ageConfirmed: true));

    await container
        .read(engineViewModelProvider.notifier)
        .select(EngineType.groq);

    verify(() => repository.setEngine(EngineType.groq)).called(1);
  });

  test('Gemini는 연령 확인과 키가 있으면 선택된다', () async {
    when(() => repository.getApiKey(any())).thenAnswer((_) async => "k");
    await ready(const TranslatorSettings(ageConfirmed: true));

    await container
        .read(engineViewModelProvider.notifier)
        .select(EngineType.gemini);

    verify(() => repository.setEngine(EngineType.gemini)).called(1);
  });
}
