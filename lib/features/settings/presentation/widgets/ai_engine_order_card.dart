import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/l10n/labels.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/translator_settings.dart';
import '../view_models/api_key_view_model.dart';
import '../view_models/engine_view_model.dart';

/// 1순위 AI 엔진 선택 (NA-13). Gemini · Groq 키가 모두 있을 때만 보인다.
/// 고른 엔진이 [EngineType] 설정 그 자체라 빠른 설정 버블·엔진 목록과 같은 값이다.
/// 1순위가 실패하면 다른 AI 엔진 → ML Kit 순으로 넘어간다.
class AiEngineOrderCard extends ConsumerWidget {
  const AiEngineOrderCard({super.key});

  static const _aiEngines = [EngineType.gemini, EngineType.groq];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBoth = _aiEngines.every(
      (e) => ref.watch(apiKeyViewModelProvider(e)).value != null,
    );
    if (!hasBoth) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final current =
        ref.watch(engineViewModelProvider).value ?? EngineType.mlKit;
    final isAi = current.needsApiKey;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          vertical: AppTokens.cardListPaddingV,
        ),
        child: AppListTile(
          icon: Symbols.swap_vert_rounded,
          title: l10n.aiOrderTitle,
          subtitle: l10n.aiOrderDetail,
          trailing: AppPopupMenu<EngineType>(
            icon: Symbols.looks_one_rounded,
            label: isAi ? l10n.engineBrand(current) : l10n.aiOrderNone,
            values: _aiEngines,
            selected: current,
            itemLabel: l10n.engineBrand,
            active: isAi,
            onSelected: ref.read(engineViewModelProvider.notifier).select,
          ),
        ),
      ),
    );
  }
}
