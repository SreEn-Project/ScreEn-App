import 'package:flutter/material.dart';

/// 색 토큰. 값의 근거와 용도는 docs/design.md 참고.
/// 화면 코드에서는 이 파일을 직접 쓰지 말고 `Theme.of(context)`로 가져온다.
abstract final class AppColors {
  static const lightBackground = Color(0xFFF6F8F5);
  static const darkBackground = Color(0xFF0B1A16);

  static const lightAccent = Color(0xFF72C613);
  static const darkAccent = Color(0xFF8FDB3A);

  static const lightHeroGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFCBF39D),
    Color(0xFFC8EFC1),
  ];
  static const darkHeroGradient = [
    Color(0xFF13241F),
    Color(0xFF1D3A31),
    Color(0xFF2A4A1F),
  ];

  static const lightShadow = Color(0x0F000000); // 검정 6%
  static const darkShadow = Color(0x3D000000); // 검정 24%

  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF044B39),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFC8EFC1),
    onPrimaryContainer: Color(0xFF044B39),
    secondary: Color(0xFF6B7570),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCBF39D),
    onSecondaryContainer: Color(0xFF0F1F1A),
    tertiary: Color(0xFF72C613),
    onTertiary: Color(0xFF0F1F1A),
    surface: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFAFBFA),
    surfaceContainer: Color(0xFFF6F8F5),
    surfaceContainerHigh: Color(0xFFEFF3EF),
    surfaceContainerHighest: Color(0xFFE8EDE9),
    onSurface: Color(0xFF0F1F1A),
    onSurfaceVariant: Color(0xFF6B7570),
    outline: Color(0xFFE3E8E4),
    outlineVariant: Color(0xFFEDF1EE),
    shadow: Color(0xFF000000),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFC8EFC1),
    onPrimary: Color(0xFF04261D),
    primaryContainer: Color(0xFF1D3A31),
    onPrimaryContainer: Color(0xFFC8EFC1),
    secondary: Color(0xFF9AA8A1),
    onSecondary: Color(0xFF0B1A16),
    secondaryContainer: Color(0xFF2A4A1F),
    onSecondaryContainer: Color(0xFFE4EDE8),
    tertiary: Color(0xFF8FDB3A),
    onTertiary: Color(0xFF0B1A16),
    surface: Color(0xFF13241F),
    surfaceContainerLowest: Color(0xFF0B1A16),
    surfaceContainerLow: Color(0xFF101F1B),
    surfaceContainer: Color(0xFF13241F),
    surfaceContainerHigh: Color(0xFF1A2E28),
    surfaceContainerHighest: Color(0xFF213831),
    onSurface: Color(0xFFE4EDE8),
    onSurfaceVariant: Color(0xFF9AA8A1),
    outline: Color(0xFF24362F),
    outlineVariant: Color(0xFF1C2E28),
    shadow: Color(0xFF000000),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
  );
}
