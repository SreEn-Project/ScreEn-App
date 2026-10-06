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
/// 암기 테스트(AD-09) · 카드 학습(AD-08)이 열려 있고 미니게임은 준비 중이다.
class LearningStartScreen extends ConsumerStatefulWidget {
  const LearningStartScreen({super.key, this.initialWordbookId});

  /// 미리 골라 둘 단어장 (단어장 상세에서 들어올 때).
  final int? initialWordbookId;

  @override
  ConsumerState<LearningStartScreen> createState() =>
      _LearningStartScreenState();
}

class _LearningStartScreenState extends ConsumerState<LearningStartScreen> {
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialWordbookId;
  }

  Wordbook? _selected(List<Wordbook> books) =>
      books.where((b) => b.id == _selectedId).firstOrNull ?? books.firstOrNull;

  Future<void> _pick(List<Wordbook> books, Wordbook? selected) async {
    final picked = await showWordbookPickerSheet(
      context,
      books: books,
      selectedId: selected?.id,
      title: AppLocalizations.of(context).learnPickBook,
    );
    if (picked != null && mounted) setState(() => _selectedId = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final books = ref.watch(wordbooksViewModelProvider).value;
    final selected = books == null ? null : _selected(books);

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
            onTap: () => _pick(books, selected),
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
                      : () => context.push(AppRoutes.wordTestPath(selected.id)),
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
                      : () =>
                            context.push(AppRoutes.flashcardsPath(selected.id)),
                ),
                const AppDivider(),
                AppListTile(
                  icon: Symbols.sports_esports_rounded,
                  title: l10n.learnGames,
                  subtitle: l10n.learnComingSoon,
                  enabled: false,
                  onTap: () {},
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
