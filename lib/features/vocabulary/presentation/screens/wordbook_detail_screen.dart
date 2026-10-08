import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/vocabulary.dart';
import '../view_models/wordbook_detail_view_model.dart';
import '../view_models/wordbooks_view_model.dart';
import '../widgets/vocabulary_sheets.dart';
import '../widgets/word_card.dart';
import '../widgets/word_edit_sheet.dart';

/// 단어장 상세 (X-04, AD-05): 단어 검색 · 정렬 · 이동 · 삭제 · 외운 단어 체크, 탭하면 단어 상세.
class WordbookDetailScreen extends ConsumerWidget {
  const WordbookDetailScreen({super.key, required this.wordbookId});

  final int wordbookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = wordbookDetailViewModelProvider(wordbookId);
    final state = ref.watch(provider).value;
    final model = ref.read(provider.notifier);
    final name = ref
        .watch(wordbooksViewModelProvider)
        .value
        ?.where((book) => book.id == wordbookId)
        .firstOrNull
        ?.name;
    final words = state?.words ?? const <VocabularyWord>[];
    final sorts = {
      WordSort.newest: l10n.vocabSortNewest,
      WordSort.oldest: l10n.vocabSortOldest,
      WordSort.alphabetical: l10n.vocabSortAlphabetical,
      WordSort.accuracyHigh: l10n.vocabSortAccuracyHigh,
      WordSort.accuracyLow: l10n.vocabSortAccuracyLow,
    };
    final filters = {
      WordFilter.all: l10n.vocabFilterAll,
      WordFilter.notStudied: l10n.vocabFilterNotStudied,
      WordFilter.low: l10n.vocabFilterLow,
      WordFilter.mid: l10n.vocabFilterMid,
      WordFilter.high: l10n.vocabFilterHigh,
    };
    final sort = state?.sort ?? WordSort.newest;
    final filter = state?.filter ?? WordFilter.all;
    final book = ref
        .watch(wordbooksViewModelProvider)
        .value
        ?.where((b) => b.id == wordbookId)
        .firstOrNull;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: name ?? l10n.vocabTitle,
              trailing: AppIconButton(
                icon: Symbols.add_rounded,
                tooltip: l10n.vocabAddWord,
                plain: true,
                size: 44,
                onPressed: () => _addWord(context, model),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.pagePadding,
              ),
              child: AppSearchField(
                hint: l10n.vocabSearchHint,
                onChanged: model.setQuery,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.pagePadding,
                AppTokens.space12,
                AppTokens.pagePadding,
                AppTokens.space8,
              ),
              child: Row(
                children: [
                  AppPopupMenu<WordSort>(
                    icon: Symbols.swap_vert_rounded,
                    label: sorts[sort]!,
                    values: WordSort.values,
                    selected: sort,
                    itemLabel: (v) => sorts[v]!,
                    onSelected: model.setSort,
                  ),
                  const SizedBox(width: AppTokens.space8),
                  AppPopupMenu<WordFilter>(
                    icon: Symbols.filter_list_rounded,
                    label: filter == WordFilter.all
                        ? l10n.vocabFilterLabel
                        : filters[filter]!,
                    values: WordFilter.values,
                    selected: filter,
                    itemLabel: (v) => filters[v]!,
                    onSelected: model.setFilter,
                    active: filter != WordFilter.all,
                  ),
                  if (book != null && book.accuracy != null) ...[
                    const Spacer(),
                    Flexible(
                      child: Text(
                        l10n.vocabBookAccuracy(
                          (book.accuracy! * 100).round(),
                          book.correctCount,
                          book.attemptCount,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: words.isEmpty
                  ? Center(
                      child: state == null
                          ? const SizedBox.shrink()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const IconBadge(
                                  icon: Symbols.menu_book_rounded,
                                  size: 48,
                                ),
                                const SizedBox(height: AppTokens.space12),
                                Text(
                                  state.filtered
                                      ? l10n.vocabNoResult
                                      : l10n.vocabNoWords,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppTokens.pagePadding,
                        AppTokens.space4,
                        AppTokens.pagePadding,
                        AppTokens.sectionGap,
                      ),
                      itemCount: words.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppTokens.space12),
                      itemBuilder: (context, index) {
                        final word = words[index];
                        return WordCard(
                          word: word,
                          onTap: () async {
                            await context.push(AppRoutes.wordPath(word.id));
                            // 상세에서 지우거나 옮겼을 수 있다.
                            await model.refresh();
                          },
                          onToggleMemorized: () => model.setMemorized(
                            word.id,
                            memorized: !word.memorized,
                          ),
                          onMore: () => _showActions(context, ref, word),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 직접 단어 추가: 편집 시트에서 이 단어장에 저장한다.
  Future<void> _addWord(
    BuildContext context,
    WordbookDetailViewModel model,
  ) async {
    final l10n = AppLocalizations.of(context);
    final saved = await showWordEditSheet(
      context,
      title: l10n.vocabAddWord,
      initial: WordDraft(
        word: '',
        meaning: '',
        sourceLanguage: 'und',
        targetLanguage: Localizations.localeOf(context).languageCode,
      ),
      wordbookId: wordbookId,
    );
    if (saved != null) await model.refresh();
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    VocabularyWord word,
  ) async {
    final model = ref.read(
      wordbookDetailViewModelProvider(wordbookId).notifier,
    );
    final action = await showWordActionsSheet(context);
    if (action == null || !context.mounted) return;
    switch (action) {
      case WordAction.edit:
        final l10n = AppLocalizations.of(context);
        final edited = await showWordEditSheet(
          context,
          title: l10n.vocabEditWord,
          initial: word.toDraft(),
          editingId: word.id,
        );
        if (edited != null) await model.refresh();
      case WordAction.move:
        final books = await ref.read(wordbooksViewModelProvider.future);
        if (!context.mounted) return;
        final target = await showWordbookPickerSheet(
          context,
          books: books,
          exceptId: wordbookId,
        );
        if (target != null) await model.move(word.id, target);
      case WordAction.delete:
        final l10n = AppLocalizations.of(context);
        final confirmed = await showDeleteConfirmSheet(
          context,
          title: l10n.vocabDeleteWordTitle,
          body: word.word,
        );
        if (confirmed) await model.delete(word.id);
    }
  }
}
