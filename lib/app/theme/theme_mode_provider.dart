import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'theme_mode';

/// 앱 테마(시스템 · 라이트 · 다크). 화면 모양만 정하는 값이라 기기에만 저장한다 (D-071, #188).
/// 처음(저장값 없음)에는 라이트. 저장소를 읽지 못해도 라이트로 동작한다.
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.light;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      final mode = ThemeMode.values.where((m) => m.name == saved).firstOrNull;
      if (mode != null && mode != state) state = mode;
    } catch (_) {
      // 저장소를 못 읽으면 기본(라이트)을 쓴다.
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {
      // 저장하지 못해도 이번 실행에서는 바뀐 채로 쓴다.
    }
  }
}
