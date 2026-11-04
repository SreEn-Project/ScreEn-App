import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/gemma/presentation/view_models/gemma_assist_view_model.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/domain/repositories/settings_repository.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockSettingsRepository();
    when(() => repository.watch()).thenAnswer((_) => const Stream.empty());
    when(() => repository.setGemmaFixOcr(any())).thenAnswer((_) async {});
    when(() => repository.setGemmaPolish(any())).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  Future<GemmaAssistOptions> ready([
    TranslatorSettings saved = const TranslatorSettings(),
  ]) {
    when(() => repository.load()).thenAnswer((_) async => saved);
    container.listen(gemmaAssistViewModelProvider, (_, _) {});
    return container.read(gemmaAssistViewModelProvider.future);
  }

  test('기본값은 둘 다 꺼짐', () async {
    final options = await ready();

    expect(options.fixOcr, isFalse);
    expect(options.polish, isFalse);
  });

  test('저장된 설정을 읽어 온다', () async {
    final options = await ready(
      const TranslatorSettings(gemmaFixOcr: true, gemmaPolish: true),
    );

    expect(options.fixOcr, isTrue);
    expect(options.polish, isTrue);
  });

  test('켜고 끄는 값을 저장소로 전달한다', () async {
    await ready();
    final viewModel = container.read(gemmaAssistViewModelProvider.notifier);

    await viewModel.setFixOcr(true);
    await viewModel.setPolish(true);

    verify(() => repository.setGemmaFixOcr(true)).called(1);
    verify(() => repository.setGemmaPolish(true)).called(1);
  });
}
