import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:translation_poc_app/features/settings/domain/usecases/settings_usecases.dart';
import 'package:translation_poc_app/features/settings/presentation/view_models/ai_options_view_model.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(AiTone.standard);
    registerFallbackValue(<GlossaryEntry>[]);
  });

  setUp(() {
    repository = _MockSettingsRepository();
    when(() => repository.watch()).thenAnswer((_) => const Stream.empty());
    when(() => repository.setAgeConfirmed(any())).thenAnswer((_) async {});
    when(() => repository.setAiTone(any())).thenAnswer((_) async {});
    when(() => repository.setGlossary(any())).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  Future<AiOptions> ready([
    TranslatorSettings saved = const TranslatorSettings(),
  ]) {
    when(() => repository.load()).thenAnswer((_) async => saved);
    container.listen(aiOptionsViewModelProvider, (_, _) {});
    return container.read(aiOptionsViewModelProvider.future);
  }

  List<GlossaryEntry> savedGlossary() =>
      verify(() => repository.setGlossary(captureAny())).captured.last
          as List<GlossaryEntry>;

  test('기본값: 확인 안 함 · 말투 기본 · 용어집 비어 있음', () async {
    final options = await ready();

    expect(options.ageConfirmed, isFalse);
    expect(options.tone, AiTone.standard);
    expect(options.glossary, isEmpty);
  });

  test('연령 확인 · 말투를 저장소로 전달한다', () async {
    await ready();
    final viewModel = container.read(aiOptionsViewModelProvider.notifier);

    await viewModel.setAgeConfirmed(true);
    await viewModel.setTone(AiTone.formal);

    verify(() => repository.setAgeConfirmed(true)).called(1);
    verify(() => repository.setAiTone(AiTone.formal)).called(1);
  });

  test('용어를 더하면 공백을 걷어 저장한다', () async {
    await ready();

    final result = await container
        .read(aiOptionsViewModelProvider.notifier)
        .addEntry('  Mana ', ' 마나 ');

    expect(result, AddGlossaryResult.added);
    expect(savedGlossary(), const [
      GlossaryEntry(source: 'Mana', target: '마나'),
    ]);
  });

  test('빈 값은 저장하지 않는다', () async {
    await ready();
    final viewModel = container.read(aiOptionsViewModelProvider.notifier);

    expect(await viewModel.addEntry('Mana', '  '), AddGlossaryResult.empty);
    expect(await viewModel.addEntry('', '마나'), AddGlossaryResult.empty);
    verifyNever(() => repository.setGlossary(any()));
  });

  test('같은 원문(대소문자 무시)은 번역어를 바꾼다', () async {
    await ready(
      const TranslatorSettings(
        glossary: [GlossaryEntry(source: 'Mana', target: '마나')],
      ),
    );

    await container
        .read(aiOptionsViewModelProvider.notifier)
        .addEntry('mana', '마력');

    expect(savedGlossary(), const [
      GlossaryEntry(source: 'mana', target: '마력'),
    ]);
  });

  test('가득 차면 새 용어는 저장하지 않고 full', () async {
    await ready(
      TranslatorSettings(
        glossary: [
          for (var i = 0; i < maxGlossaryEntries; i++)
            GlossaryEntry(source: 's$i', target: 't$i'),
        ],
      ),
    );

    final result = await container
        .read(aiOptionsViewModelProvider.notifier)
        .addEntry('new', '새');

    expect(result, AddGlossaryResult.full);
    verifyNever(() => repository.setGlossary(any()));
  });

  test('용어를 지우면 나머지만 저장한다', () async {
    const keep = GlossaryEntry(source: 'Quest', target: '퀘스트');
    const drop = GlossaryEntry(source: 'Mana', target: '마나');
    await ready(const TranslatorSettings(glossary: [drop, keep]));

    await container.read(aiOptionsViewModelProvider.notifier).removeEntry(drop);

    expect(savedGlossary(), const [keep]);
  });

  test('저장 전 정리: 중복 · 빈 칸을 빼고 길이를 제한한다', () async {
    final fake = _MockSettingsRepository();
    when(() => fake.setGlossary(any())).thenAnswer((_) async {});

    await ChangeGlossary(fake)([
      const GlossaryEntry(source: ' A ', target: ' a '),
      const GlossaryEntry(source: 'a', target: 'b'),
      const GlossaryEntry(source: '', target: 'x'),
      GlossaryEntry(source: 'L' * 100, target: 't'),
    ]);

    final saved =
        verify(() => fake.setGlossary(captureAny())).captured.single
            as List<GlossaryEntry>;
    expect(saved.length, 2);
    expect(saved.first, const GlossaryEntry(source: 'A', target: 'a'));
    expect(saved.last.source.length, maxGlossaryTextLength);
  });
}
