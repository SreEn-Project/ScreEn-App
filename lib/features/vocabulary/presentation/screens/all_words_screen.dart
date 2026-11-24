import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/vocabulary.dart';
import '../view_models/all_words_view_model.dart';
import '../view_models/wordbooks_view_model.dart';

/// 전체 단어 (AD-05): 모든 단어장의 단어를 한 단어씩 모아 검색 · 정렬하고, 들어 있는 단어장을 보여 준다.
/// 정답률은 든 모든 단어장의 진도를 합친 값이다. 탭하면 단어 상세.
class AllWordsScreen extends ConsumerWidget {
  const AllWordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(allWordsViewModelProvider).value;
    final model = ref.read(allWordsViewModelProvider.notifier);
    final books = ref.watch(wordbooksViewModelProvider).value ?? const [];
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: l10n.vocabAllWords, large: true),
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
                    icon: LucideIcons.arrowUpDown,
                    label: sorts[sort]!,
                    values: WordSort.values,
                    selected: sort,
                    itemLabel: (v) => sorts[v]!,
                    onSelected: model.setSort,
                  ),
                  const SizedBox(width: AppTokens.space8),
                  AppPopupMenu<WordFilter>(
                    icon: LucideIcons.listFilter,
                    label: filter == WordFilter.all
                        ? l10n.vocabFilterLabel
                        : filters[filter]!,
                    values: WordFilter.values,
                    selected: filter,
                    itemLabel: (v) => filters[v]!,
                    onSelected: model.setFilter,
                    active: filter != WordFilter.all,
                  ),
                  const Spacer(),
                  Text(
                    l10n.vocabAllWordsCount(words.length),
                    style: theme.textTheme.bodySmall,
                  ),
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
                                  icon: LucideIcons.bookOpen,
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
                      separatorBuilder: (_, _) => const AppDivider(indent: 0),
                      itemBuilder: (context, index) {
                        final word = words[index];
                        return _AllWordCard(
                          word: word,
                          bookNames: [
                            for (final id in word.wordbookIds)
                              ?books.where((b) => b.id == id).firstOrNull?.name,
                          ],
                          onTap: () async {
                            await context.push(AppRoutes.wordPath(word.id));
                            // 상세에서 고치거나 지웠을 수 있다.
                            await model.refresh();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 전체 단어의 한 줄: 단어 · 뜻(여러 개면 "외 n개") · 합친 정답률 · 들어 있는 단어장.
class _AllWordCard extends StatelessWidget {
  const _AllWordCard({
    required this.word,
    required this.bookNames,
    required this.onTap,
  });

  final VocabularyWord word;
  final List<String> bookNames;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final extra = word.meanings.length - 1;
    final accuracy = word.accuracy;

    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space4,
          vertical: AppTokens.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    word.word,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (accuracy != null)
                  Text(
                    l10n.vocabAccuracy((accuracy * 100).round()),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: AppTokens.space4),
            Text(
              extra > 0
                  ? '${word.meaning}  ${l10n.vocabMoreMeanings(extra)}'
                  : word.meaning,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (bookNames.isNotEmpty) ...[
              const SizedBox(height: AppTokens.space8),
              Wrap(
                spacing: AppTokens.space8,
                runSpacing: AppTokens.space4,
                children: [for (final name in bookNames) AppBadge(label: name)],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
