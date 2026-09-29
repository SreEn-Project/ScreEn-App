import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../l10n/app_localizations.dart';

/// 정보 (S-08, FL-14).
/// UI 퍼블리싱 단계: 버전은 고정 값, 개인정보처리방침은 주소가 정해지면 url_launcher로 연다.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // 기능 연결 때 package_info_plus로 교체한다.
  static const _version = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.pagePadding,
          16,
          AppTokens.pagePadding,
          32,
        ),
        children: [
          Column(
            children: [
              const IconBadge(icon: Symbols.translate_rounded, size: 80),
              const SizedBox(height: 16),
              Text(l10n.appTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                '${l10n.aboutVersion} $_version',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 32),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                ListTile(
                  enabled: false,
                  leading: const IconBadge(icon: Symbols.policy_rounded),
                  title: Text(
                    l10n.aboutPrivacy,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    l10n.aboutPending,
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: const Icon(Symbols.open_in_new_rounded),
                ),
                const Divider(indent: 20, endIndent: 20, height: 1),
                ListTile(
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: l10n.appTitle,
                    applicationVersion: _version,
                  ),
                  leading: const IconBadge(icon: Symbols.description_rounded),
                  title: Text(
                    l10n.aboutLicenses,
                    style: theme.textTheme.titleMedium,
                  ),
                  trailing: const Icon(Symbols.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
