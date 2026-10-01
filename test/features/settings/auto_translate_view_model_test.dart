import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:translation_poc_app/features/settings/presentation/view_models/auto_translate_view_model.dart';
import 'package:translation_poc_app/features/settings/presentation/view_models/hide_after_interaction_view_model.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockSettingsRepository();
    when(() => repository.watch()).thenAnswer((_) => const Stream.empty());
    when(() => repository.setAutoTranslate(any())).thenAnswer((_) async {});
    when(() => repository.setAutoShowDelayMs(any())).thenAnswer((_) async {});
    when(() => repository.setHideAfterInteractionMs(any()))
        .thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  Future<AutoTranslateSettings> ready([
    TranslatorSettings saved = const TranslatorSettings(),
  ]) {
    when(() => repository.load()).thenAnswer((_) async => saved);
    container.listen(autoTranslateViewModelProvider, (_, _) {});
    return container.read(autoTranslateViewModelProvider.future);
  }

  test('기본값은 꺼짐, 새 번역은 되는 대로 바로', () async {
    final s = await ready();

    expect(s.enabled, isFalse);
    expect(s.showDelayMs, 0);
  });

  test('저장된 값을 보여 준다', () async {
    final s = await ready(
      const TranslatorSettings(autoTranslate: true, autoShowDelayMs: 2000),
    );

    expect(s.enabled, isTrue);
    expect(s.showDelayMs, 2000);
  });

  test('켜고 끄기는 저장소로 전달된다', () async {
    await ready();

    await container
        .read(autoTranslateViewModelProvider.notifier)
        .setEnabled(true);

    verify(() => repository.setAutoTranslate(true)).called(1);
  });

  test('표시 시점은 가장 가까운 선택지로 맞춰 저장한다', () async {
    await ready();
    final viewModel = container.read(autoTranslateViewModelProvider.notifier);

    await viewModel.setShowDelay(0);
    await viewModel.setShowDelay(1400);
    await viewModel.setShowDelay(9000);

    verify(() => repository.setAutoShowDelayMs(0)).called(1);
    verify(() => repository.setAutoShowDelayMs(1000)).called(1);
    verify(() => repository.setAutoShowDelayMs(3000)).called(1);
  });

  test('조작 뒤 숨김 시간은 자동 번역과 따로 저장하고, 음수는 숨기지 않음, 나머지는 가장 가까운 선택지로', () async {
    when(() => repository.load())
        .thenAnswer((_) async => const TranslatorSettings());
    container.listen(hideAfterInteractionViewModelProvider, (_, _) {});
    expect(
      await container.read(hideAfterInteractionViewModelProvider.future),
      defaultHideAfterInteractionMs,
    );
    final viewModel = container.read(
      hideAfterInteractionViewModelProvider.notifier,
    );

    await viewModel.setHide(-5);
    await viewModel.setHide(700);

    verify(() => repository.setHideAfterInteractionMs(hideNever)).called(1);
    verify(() => repository.setHideAfterInteractionMs(500)).called(1);
  });

  test('nearestChoice는 가까운 값을 고르고 같은 거리면 앞쪽을 고른다', () {
    expect(
      nearestChoice(hideAfterInteractionChoicesMs.sublist(0, 4), 700),
      500,
    );
    expect(
      nearestChoice(hideAfterInteractionChoicesMs.sublist(0, 4), 750),
      500,
    );
  });
}
