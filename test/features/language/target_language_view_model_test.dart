import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/language/presentation/view_models/target_language_view_model.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/domain/repositories/settings_repository.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockSettingsRepository();
    when(
      () => repository.load(),
    ).thenAnswer((_) async => const TranslatorSettings(targetLanguage: 'ja'));
    when(() => repository.watch()).thenAnswer((_) => const Stream.empty());
    when(() => repository.setTargetLanguage(any())).thenAnswer((_) async {});
    when(() => repository.setWifiOnlyModelDownload(any()))
        .thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  test('처음에는 저장된 대상 언어를 보여 준다', () async {
    container.listen(targetLanguageViewModelProvider, (_, _) {});
    expect(await container.read(targetLanguageViewModelProvider.future), 'ja');
  });

  test('언어를 고르면 설정에 저장한다', () async {
    await container.read(targetLanguageViewModelProvider.notifier).select('fr');

    verify(() => repository.setTargetLanguage('fr')).called(1);
  });

  test('Wi-Fi 전용 받기 스위치는 설정에 저장한다', () async {
    await container
        .read(wifiOnlyDownloadViewModelProvider.notifier)
        .setEnabled(false);

    verify(() => repository.setWifiOnlyModelDownload(false)).called(1);
  });
}
