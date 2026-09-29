import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/core/bridge/translator_api.g.dart';
import 'package:translation_poc_app/features/home/presentation/service_view_model.dart';
import 'package:translation_poc_app/features/service/data/pigeon_service_repository.dart';
import 'package:translation_poc_app/features/service/domain/service_repository.dart';

class _MockServiceRepository extends Mock implements ServiceRepository {}

void main() {
  late _MockServiceRepository repository;
  late StreamController<ServiceState> states;
  late ProviderContainer container;

  setUp(() {
    repository = _MockServiceRepository();
    states = StreamController<ServiceState>();
    when(() => repository.watchState()).thenAnswer((_) => states.stream);
    when(() => repository.start()).thenAnswer((_) async {});
    when(() => repository.stop()).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [serviceRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
    states.close();
  });

  Future<ServiceState> settle(ServiceState initial) async {
    when(() => repository.currentState()).thenAnswer((_) async => initial);
    container.listen(serviceViewModelProvider, (_, _) {});
    return container.read(serviceViewModelProvider.future);
  }

  test('처음에는 네이티브의 현재 상태를 보여 준다', () async {
    expect(await settle(ServiceState.running), ServiceState.running);
  });

  test('네이티브 이벤트로 상태가 바뀐다 (알림에서 중지한 경우 등)', () async {
    await settle(ServiceState.running);

    states.add(ServiceState.stopped);
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(serviceViewModelProvider).value,
      ServiceState.stopped,
    );
  });

  test('꺼져 있을 때 toggle은 시작한다', () async {
    await settle(ServiceState.stopped);

    await container.read(serviceViewModelProvider.notifier).toggle();

    verify(() => repository.start()).called(1);
    verifyNever(() => repository.stop());
  });

  test('오류 상태에서 toggle은 다시 시작한다', () async {
    await settle(ServiceState.error);

    await container.read(serviceViewModelProvider.notifier).toggle();

    verify(() => repository.start()).called(1);
  });

  test('실행 중일 때 toggle은 중지한다', () async {
    await settle(ServiceState.running);

    await container.read(serviceViewModelProvider.notifier).toggle();

    verify(() => repository.stop()).called(1);
    verifyNever(() => repository.start());
  });

  test('동의 대기 중에는 toggle이 아무것도 하지 않는다', () async {
    await settle(ServiceState.starting);

    await container.read(serviceViewModelProvider.notifier).toggle();

    verifyNever(() => repository.start());
    verifyNever(() => repository.stop());
  });
}
