import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/target_language_view_model.dart';
import '../widgets/language_list.dart';

/// 대상 언어 선택 (FL-04). 홈 · 언어 탭에서 연다. 고르면 바로 저장하고 닫는다.
class LanguagePickerScreen extends ConsumerWidget {
  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(targetLanguageViewModelProvider).value ?? 'ko';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: l10n.languagePickerTitle),
            const SizedBox(height: 8),
            Expanded(
              child: LanguageList(
                selectedCode: selected,
                onSelected: (language) async {
                  await ref
                      .read(targetLanguageViewModelProvider.notifier)
                      .select(language.code);
                  if (context.mounted) context.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
