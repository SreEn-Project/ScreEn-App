import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';

/// 흰 톤 + 연한 초록 포인트 테마 (docs/design.md).
/// 카드 그림자는 Material elevation 대신 `AppCard`가 토큰 그림자로 그린다.
abstract final class AppTheme {
  static ThemeData get light => _build(AppColors.light, AppTokens.light);
  static ThemeData get dark => _build(AppColors.dark, AppTokens.dark);

  static ThemeData _build(ColorScheme colors, AppTokens tokens) {
    const pill = StadiumBorder();
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusInput),
      borderSide: BorderSide(color: colors.outline),
    );
    const buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: tokens.background,
      extensions: [tokens],
      textTheme: _textTheme(colors),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.background,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        elevation: 0,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.radiusSheet),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, AppTokens.largeButtonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, AppTokens.largeButtonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          shape: pill,
          side: BorderSide(color: colors.outline),
          foregroundColor: colors.onSurface,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: pill),
      ),
      chipTheme: ChipThemeData(
        shape: pill,
        side: BorderSide.none,
        backgroundColor: colors.surface,
        selectedColor: colors.primaryContainer,
        labelStyle: TextStyle(fontSize: 14, color: colors.onSurface),
        secondaryLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.onPrimaryContainer,
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: colors.onSurface),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.pagePadding,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline,
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(colors.outline),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: inputBorder,
        enabledBorder: inputBorder,
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme colors) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      bodyLarge: TextStyle(fontSize: 15, height: 1.5, color: colors.onSurface),
      bodyMedium: TextStyle(fontSize: 15, height: 1.5, color: colors.onSurface),
      bodySmall: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
      labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );
  }
}
