import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';

const pinLength = 4;

/// 4자리 PIN 입력 시트 (NA-13). 네 자리가 차면 [validate]를 부르고, 오류 문구를 돌려주면 시트에 보여 주며
/// null이면 닫으면서 입력한 PIN을 돌려준다. 닫으면 null.
Future<String?> showPinSheet(
  BuildContext context, {
  required String title,
  String? body,
  Future<String?> Function(String pin)? validate,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PinSheet(title: title, body: body, validate: validate),
  );
}

class _PinSheet extends StatefulWidget {
  const _PinSheet({required this.title, this.body, this.validate});

  final String title;
  final String? body;
  final Future<String?> Function(String pin)? validate;

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _changed(String value) async {
    if (_error != null) setState(() => _error = null);
    if (value.length != pinLength || _busy) return;
    setState(() => _busy = true);
    final error = await widget.validate?.call(value);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(value);
      return;
    }
    _controller.clear();
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pagePadding,
            0,
            AppTokens.pagePadding,
            AppTokens.sectionGap,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: theme.textTheme.titleLarge),
              if (widget.body != null) ...[
                const SizedBox(height: AppTokens.space8),
                Text(widget.body!, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: AppTokens.sectionGap),
              AppTextField(
                controller: _controller,
                hint: '••••',
                obscure: true,
                autofocus: true,
                maxLength: pinLength,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _changed,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppTokens.space8),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// PIN을 잊었을 때: 키를 지우고 초기화할지 묻는다. 하겠다고 하면 true.
Future<bool> showPinResetSheet(BuildContext context) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      final theme = Theme.of(sheetContext);
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pagePadding,
            0,
            AppTokens.pagePadding,
            AppTokens.sectionGap,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.pinResetTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppTokens.space8),
              Text(l10n.pinResetBody, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppTokens.sectionGap),
              AppButton(
                label: l10n.pinResetConfirm,
                expand: true,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
              const SizedBox(height: AppTokens.space8),
              AppButton.secondary(
                label: l10n.pinCancel,
                expand: true,
                onPressed: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );
  return confirmed ?? false;
}
