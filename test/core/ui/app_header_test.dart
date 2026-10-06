import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/theme/app_theme.dart';
import 'package:translation_poc_app/core/ui/ui.dart';

void main() {
  testWidgets('오른쪽 글자 버튼은 56px보다 넓어도 잘리지 않고 제목은 가운데에 있다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppHeader(
            title: '번역 기록',
            showBack: false,
            trailing: AppButton.text(label: '전체 삭제', onPressed: () {}),
          ),
        ),
      ),
    );

    final button = tester.getSize(find.byType(AppButton));
    expect(button.width, greaterThan(56));
    // 글자가 말줄임 없이 그려진다.
    final paragraph = tester.renderObject<RenderParagraph>(find.text('전체 삭제'));
    expect(paragraph.didExceedMaxLines, isFalse);

    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(
      tester.getCenter(find.text('번역 기록')).dx,
      closeTo(screen.width / 2, 0.5),
    );
  });
}
