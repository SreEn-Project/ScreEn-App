import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/permission/di.dart';
import 'package:translation_poc_app/features/permission/domain/entities/app_permissions.dart';
import 'package:translation_poc_app/features/permission/domain/repositories/permission_repository.dart';
import 'package:translation_poc_app/features/permission/presentation/view_models/permission_view_model.dart';

class _MockPermissionRepository extends Mock implements PermissionRepository {}

void main() {
  late _MockPermissionRepository repository;
  late ProviderContainer container;

  const none = AppPermissions(overlay: false, notification: false);
  const all = AppPermissions(overlay: true, notification: true);

  setUp(() {
    repository = _MockPermissionRepository();
    container = ProviderContainer(
      overrides: [permissionRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  test('처음에 현재 권한 상태를 확인한다', () async {
    when(() => repository.check()).thenAnswer((_) async => none);

    final state = await container.read(permissionViewModelProvider.future);

    expect(state.allGranted, isFalse);
  });

  test('알림 권한을 요청한 뒤 다시 확인한다', () async {
    var granted = false;
    when(() => repository.check()).thenAnswer(
      (_) async => AppPermissions(overlay: true, notification: granted),
    );
    when(() => repository.requestNotification()).thenAnswer((_) async {
      granted = true;
    });
    await container.read(permissionViewModelProvider.future);

    await container
        .read(permissionViewModelProvider.notifier)
        .requestNotification();

    verify(() => repository.requestNotification()).called(1);
    expect(container.read(permissionViewModelProvider).value, all);
  });

  test('다른 앱 위 표시 설정에서 돌아오면 다시 확인한다', () async {
    var overlay = false;
    when(() => repository.check()).thenAnswer(
      (_) async => AppPermissions(overlay: overlay, notification: true),
    );
    when(() => repository.requestOverlay()).thenAnswer((_) async {
      overlay = true;
    });
    await container.read(permissionViewModelProvider.future);

    await container.read(permissionViewModelProvider.notifier).requestOverlay();

    expect(
      container.read(permissionViewModelProvider).value?.allGranted,
      isTrue,
    );
  });

  test('refresh는 설정 앱에서 바뀐 권한을 반영한다', () async {
    var current = all;
    when(() => repository.check()).thenAnswer((_) async => current);
    await container.read(permissionViewModelProvider.future);

    current = none;
    await container.read(permissionViewModelProvider.notifier).refresh();

    expect(container.read(permissionViewModelProvider).value, none);
  });
}
