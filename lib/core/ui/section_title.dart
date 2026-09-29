import 'package:flutter/material.dart';

/// 섹션 제목 + 선택적 오른쪽 동작 (예: "전체 보기").
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.titleLarge),
        ),
        ?action,
      ],
    );
  }
}
