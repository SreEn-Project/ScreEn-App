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
import '../widgets/wordbook_card.dart';

/// 단어장 목록 (X-03, AD-04): 만들기 · 이름 변경 · 삭제, 탭하면 단어장 상세.
class WordbooksScreen extends ConsumerWidget {
  const WordbooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(wordbooksViewModelProvider);
    final model = ref.read(wordbooksViewModelProvider.notifier);
    final books = state.value;

    Future<void> create() => showWordbookNameSheet(
      context,
      title: l10n.vocabNewBook,
      confirmLabel: l10n.vocabCreate,
      onSubmit: (name) async => await model.create(name) != null,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: l10n.vocabTitle,
              trailing: AppIconButton(
                icon: Symbols.add_rounded,
                tooltip: l10n.vocabNewBook,
                plain: true,
                size: 44,
                onPressed: create,
              ),
            ),
            Expanded(
              child: books == null
                  ? const SizedBox.shrink()
                  : books.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.pagePadding,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const IconBadge(
                              icon: Symbols.menu_book_rounded,
                              size: 48,
                            ),
                            const SizedBox(height: AppTokens.space12),
                            Text(
                              l10n.vocabEmpty,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppTokens.space4),
                            Text(
                              l10n.vocabEmptyHint,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: AppTokens.sectionGap),
                            AppButton(
                              label: l10n.vocabNewBook,
                              expand: false,
                              onPressed: create,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppTokens.pagePadding,
                        AppTokens.space8,
                        AppTokens.pagePadding,
                        AppTokens.sectionGap,
                      ),
                      itemCount: books.length + 1,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppTokens.space12),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _StudyCard(
                            onTap: () => context.push(AppRoutes.learning),
                          );
                        }
                        final book = books[index - 1];
                        return WordbookCard(
                          book: book,
                          onTap: () async {
                            await context.push(AppRoutes.wordbookPath(book.id));
                            // 안에서 단어를 지우거나 옮겼을 수 있다.
                            await model.refresh();
                          },
                          onRename: () => showWordbookNameSheet(
                            context,
                            title: l10n.vocabRename,
                            confirmLabel: l10n.vocabSave,
                            initialName: book.name,
                            onSubmit: (name) => model.rename(book.id, name),
                          ),
                          onDelete: () => _confirmDelete(context, ref, book),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Wordbook book,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDeleteConfirmSheet(
      context,
      title: l10n.vocabDeleteBookTitle(book.name),
      body: book.wordCount > 0
          ? l10n.vocabDeleteBookBody(book.wordCount)
          : null,
    );
    if (confirmed) {
      await ref.read(wordbooksViewModelProvider.notifier).delete(book.id);
    }
  }
}

/// 학습 시작(L-01)으로 가는 카드: 단어장 목록 맨 위에 둔다.
class _StudyCard extends StatelessWidget {
  const _StudyCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AppCard(
      onTap: onTap,
      color: colors.primaryContainer,
      shadow: false,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.pagePadding,
        vertical: AppTokens.space16,
      ),
      child: Row(
        children: [
          Icon(Symbols.quiz_rounded, color: colors.onPrimaryContainer),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.vocabStudy,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                Text(
                  l10n.vocabStudyHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Icon(Symbols.chevron_right_rounded, color: colors.onPrimaryContainer),
        ],
      ),
    );
  }
}
