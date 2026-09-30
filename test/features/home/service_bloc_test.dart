import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/home/presentation/bloc/service_bloc.dart';
import 'package:translation_poc_app/features/service/domain/entities/service_status.dart';
import 'package:translation_poc_app/features/service/domain/repositories/service_repository.dart';
import 'package:translation_poc_app/features/service/domain/usecases/service_usecases.dart';

class _MockServiceRepository extends Mock implements ServiceRepository {}

void main() {
  late _MockServiceRepository repository;
  late StreamController<ServiceStatus> states;
  late ServiceBloc bloc;

  setUp(() {
    repository = _MockServiceRepository();
    states = StreamController<ServiceStatus>();
    when(() => repository.watchStatus()).thenAnswer((_) => states.stream);
    when(() => repository.start()).thenAnswer((_) async {});
    when(() => repository.stop()).thenAnswer((_) async {});
    bloc = ServiceBloc(
      getServiceStatus: GetServiceStatus(repository),
      watchServiceStatus: WatchServiceStatus(repository),
      startTranslationService: StartTranslationService(repository),
      stopTranslationService: StopTranslationService(repository),
    );
  });

  tearDown(() async {
    await bloc.close();
    // 구독하지 않은 테스트에서는 close가 끝나지 않으므로 기다리지 않는다.
    unawaited(states.close());
  });

  Future<void> settle(ServiceStatus initial) async {
    when(() => repository.currentStatus()).thenAnswer((_) async => initial);
    bloc.add(const ServiceSubscriptionRequested());
    await pumpEventQueue();
  }

  Future<void> toggle() async {
    bloc.add(const ServiceToggled());
    await pumpEventQueue();
  }

  test('처음 상태는 꺼짐이다', () {
    expect(bloc.state, ServiceStatus.stopped);
  });

  test('구독하면 네이티브의 현재 상태를 보여 준다', () async {
    await settle(ServiceStatus.running);

    expect(bloc.state, ServiceStatus.running);
  });

  test('네이티브 이벤트로 상태가 바뀐다 (알림에서 중지한 경우 등)', () async {
    await settle(ServiceStatus.running);

    states.add(ServiceStatus.stopped);
    await pumpEventQueue();

    expect(bloc.state, ServiceStatus.stopped);
  });

  test('꺼져 있을 때 toggle은 시작한다', () async {
    await settle(ServiceStatus.stopped);

    await toggle();

    verify(() => repository.start()).called(1);
    verifyNever(() => repository.stop());
  });

  test('오류 상태에서 toggle은 다시 시작한다', () async {
    await settle(ServiceStatus.error);

    await toggle();

    verify(() => repository.start()).called(1);
  });

  test('실행 중일 때 toggle은 중지한다', () async {
    await settle(ServiceStatus.running);

    await toggle();

    verify(() => repository.stop()).called(1);
    verifyNever(() => repository.start());
  });

  test('동의 대기 중에 toggle하면 동의 창을 다시 띄운다', () async {
    await settle(ServiceStatus.waitingConsent);

    await toggle();

    verify(() => repository.start()).called(1);
    verifyNever(() => repository.stop());
  });
}
