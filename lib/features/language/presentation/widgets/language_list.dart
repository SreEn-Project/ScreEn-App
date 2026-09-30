import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/supported_language.dart';

/// 검색 가능한 대상 언어 목록 (FL-04). 온보딩 · 언어 선택 화면에서 같이 쓴다.
class LanguageList extends StatefulWidget {
  const LanguageList({
    super.key,
    required this.selectedCode,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppTokens.pagePadding,
    ),
  });

  final String selectedCode;
  final ValueChanged<SupportedLanguage> onSelected;
  final EdgeInsets padding;

  @override
  State<LanguageList> createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final languages = SupportedLanguage.all
        .where((l) => l.matches(_query))
        .toList();

    return Column(
      children: [
        Padding(
          padding: widget.padding,
          child: AppSearchField(
            hint: l10n.languageSearchHint,
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: languages.isEmpty
              ? Center(
                  child: Text(
                    l10n.languageEmpty,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              : ListView.separated(
                  padding: widget.padding.copyWith(top: 4, bottom: 24),
                  itemCount: languages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    return _LanguageTile(
                      language: language,
                      name: language.displayName(locale.languageCode),
                      selected: language.code == widget.selectedCode,
                      onTap: () => widget.onSelected(language),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final SupportedLanguage language;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      onTap: onTap,
      color: selected ? colors.primaryContainer : null,
      shadow: !selected,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(language.nativeName, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (!language.ocrSupported) ...[
            AppBadge(label: l10n.languageOcrUnsupported),
            const SizedBox(width: 8),
          ],
          AnimatedOpacity(
            opacity: selected ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Icon(Symbols.check_circle_rounded, color: colors.primary),
          ),
        ],
      ),
    );
  }
}
