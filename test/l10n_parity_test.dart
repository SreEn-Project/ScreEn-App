import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// FL-15: 한국어 · 영어 문구가 한쪽만 빠지거나 자리표시자가 어긋나지 않았는지 검사한다.
void main() {
  group('ARB (Flutter 화면 문구)', () {
    final en = _readArb('lib/l10n/app_en.arb');
    final ko = _readArb('lib/l10n/app_ko.arb');

    test('영어 · 한국어가 같은 키를 가진다', () {
      expect(ko.keys.toSet(), en.keys.toSet());
    });

    test('자리표시자가 두 언어에서 같다', () {
      for (final key in en.keys) {
        expect(
          _argsOf(ko[key]!),
          _argsOf(en[key]!),
          reason: '$key 의 자리표시자가 다름',
        );
      }
    });
  });

  group('strings.xml (네이티브 문구)', () {
    final base = _readStrings('android/app/src/main/res/values/strings.xml');
    final ko = _readStrings('android/app/src/main/res/values-ko/strings.xml');

    test('영어 · 한국어가 같은 이름을 가진다', () {
      expect(ko.keys.toSet(), base.keys.toSet());
    });

    test('서식 자리표시자가 두 언어에서 같다', () {
      for (final key in base.keys) {
        expect(
          _formatArgsOf(ko[key]!),
          _formatArgsOf(base[key]!),
          reason: '$key 의 서식 자리표시자가 다름',
        );
      }
    });
  });
}

Map<String, String> _readArb(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final e in json.entries)
      if (!e.key.startsWith('@')) e.key: e.value as String,
  };
}

Set<String> _argsOf(String text) =>
    RegExp(r'\{(\w+)').allMatches(text).map((m) => m.group(1)!).toSet();

Map<String, String> _readStrings(String path) {
  final xml = File(path).readAsStringSync();
  return {
    for (final m in RegExp(
      r'<string name="(\w+)"[^>]*>(.*?)</string>',
      dotAll: true,
    ).allMatches(xml))
      m.group(1)!: m.group(2)!,
  };
}

List<String> _formatArgsOf(String text) =>
    RegExp(r'%(\d+\$)?[sd]').allMatches(text).map((m) => m.group(0)!).toList()
      ..sort();
