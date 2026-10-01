import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:translation_poc_app/features/settings/presentation/view_models/quick_languages_view_model.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockSettingsRepository();
    when(() => repository.watch()).thenAnswer((_) => const Stream.empty());
    when(() => repository.setQuickLanguages(any())).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  Future<List<String>> ready([List<String> saved = const ['ko', 'en']]) {
    when(() => repository.load())
        .thenAnswer((_) async => TranslatorSettings(quickLanguages: saved));
    container.listen(quickLanguagesViewModelProvider, (_, _) {});
    return container.read(quickLanguagesViewModelProvider.future);
  }

  test('처음에는 저장된 빠른 언어를 보여 준다', () async {
    expect(await ready(), ['ko', 'en']);
  });

  test('없는 언어를 누르면 끝에 추가한다', () async {
    await ready();

    await container.read(quickLanguagesViewModelProvider.notifier).toggle('ja');

    verify(() => repository.setQuickLanguages(['ko', 'en', 'ja'])).called(1);
  });

  test('있는 언어를 누르면 뺀다', () async {
    await ready();

    await container.read(quickLanguagesViewModelProvider.notifier).toggle('en');

    verify(() => repository.setQuickLanguages(['ko'])).called(1);
  });

  test('마지막 하나는 뺄 수 없다', () async {
    await ready(['ko']);

    await container.read(quickLanguagesViewModelProvider.notifier).toggle('ko');

    verifyNever(() => repository.setQuickLanguages(any()));
  });

  test('최대 개수를 넘게는 더할 수 없다', () async {
    final full = ['ko', 'en', 'ja', 'zh', 'fr', 'de', 'es', 'it'];
    await ready(full);

    await container.read(quickLanguagesViewModelProvider.notifier).toggle('ru');

    verifyNever(() => repository.setQuickLanguages(any()));
  });
}
