import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/translator_settings.dart';
import 'api_key_view_model.dart';

part 'api_key_pin_view_model.g.dart';

/// API 키 접근 PIN 상태 (NA-13). [enabled]면 [unlocked]가 되기 전에는 키를 보거나 고칠 수 없다.
/// 잠금 해제는 화면을 떠나면 사라진다 (provider가 화면과 함께 해제된다).
class ApiKeyPinState {
  const ApiKeyPinState({required this.enabled, required this.unlocked});

  final bool enabled;
  final bool unlocked;
}

@riverpod
class ApiKeyPinViewModel extends _$ApiKeyPinViewModel {
  @override
  Future<ApiKeyPinState> build() async {
    final enabled = await ref.watch(isApiKeyPinEnabledProvider)();
    return ApiKeyPinState(enabled: enabled, unlocked: !enabled);
  }

  /// PIN이 맞으면 잠금을 풀고 true.
  Future<bool> unlock(String pin) async {
    if (!await verify(pin)) return false;
    state = const AsyncData(ApiKeyPinState(enabled: true, unlocked: true));
    return true;
  }

  /// 잠금 상태는 건드리지 않고 PIN만 확인한다 (변경 · 끄기 전 확인).
  Future<bool> verify(String pin) => ref.read(verifyApiKeyPinProvider)(pin);

  /// PIN을 처음 켠다. 4자리 숫자가 아니면 false.
  Future<bool> enable(String pin) async {
    final ok = await ref.read(setApiKeyPinProvider)((
      newPin: pin,
      currentPin: null,
    ));
    if (ok) {
      state = const AsyncData(ApiKeyPinState(enabled: true, unlocked: true));
    }
    return ok;
  }

  /// 현재 PIN이 맞으면 새 PIN으로 바꾼다.
  Future<bool> change(String currentPin, String newPin) =>
      ref.read(setApiKeyPinProvider)((newPin: newPin, currentPin: currentPin));

  /// 현재 PIN이 맞으면 PIN을 끈다.
  Future<bool> disable(String currentPin) async {
    final ok = await ref.read(clearApiKeyPinProvider)(currentPin);
    if (ok) {
      state = const AsyncData(ApiKeyPinState(enabled: false, unlocked: true));
    }
    return ok;
  }

  /// PIN 분실: 키와 PIN을 지우고 AI 엔진은 ML Kit으로 되돌린다.
  Future<void> reset() async {
    await ref.read(resetApiKeyProtectionProvider)();
    await ref.read(changeEngineProvider)(EngineType.mlKit);
    ref.invalidate(apiKeyViewModelProvider);
    state = const AsyncData(ApiKeyPinState(enabled: false, unlocked: true));
  }
}
