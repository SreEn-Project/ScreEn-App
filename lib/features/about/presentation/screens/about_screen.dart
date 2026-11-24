import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/app_info_view_model.dart';

/// 정보 (S-08, FL-14).
/// 버전은 package_info_plus, 라이선스는 showLicensePage. 개인정보처리방침은 주소가 정해지면 url_launcher로 연다.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appInfoProvider).value?.displayVersion;
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
        // 버전을 읽기 전에는 자리만 잡아 화면이 출렁이지 않게 한다.
        Text(
          version == null ? ' ' : '${l10n.aboutVersion} $version',
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
                  applicationVersion: version,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
