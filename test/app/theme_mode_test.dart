import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translation_poc_app/app/theme/theme_mode_provider.dart';

void main() {
  test('저장값이 없으면 라이트로 시작한다', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('고른 테마를 저장하고 다음 실행에서 다시 읽는다', () async {
    SharedPreferences.setMockInitialValues({});
    final first = ProviderContainer();
    addTearDown(first.dispose);
    await first.read(themeModeProvider.notifier).set(ThemeMode.dark);
    expect(first.read(themeModeProvider), ThemeMode.dark);

    final second = ProviderContainer();
    addTearDown(second.dispose);
    second.read(themeModeProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(second.read(themeModeProvider), ThemeMode.dark);
  });
}
