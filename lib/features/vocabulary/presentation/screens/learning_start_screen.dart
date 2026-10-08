import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/vocabulary.dart';
import '../view_models/wordbooks_view_model.dart';
import '../widgets/vocabulary_sheets.dart';
import '../widgets/wordbook_selector.dart';

/// 학습 시작 (L-01, AD-07): 학습할 단어장을 고르고 학습 유형을 고른다.
/// 암기 테스트(AD-09) · 카드 학습(AD-08)이 열려 있고 선 잇기(AD-11) · 하강형 타이핑(AD-12) · 단어 조립(AD-13)이 열려 있다.
class LearningStartScreen extends ConsumerStatefulWidget {
  const LearningStartScreen({super.key, this.initialWordbookId});

  /// 미리 골라 둘 단어장 (단어장 상세에서 들어올 때).
  final int? initialWordbookId;

  @override
  ConsumerState<LearningStartScreen> createState() =>
      _LearningStartScreenState();
}

class _LearningStartScreenState extends ConsumerState<LearningStartScreen> {
  Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    final initial = widget.initialWordbookId;
    if (initial != null) _selectedIds = {initial};
  }

  /// 고른 단어장 중 실제로 있는 것. 하나도 없으면 첫 단어장.
  WordbookSelection _selection(List<Wordbook> books) {
    final ids = {
      for (final b in books)
        if (_selectedIds.contains(b.id)) b.id,
    };
    if (ids.isEmpty && books.isNotEmpty) ids.add(books.first.id);
    return WordbookSelection(ids);
  }

  Future<void> _pick(List<Wordbook> books, WordbookSelection selection) async {
    final picked = await showWordbookMultiPickerSheet(
      context,
      books: books,
      selectedIds: selection.ids.toSet(),
      title: AppLocalizations.of(context).learnPickBook,
    );
    if (picked != null && mounted) {
      setState(() => _selectedIds = picked.toSet());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final books = ref.watch(wordbooksViewModelProvider).value;
    final selection = books == null ? null : _selection(books);
    final selected = books == null ? null : selection!.summarize(books);

    Widget body;
    if (books == null) {
      body = const SizedBox.shrink();
    } else if (books.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.only(top: AppTokens.sectionGap),
        child: Column(
          children: [
            const IconBadge(icon: Symbols.menu_book_rounded, size: 48),
            const SizedBox(height: AppTokens.space12),
            Text(l10n.learnNoBooks, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTokens.space4),
            Text(
              l10n.learnNoBooksHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    } else {
      final count = selected?.wordCount ?? 0;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(l10n.learnBook),
          const SizedBox(height: AppTokens.sectionTitleGap),
          WordbookSelector(
            label: selected?.name ?? '',
            count: selected?.wordCount,
            onTap: () => _pick(books, selection!),
          ),
          if (selected != null) ...[
            const SizedBox(height: AppTokens.space12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.sectionTitleIndent,
              ),
              child: Text(
                l10n.learnBookStats(
                  selected.wordCount,
                  selected.memorizedCount,
                ),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
          const SizedBox(height: AppTokens.sectionGap),
          SectionTitle(l10n.learnTypes),
          const SizedBox(height: AppTokens.sectionTitleGap),
          AppCard(
            padding: const EdgeInsets.symmetric(
              vertical: AppTokens.cardListPaddingV,
            ),
            child: Column(
              children: [
                AppListTile(
                  icon: Symbols.quiz_rounded,
                  title: l10n.learnTest,
                  subtitle: count == 0
                      ? l10n.learnTestNeedWords
                      : l10n.learnTestHint,
                  enabled: count > 0,
                  onTap: selected == null
                      ? null
                      : () => context.push(
                          AppRoutes.wordTestPath(selection!.ids),
                        ),
                ),
                const AppDivider(),
                AppListTile(
                  icon: Symbols.style_rounded,
                  title: l10n.learnCards,
                  subtitle: count == 0
                      ? l10n.learnTestNeedWords
                      : l10n.learnCardsHint,
                  enabled: count > 0,
                  onTap: selected == null
                      ? null
                      : () => context.push(
                          AppRoutes.flashcardsPath(selection!.ids),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.sectionGap),
          SectionTitle(l10n.learnGames),
          const SizedBox(height: AppTokens.sectionTitleGap),
          AppCard(
            padding: const EdgeInsets.symmetric(
              vertical: AppTokens.cardListPaddingV,
            ),
            child: Column(
              children: [
                AppListTile(
                  icon: Symbols.cable_rounded,
                  title: l10n.learnMatch,
                  subtitle: count == 0
                      ? l10n.learnTestNeedWords
                      : l10n.learnMatchHint,
                  enabled: count > 0,
                  onTap: selected == null
                      ? null
                      : () => context.push(
                          AppRoutes.lineMatchPath(selection!.ids),
                        ),
                ),
                const AppDivider(),
                AppListTile(
                  icon: Symbols.keyboard_rounded,
                  title: l10n.learnFall,
                  subtitle: count == 0
                      ? l10n.learnTestNeedWords
                      : l10n.learnFallHint,
                  enabled: count > 0,
                  onTap: selected == null
                      ? null
                      : () =>
                            context.push(AppRoutes.fallingPath(selection!.ids)),
                ),
                const AppDivider(),
                AppListTile(
                  icon: Symbols.extension_rounded,
                  title: l10n.learnAssemble,
                  subtitle: count == 0
                      ? l10n.learnTestNeedWords
                      : l10n.learnAssembleHint,
                  enabled: count > 0,
                  onTap: selected == null
                      ? null
                      : () => context.push(
                          AppRoutes.assemblyPath(selection!.ids),
                        ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return AppPage(title: l10n.learnTitle, children: [body]);
  }
}
