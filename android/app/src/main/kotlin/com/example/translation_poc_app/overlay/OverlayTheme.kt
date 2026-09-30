package com.example.translation_poc_app.overlay

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.translation_poc_app.R

/**
 * 오버레이 색 토큰. 값은 res/values(-night)/colors.xml → docs/design.md와 같다.
 * 오버레이 코드에서 색 값을 직접 쓰지 않고 [OverlayTheme.colors]로만 가져온다.
 */
@Immutable
data class OverlayColors(
    val primary: Color,
    val onPrimary: Color,
    val primaryContainer: Color,
    val onPrimaryContainer: Color,
    val background: Color,
    val surface: Color,
    val onSurface: Color,
    val onSurfaceVariant: Color,
    val outline: Color,
    val error: Color,
    val scrim: Color,
    val shadow: Color,
)

private val LocalOverlayColors = staticCompositionLocalOf<OverlayColors> { error("OverlayTheme 밖에서 사용") }

object OverlayTheme {
    val colors: OverlayColors
        @Composable get() = LocalOverlayColors.current

    /** 제목 18 SemiBold, 본문 15, 보조 13 (design.md "글자"). 오버레이는 가독성을 위해 번역문을 16으로 키운다. */
    val title = TextStyle(fontSize = 18.sp, fontWeight = FontWeight.SemiBold)
    val body = TextStyle(fontSize = 15.sp)
    val translated = TextStyle(fontSize = 16.sp, lineHeight = 23.sp)
    val caption = TextStyle(fontSize = 13.sp, lineHeight = 18.sp)
    val label = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
    val badge = TextStyle(fontSize = 12.sp, fontWeight = FontWeight.SemiBold)
}

@Composable
fun OverlayTheme(content: @Composable () -> Unit) {
    val colors = OverlayColors(
        primary = colorResource(R.color.brand_primary),
        onPrimary = colorResource(R.color.brand_on_primary),
        primaryContainer = colorResource(R.color.brand_primary_container),
        onPrimaryContainer = colorResource(R.color.brand_on_primary_container),
        background = colorResource(R.color.brand_background),
        surface = colorResource(R.color.brand_surface),
        onSurface = colorResource(R.color.brand_on_surface),
        onSurfaceVariant = colorResource(R.color.brand_on_surface_variant),
        outline = colorResource(R.color.brand_outline),
        error = colorResource(R.color.brand_error),
        scrim = colorResource(R.color.overlay_scrim),
        shadow = colorResource(R.color.overlay_shadow),
    )
    CompositionLocalProvider(LocalOverlayColors provides colors, content = content)
}

/**
 * Material Symbols Rounded 선 아이콘 (design.md "아이콘", Flutter 화면과 같은 글꼴).
 * res/font/material_symbols_rounded.ttf는 아래 글자만 남기고 FILL 0 · wght 400 · opsz 24로 고정한 부분 글꼴이다.
 * 아이콘을 늘리면 글꼴도 다시 만들어야 한다 (만드는 법: docs/decisions.md D-025).
 */
enum class Symbol(val codepoint: Int) {
    FULLSCREEN(0xe5d0),
    CROP(0xe3be),
    PUSH_PIN(0xf10d),
    EDIT(0xf097),
    TRANSLATE(0xe8e2),
    CONTENT_COPY(0xe14d),
    CHECK(0xe668),
    CLOSE(0xe5cd),
    AUTO_AWESOME(0xe65f),
    ERROR(0xf8b6),
    VISIBILITY_OFF(0xe8f5),
}

private val SymbolsFont = FontFamily(Font(R.font.material_symbols_rounded))

@Composable
fun SymbolIcon(symbol: Symbol, color: Color, modifier: Modifier = Modifier, size: Dp = 24.dp) {
    // 글꼴 크기가 사용자 글자 크기 설정을 따라 커지지 않도록 dp → sp를 직접 바꾼다.
    val fontSize = with(LocalDensity.current) { size.toSp() }
    Box(modifier.size(size), contentAlignment = Alignment.Center) {
        BasicText(
            text = String(Character.toChars(symbol.codepoint)),
            style = TextStyle(
                color = color,
                fontFamily = SymbolsFont,
                fontSize = fontSize,
                lineHeight = fontSize,
                textAlign = TextAlign.Center,
            ),
        )
    }
}
