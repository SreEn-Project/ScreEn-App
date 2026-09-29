import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import 'language_list.dart';

/// 설정에서 여는 대상 언어 선택 (FL-04).
/// UI 퍼블리싱 단계: 고르면 닫히기만 하고 저장은 기능 연결 때 SettingsRepository로 한다.
class LanguagePickerScreen extends StatelessWidget {
  const LanguagePickerScreen({super.key, this.selectedCode = 'ko'});

  final String selectedCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.languagePickerTitle)),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: LanguageList(
            selectedCode: selectedCode,
            onSelected: (language) => context.pop(language.code),
          ),
        ),
      ),
    );
  }
}
