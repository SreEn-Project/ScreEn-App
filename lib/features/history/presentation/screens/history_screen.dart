import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/history_entry.dart';
import '../view_models/history_view_model.dart';
import '../widgets/history_card.dart';

/// 번역 기록 (FL-13): 검색 · 기간 필터 · 한 줄 삭제 · 전체 삭제.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  // 전체 삭제는 한 번 눌러 확인을 받고, 다시 눌러야 지운다.
  bool _confirmClear = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(historyViewModelProvider).value;
    final model = ref.read(historyViewModelProvider.notifier);
    final periods = {
      HistoryPeriod.all: l10n.homeRecentFilterAll,
      HistoryPeriod.today: l10n.homeRecentFilterToday,
      HistoryPeriod.week: l10n.homeRecentFilterWeek,
    };
    final entries = state?.entries ?? const <HistoryEntry>[];
    final canClear = entries.isNotEmpty || _confirmClear;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: l10n.historyTitle,
              trailing: canClear
                  ? AppButton.text(
                      label: _confirmClear
                          ? l10n.historyClearConfirm
                          : l10n.historyClearAll,
                      onPressed: () {
                        if (!_confirmClear) {
                          setState(() => _confirmClear = true);
                          return;
                        }
                        setState(() => _confirmClear = false);
                        model.clear();
                        ref.invalidate(recentHistoryProvider);
                      },
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.pagePadding,
              ),
              child: AppSearchField(
                hint: l10n.historySearchHint,
                onChanged: model.setQuery,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.pagePadding,
                12,
                AppTokens.pagePadding,
                8,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final period in HistoryPeriod.values)
                      AppChip(
                        label: periods[period]!,
                        selected:
                            (state?.period ?? HistoryPeriod.all) == period,
                        onTap: () => model.setPeriod(period),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: state == null
                          ? const SizedBox.shrink()
                          : AppEmptyState(
                              icon: state.filtered
                                  ? LucideIcons.searchX
                                  : LucideIcons.history,
                              title: state.filtered
                                  ? l10n.historyNoResult
                                  : l10n.homeRecentEmpty,
                            ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppTokens.pagePadding,
                        4,
                        AppTokens.pagePadding,
                        AppTokens.bottomNavSpace + AppTokens.space16,
                      ),
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => const AppDivider(indent: 4),
                      itemBuilder: (context, index) => HistoryCard(
                        flat: true,
                        entry: entries[index],
                        deleteTooltip: l10n.historyDelete,
                        onDelete: () {
                          model.delete(entries[index].id);
                          ref.invalidate(recentHistoryProvider);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
