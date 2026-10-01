import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../language/presentation/widgets/language_list.dart';
import '../../domain/entities/translator_settings.dart';
import '../view_models/quick_languages_view_model.dart';

/// 빠른 언어 편집 (FL-04). 플로팅 버튼 길게 누르기 → "빠른 언어" 버블에 나올 언어를 고른다.
/// 누르면 켜지고 꺼진다. 최소 1개, 최대 [maxQuickLanguages]개.
class QuickLanguagesScreen extends ConsumerWidget {
  const QuickLanguagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected =
        ref.watch(quickLanguagesViewModelProvider).value ??
        defaultQuickLanguages;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: l10n.quickLanguagesTitle),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.pagePadding,
                4,
                AppTokens.pagePadding,
                12,
              ),
              child: Text(
                l10n.quickLanguagesHint(
                  selected.length,
                  maxQuickLanguages,
                  minQuickLanguages,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: LanguageList(
                selectedCodes: selected.toSet(),
                onSelected: (language) => ref
                    .read(quickLanguagesViewModelProvider.notifier)
                    .toggle(language.code),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
