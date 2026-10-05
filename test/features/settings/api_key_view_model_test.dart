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
    when(() => repository.hasApiKey()).thenAnswer((_) async => false);
    when(() => repository.setApiKey(any())).thenAnswer((_) async {});
    when(() => repository.clearApiKey()).thenAnswer((_) async {});
    when(() => repository.setEngine(any())).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen(apiKeyViewModelProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  test('저장 여부를 보여 준다', () async {
    expect(await container.read(apiKeyViewModelProvider.future), isFalse);
  });

  test('키를 저장하면 앞뒤 공백을 걷어 전달하고 등록됨이 된다', () async {
    await container.read(apiKeyViewModelProvider.future);

    final saved = await container
        .read(apiKeyViewModelProvider.notifier)
        .save('  abc ');

    expect(saved, isTrue);
    verify(() => repository.setApiKey('abc')).called(1);
    expect(container.read(apiKeyViewModelProvider).value, isTrue);
  });

  test('빈 키는 저장하지 않는다', () async {
    await container.read(apiKeyViewModelProvider.future);

    final saved = await container
        .read(apiKeyViewModelProvider.notifier)
        .save('   ');

    expect(saved, isFalse);
    verifyNever(() => repository.setApiKey(any()));
  });

  test('키를 지우면 엔진을 ML Kit으로 되돌린다', () async {
    await container.read(apiKeyViewModelProvider.future);

    await container.read(apiKeyViewModelProvider.notifier).clear();

    verify(() => repository.clearApiKey()).called(1);
    verify(() => repository.setEngine(EngineType.mlKit)).called(1);
    expect(container.read(apiKeyViewModelProvider).value, isFalse);
  });
}
