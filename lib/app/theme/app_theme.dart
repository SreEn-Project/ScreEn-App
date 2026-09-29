import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';

/// 흰 톤 + 연한 초록 포인트 테마 (docs/design.md).
/// 화면은 `lib/core/ui/` 자체 컴포넌트로 그린다 (D-015). 여기 Material 컴포넌트 테마는
/// 라이선스 화면 · 대화상자처럼 Flutter 기본 위젯이 뜨는 곳을 팔레트에 맞추는 용도다.
abstract final class AppTheme {
  static ThemeData get light => _build(AppColors.light, AppTokens.light);
  static ThemeData get dark => _build(AppColors.dark, AppTokens.dark);

  static ThemeData _build(ColorScheme colors, AppTokens tokens) {
    const pill = StadiumBorder();
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusInput),
      borderSide: BorderSide(color: colors.outline),
    );
    // 컴포넌트 글자 스타일은 textTheme에서 파생해 글꼴 설정을 물려받게 한다.
    final textTheme = ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
    ).textTheme.merge(_textTheme(colors));
    final buttonText = textTheme.labelLarge!.copyWith(fontSize: 16);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: tokens.background,
      extensions: [tokens],
      // 물결(ripple) 대신 자체 컴포넌트의 눌림 효과(Pressable)를 쓴다.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.background,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge!.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
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
        style: TextButton.styleFrom(
          shape: pill,
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: pill,
        side: BorderSide.none,
        backgroundColor: colors.surface,
        selectedColor: colors.primaryContainer,
        labelStyle: textTheme.bodyMedium!.copyWith(fontSize: 14),
        secondaryLabelStyle: textTheme.labelLarge!.copyWith(
          fontSize: 14,
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
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
    );
  }
}
