import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/language_list.dart';

/// 대상 언어 선택 (FL-04). 홈 · 언어 탭에서 연다. 고른 언어 코드를 돌려주며 닫힌다.
/// UI 퍼블리싱 단계: 저장은 기능 연결 때 SettingsRepository로 한다.
class LanguagePickerScreen extends StatelessWidget {
  const LanguagePickerScreen({super.key, this.selectedCode = 'ko'});

  final String selectedCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: l10n.languagePickerTitle),
            const SizedBox(height: 8),
            Expanded(
              child: LanguageList(
                selectedCode: selectedCode,
                onSelected: (language) => context.pop(language.code),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
