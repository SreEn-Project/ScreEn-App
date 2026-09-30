import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/permission/domain/entities/app_permissions.dart';
import 'package:translation_poc_app/features/permission/domain/repositories/permission_repository.dart';
import 'package:translation_poc_app/features/permission/domain/usecases/permission_usecases.dart';
import 'package:translation_poc_app/features/permission/presentation/bloc/permission_cubit.dart';

class _MockPermissionRepository extends Mock implements PermissionRepository {}

void main() {
  late _MockPermissionRepository repository;
  late PermissionCubit cubit;

  const none = AppPermissions(overlay: false, notification: false);
  const all = AppPermissions(overlay: true, notification: true);

  setUp(() {
    repository = _MockPermissionRepository();
    cubit = PermissionCubit(
      checkPermissions: CheckPermissions(repository),
      requestNotificationPermission: RequestNotificationPermission(repository),
      requestOverlayPermission: RequestOverlayPermission(repository),
    );
  });

  tearDown(() => cubit.close());

  test('확인 전에는 상태가 없다 (홈 시작 버튼을 막지 않는다)', () {
    expect(cubit.state, isNull);
  });

  test('refresh는 현재 권한 상태를 확인한다', () async {
    when(() => repository.check()).thenAnswer((_) async => none);

    await cubit.refresh();

    expect(cubit.state?.allGranted, isFalse);
  });

  test('알림 권한을 요청한 뒤 다시 확인한다', () async {
    var granted = false;
    when(() => repository.check()).thenAnswer(
      (_) async => AppPermissions(overlay: true, notification: granted),
    );
    when(() => repository.requestNotification()).thenAnswer((_) async {
      granted = true;
    });
    await cubit.refresh();

    await cubit.requestNotification();

    verify(() => repository.requestNotification()).called(1);
    expect(cubit.state, all);
  });

  test('다른 앱 위 표시 설정에서 돌아오면 다시 확인한다', () async {
    var overlay = false;
    when(() => repository.check()).thenAnswer(
      (_) async => AppPermissions(overlay: overlay, notification: true),
    );
    when(() => repository.requestOverlay()).thenAnswer((_) async {
      overlay = true;
    });
    await cubit.refresh();

    await cubit.requestOverlay();

    expect(cubit.state?.allGranted, isTrue);
  });

  test('refresh는 설정 앱에서 바뀐 권한을 반영한다', () async {
    var current = all;
    when(() => repository.check()).thenAnswer((_) async => current);
    await cubit.refresh();

    current = none;
    await cubit.refresh();

    expect(cubit.state, none);
  });

  test('닫힌 뒤 늦게 온 결과는 무시한다', () async {
    when(() => repository.check()).thenAnswer((_) async => all);
    final pending = cubit.refresh();
    await cubit.close();

    await expectLater(pending, completes);
  });
}
