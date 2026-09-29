import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/ui/ui.dart';
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

    return AppPage(
      title: l10n.aboutTitle,
      children: [
        const SizedBox(height: 16),
        const Center(
          child: IconBadge(icon: Symbols.translate_rounded, size: 88),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.appTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          '${l10n.aboutVersion} $_version',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 32),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              AppListTile(
                icon: Symbols.policy_rounded,
                title: l10n.aboutPrivacy,
                subtitle: l10n.aboutPending,
                enabled: false,
                onTap: () {},
              ),
              const AppDivider(),
              AppListTile(
                icon: Symbols.description_rounded,
                title: l10n.aboutLicenses,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appTitle,
                  applicationVersion: _version,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
