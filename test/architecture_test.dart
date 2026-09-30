import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 클린 아키텍처 의존 규칙 검사 (D-018).
/// - domain: 순수 Dart. Flutter · Bloc · get_it · Pigeon · 플러그인 · 다른 계층을 모른다.
/// - presentation: data를 직접 쓰지 않는다 (Bloc · Cubit은 생성자로 유스케이스를 받는다).
/// - presentation: DI 컨테이너(get_it)를 직접 꺼내 쓰지 않는다 (D-026).
void main() {
  Iterable<File> dartFiles(String dir) =>
      Directory(dir)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.endsWith('.g.dart'))
          .where((f) => !f.path.endsWith('.freezed.dart'));

  List<String> imports(File file) => file
      .readAsLinesSync()
      .where((l) => l.startsWith('import ') || l.startsWith('export '))
      .toList();

  List<String> violations(Iterable<File> files, bool Function(String) bad) => [
    for (final file in files)
      for (final line in imports(file))
        if (bad(line)) '${file.path}: $line',
  ];

  Iterable<File> layer(String name) =>
      Directory('lib/features')
          .listSync()
          .whereType<Directory>()
          .map((feature) => Directory('${feature.path}/$name'))
          .where((dir) => dir.existsSync())
          .expand((dir) => dartFiles(dir.path));

  test('domain은 순수 Dart다', () {
    const allowed = ['package:freezed_annotation/', 'package:meta/'];
    final files = [...layer('domain'), ...dartFiles('lib/core/domain')];

    final found = violations(files, (line) {
      if (line.contains("'dart:") && !line.contains("'dart:ui")) return false;
      if (line.contains("package:") && !allowed.any((p) => line.contains(p))) {
        return true;
      }
      return line.contains('/data/') ||
          line.contains('/presentation/') ||
          line.contains('/bridge/') ||
          line.contains('/di.dart');
    });

    expect(found, isEmpty);
  });

  test('presentation은 data를 직접 쓰지 않는다', () {
    final found = violations(
      layer('presentation'),
      (line) => line.contains('/data/') || line.contains('/bridge/'),
    );

    expect(found, isEmpty);
  });

  test('presentation은 DI 컨테이너를 직접 쓰지 않는다', () {
    final found = violations(
      layer('presentation'),
      (line) =>
          line.contains('package:get_it/') ||
          line.contains('/core/di/') ||
          line.contains('/di.dart'),
    );

    expect(found, isEmpty);
  });
}
