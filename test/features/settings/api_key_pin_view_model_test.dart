import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/presentation/view_models/api_key_pin_view_model.dart';
import 'package:translation_poc_app/features/settings/presentation/view_models/api_key_view_model.dart';

import '../../fakes.dart';

void main() {
  late FakeSettingsRepository repository;
  late ProviderContainer container;

  ApiKeyPinViewModel vm() =>
      container.read(apiKeyPinViewModelProvider.notifier);
  ApiKeyPinState? state() => container.read(apiKeyPinViewModelProvider).value;

  Future<void> start({String? pin}) async {
    repository = FakeSettingsRepository()..apiKeyPin = pin;
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen(apiKeyPinViewModelProvider, (_, _) {});
    await container.read(apiKeyPinViewModelProvider.future);
  }

  tearDown(() => container.dispose());

  test('PIN이 없으면 처음부터 풀린 상태', () async {
    await start();
    expect(state()!.enabled, isFalse);
    expect(state()!.unlocked, isTrue);
  });

  test('PIN이 있으면 잠겨 있고, 틀린 PIN은 풀지 못한다', () async {
    await start(pin: '1234');
    expect(state()!.unlocked, isFalse);

    expect(await vm().unlock('0000'), isFalse);
    expect(state()!.unlocked, isFalse);

    expect(await vm().unlock('1234'), isTrue);
    expect(state()!.unlocked, isTrue);
  });

  test('PIN을 켜면 저장되고 풀린 상태로 둔다', () async {
    await start();
    expect(await vm().enable('4321'), isTrue);
    expect(repository.apiKeyPin, '4321');
    expect(state()!.enabled, isTrue);
    expect(state()!.unlocked, isTrue);
  });

  test('PIN 변경은 현재 PIN이 맞아야 한다', () async {
    await start(pin: '1234');
    expect(await vm().change('0000', '5555'), isFalse);
    expect(repository.apiKeyPin, '1234');
    expect(await vm().change('1234', '5555'), isTrue);
    expect(repository.apiKeyPin, '5555');
  });

  test('PIN 끄기는 현재 PIN이 맞아야 한다', () async {
    await start(pin: '1234');
    expect(await vm().disable('0000'), isFalse);
    expect(state()!.enabled, isTrue);
    expect(await vm().disable('1234'), isTrue);
    expect(repository.apiKeyPin, isNull);
    expect(state()!.enabled, isFalse);
  });

  test('분실 초기화는 키와 PIN을 지우고 엔진을 ML Kit으로 되돌린다', () async {
    await start(pin: '1234');
    repository
      ..apiKey = 'secret'
      ..settings = repository.settings.copyWith(engine: EngineType.gemini);

    await vm().reset();

    expect(repository.apiKey, isNull);
    expect(repository.apiKeyPin, isNull);
    expect(repository.settings.engine, EngineType.mlKit);
    expect(state()!.enabled, isFalse);
    expect(state()!.unlocked, isTrue);
  });

  test('분실 초기화가 끝나면 모든 엔진의 키 상태가 이미 비워져 있다 (옛 값이 남지 않는다)', () async {
    await start(pin: '1234');
    repository
      ..apiKeys[EngineType.gemini] = 'g-key'
      ..apiKeys[EngineType.groq] = 'q-key';
    for (final e in aiKeyEngines) {
      container.listen(apiKeyViewModelProvider(e), (_, _) {});
      expect(
        await container.read(apiKeyViewModelProvider(e).future),
        isNotNull,
      );
    }

    await vm().reset();

    for (final e in aiKeyEngines) {
      final async = container.read(apiKeyViewModelProvider(e));
      expect(async.isLoading, isFalse);
      expect(async.value, isNull);
    }
  });
}
