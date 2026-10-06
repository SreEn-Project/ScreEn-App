package com.example.translation_poc_app.overlay

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.TextLayoutResult
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.unit.dp
import com.example.translation_poc_app.R
import com.example.translation_poc_app.data.settings.ResultDisplay
import com.example.translation_poc_app.translate.EngineId
import com.example.translation_poc_app.translate.ItemStatus
import com.example.translation_poc_app.translate.TranslatedItem
import com.example.translation_poc_app.translate.TranslationError
import com.example.translation_poc_app.translate.TranslationOutcome
import kotlinx.coroutines.delay
import java.util.Locale

/** 복사한 항목 표시. [ALL]은 전체 복사. */
private const val ALL = -1

/**
 * O-05 번역 결과 목록 (NA-19): 흰 하단 시트(상단 28dp)에 원문 · 번역문 카드.
 * 바깥(어두운 부분)을 누르거나 뒤로 가기로 닫는다. 결과가 없으면 같은 시트에 안내를 보여 준다.
 */
@Composable
internal fun ResultSheet(
    outcome: TranslationOutcome,
    display: ResultDisplay,
    onDismiss: () -> Unit,
    onCopy: (String) -> Unit,
    /** 원문의 단어를 탭했다 (AD-01). null이면 단어를 고를 수 없다. */
    onWord: ((WordTarget) -> Unit)? = null,
) {
    val colors = OverlayTheme.colors
    val noRipple = remember { MutableInteractionSource() }
    val frame = Modifier
        .fillMaxSize()
        .background(colors.scrim)
        .clickable(interactionSource = noRipple, indication = null, onClick = onDismiss)
    Box(modifier = frame, contentAlignment = Alignment.BottomCenter) {
        SheetSurface {
            when (outcome) {
                is TranslationOutcome.Translated -> ResultList(outcome, display, onDismiss, onCopy, onWord)
                TranslationOutcome.SecureScreen -> Message(
                    Symbol.VISIBILITY_OFF,
                    stringResource(R.string.result_secure_title),
                    stringResource(R.string.result_secure_body),
                    onDismiss,
                )
                TranslationOutcome.NoText -> Message(
                    Symbol.TRANSLATE,
                    stringResource(R.string.result_no_text_title),
                    stringResource(R.string.result_no_text_body),
                    onDismiss,
                )
                TranslationOutcome.NoTextInRegion -> Message(
                    Symbol.CROP,
                    stringResource(R.string.result_no_text_title),
                    stringResource(R.string.result_no_text_region_body),
                    onDismiss,
                )
                is TranslationOutcome.AlreadyInTarget -> Message(
                    Symbol.CHECK,
                    stringResource(R.string.result_already_target_title),
                    stringResource(R.string.result_already_target_body, languageName(outcome.targetLanguage)),
                    onDismiss,
                )
                is TranslationOutcome.Failed -> {
                    val (title, body) = translationFailureText(outcome.error)
                    Message(Symbol.ERROR, stringResource(title), stringResource(body), onDismiss)
                }
            }
        }
    }
}

/** 아래에서 올라오는 흰 시트. 시트 안을 눌러도 닫히지 않는다. */
@Composable
internal fun SheetSurface(content: @Composable ColumnScope.() -> Unit) {
    val colors = OverlayTheme.colors
    val shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp)
    val maxHeight = (LocalConfiguration.current.screenHeightDp * 0.75f).dp
    val slide = remember { Animatable(1f) }
    LaunchedEffect(Unit) { slide.animateTo(0f, tween(220)) }
    val offsetPx = with(LocalDensity.current) { 120.dp.toPx() }
    val swallow = remember { MutableInteractionSource() }
    Column(
        modifier = Modifier
            .graphicsLayer {
                translationY = slide.value * offsetPx
                alpha = 1f - slide.value
            }
            .fillMaxWidth()
            .heightIn(max = maxHeight)
            .clip(shape)
            .background(colors.surface)
            .clickable(interactionSource = swallow, indication = null) {}
            .windowInsetsPadding(WindowInsets.navigationBars)
            .padding(start = 20.dp, end = 20.dp, bottom = 20.dp),
    ) {
        // 손잡이
        Box(
            Modifier
                .padding(top = 10.dp, bottom = 12.dp)
                .align(Alignment.CenterHorizontally)
                .size(width = 36.dp, height = 4.dp)
                .clip(RoundedCornerShape(50))
                .background(colors.outline),
        )
        content()
    }
}

@Composable
private fun ColumnScope.ResultList(
    result: TranslationOutcome.Translated,
    display: ResultDisplay,
    onDismiss: () -> Unit,
    onCopy: (String) -> Unit,
    onWord: ((WordTarget) -> Unit)?,
) {
    val colors = OverlayTheme.colors
    // 문단형: 번역된 블록을 나누지 않고 한 문단으로 잇는다. 번역된 게 없으면 목록으로 보여 준다.
    val paragraph = if (display == ResultDisplay.PARAGRAPH) paragraphText(result.items, result.targetLanguage) else null
    var copied by remember { mutableStateOf<Int?>(null) }
    LaunchedEffect(copied) {
        if (copied != null) {
            delay(1_500)
            copied = null
        }
    }

    Row(verticalAlignment = Alignment.CenterVertically) {
        Column(Modifier.weight(1f)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                BasicText(stringResource(R.string.result_title), style = OverlayTheme.title.copy(color = colors.onSurface))
                Spacer(Modifier.width(8.dp))
                OverlayBadge(engineName(result.engine))
            }
            Spacer(Modifier.height(4.dp))
            BasicText(
                stringResource(R.string.result_languages, languageName(result.targetLanguage)),
                style = OverlayTheme.caption.copy(color = colors.onSurfaceVariant),
            )
            // 문단형은 원문이 안 보여 단어를 고를 수 없다.
            if (onWord != null && paragraph == null) {
                Spacer(Modifier.height(2.dp))
                BasicText(
                    stringResource(R.string.word_hint),
                    style = OverlayTheme.caption.copy(color = colors.onSurfaceVariant),
                )
            }
        }
        PlainIconButton(Symbol.CLOSE, stringResource(R.string.result_close), colors.onSurface, onDismiss)
    }
    Spacer(Modifier.height(16.dp))

    LazyColumn(
        modifier = Modifier.weight(1f, fill = false),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        if (paragraph != null) {
            item { ParagraphCard(paragraph, copied = copied == 0) { onCopy(paragraph); copied = 0 } }
        } else {
            itemsIndexed(result.items) { index, item ->
                ResultCard(item, copied = copied == index, onWord = onWord) {
                    item.translated?.let {
                        onCopy(it)
                        copied = index
                    }
                }
            }
        }
        if (result.skipped > 0) {
            item {
                BasicText(
                    stringResource(R.string.result_skipped, result.skipped, languageName(result.targetLanguage)),
                    style = OverlayTheme.caption.copy(color = colors.onSurfaceVariant),
                    modifier = Modifier.padding(horizontal = 4.dp, vertical = 4.dp),
                )
            }
        }
    }

    Spacer(Modifier.height(16.dp))
    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        PillButton(
            text = stringResource(if (copied == ALL) R.string.result_copied else R.string.result_copy_all),
            icon = if (copied == ALL) Symbol.CHECK else Symbol.CONTENT_COPY,
            onClick = {
                onCopy(paragraph ?: copyAllText(result.items))
                copied = ALL
            },
            modifier = Modifier.weight(1f),
        )
        // AI로 다시 번역은 AI 엔진(NA-13)이 생기면 연결한다. ML Kit 결과일 때만 보인다.
        if (result.engine != EngineId.GEMINI) {
            PillButton(
                text = stringResource(R.string.result_retranslate_ai),
                icon = Symbol.AUTO_AWESOME,
                style = PillStyle.SECONDARY,
                enabled = false,
                onClick = {},
                modifier = Modifier.weight(1f),
            )
        }
    }
    if (result.engine != EngineId.GEMINI) {
        Spacer(Modifier.height(8.dp))
        BasicText(
            stringResource(R.string.result_ai_coming_soon),
            style = OverlayTheme.caption.copy(color = colors.onSurfaceVariant),
            modifier = Modifier.align(Alignment.End).padding(end = 8.dp),
        )
    }
}

/** 원문(회색 작은 글자) · 번역문(본문) 카드. 오른쪽 위 복사. */
@Composable
private fun ResultCard(item: TranslatedItem, copied: Boolean, onWord: ((WordTarget) -> Unit)?, onCopy: () -> Unit) {
    val colors = OverlayTheme.colors
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(colors.background)
            .padding(start = 16.dp, top = 12.dp, bottom = 12.dp, end = 4.dp),
    ) {
        Column(Modifier.weight(1f).padding(top = 2.dp)) {
            val originalStyle = OverlayTheme.caption.copy(color = colors.onSurfaceVariant)
            if (onWord != null) {
                WordPickText(item.original, originalStyle) { word ->
                    onWord(WordTarget(word, item.original, item.sourceLanguage))
                }
            } else {
                BasicText(item.original, style = originalStyle)
            }
            Spacer(Modifier.height(6.dp))
            if (item.translated != null) {
                BasicText(item.translated, style = OverlayTheme.translated.copy(color = colors.onSurface))
            } else {
                BasicText(
                    if (item.status == ItemStatus.UNSUPPORTED) {
                        stringResource(R.string.result_unsupported, languageName(item.sourceLanguage))
                    } else {
                        stringResource(R.string.result_item_failed)
                    },
                    style = OverlayTheme.caption.copy(color = colors.onSurfaceVariant, fontStyle = FontStyle.Italic),
                )
            }
        }
        if (item.translated != null) {
            PlainIconButton(
                if (copied) Symbol.CHECK else Symbol.CONTENT_COPY,
                stringResource(R.string.result_copy),
                if (copied) colors.primary else colors.onSurfaceVariant,
                onCopy,
            )
        }
    }
}

/**
 * 글에서 탭한 단어를 [onWord]로 알린다 (AD-01). 글자 칸에서 조금 벗어난 곳을 눌러도 되지만(작은 글자라서),
 * 줄 끝 빈 곳이나 멀리 떨어진 곳은 무시한다.
 */
@Composable
private fun WordPickText(text: String, style: TextStyle, onWord: (String) -> Unit) {
    var layout by remember { mutableStateOf<TextLayoutResult?>(null) }
    val slop = with(LocalDensity.current) { 12.dp.toPx() }
    BasicText(
        text,
        style = style,
        onTextLayout = { layout = it },
        modifier = Modifier.pointerInput(text) {
            detectTapGestures { position ->
                val result = layout ?: return@detectTapGestures
                val offset = result.getOffsetForPosition(position).coerceIn(0, text.length - 1)
                val box = result.getBoundingBox(offset)
                val near = position.x in (box.left - slop)..(box.right + slop) && position.y in (box.top - slop)..(box.bottom + slop)
                if (near) WordSelection.wordAt(text, offset)?.let(onWord)
            }
        },
    )
}

/** 문단형 카드: 번역문만 한 덩어리로. 오른쪽 위 복사. */
@Composable
private fun ParagraphCard(text: String, copied: Boolean, onCopy: () -> Unit) {
    val colors = OverlayTheme.colors
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(colors.background)
            .padding(start = 16.dp, top = 12.dp, bottom = 12.dp, end = 4.dp),
    ) {
        BasicText(
            text,
            style = OverlayTheme.translated.copy(color = colors.onSurface),
            modifier = Modifier.weight(1f).padding(top = 2.dp),
        )
        PlainIconButton(
            if (copied) Symbol.CHECK else Symbol.CONTENT_COPY,
            stringResource(R.string.result_copy),
            if (copied) colors.primary else colors.onSurfaceVariant,
            onCopy,
        )
    }
}

@Composable
private fun ColumnScope.Message(symbol: Symbol, title: String, body: String, onDismiss: () -> Unit) {
    val colors = OverlayTheme.colors
    Column(
        modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        SymbolBadge(symbol, size = 56.dp)
        Spacer(Modifier.height(16.dp))
        BasicText(title, style = OverlayTheme.title.copy(color = colors.onSurface))
        Spacer(Modifier.height(6.dp))
        BasicText(
            body,
            style = OverlayTheme.body.copy(
                color = colors.onSurfaceVariant,
                textAlign = androidx.compose.ui.text.style.TextAlign.Center,
            ),
        )
        Spacer(Modifier.height(24.dp))
        PillButton(
            text = stringResource(R.string.result_close),
            style = PillStyle.SECONDARY,
            onClick = onDismiss,
            modifier = Modifier.fillMaxWidth(),
        )
    }
}

@Composable
private fun engineName(engine: EngineId): String = stringResource(
    when (engine) {
        EngineId.ML_KIT -> R.string.engine_ml_kit
        EngineId.GEMINI -> R.string.engine_gemini
    },
)

/** 엔진이 알려 준 실패 이유 → 제목 · 설명. 언어 모델 문제는 사용자가 할 수 있는 일을 알려 준다. */
internal fun translationFailureText(error: TranslationError?): Pair<Int, Int> = when (error) {
    TranslationError.Network -> R.string.result_network_title to R.string.result_network_body
    TranslationError.NotEnoughSpace -> R.string.result_no_space_title to R.string.result_no_space_body
    is TranslationError.ModelNotDownloaded -> R.string.result_no_model_title to R.string.result_no_model_body
    else -> R.string.result_failed_title to R.string.result_failed_body
}

/** 언어 코드 → 기기 언어로 된 이름 ("ko" → "한국어"). */
@Composable
private fun languageName(code: String): String = languageDisplayName(code, LocalConfiguration.current.locales[0])

internal fun languageDisplayName(code: String, locale: Locale): String {
    val name = Locale.forLanguageTag(code).getDisplayLanguage(locale)
    return name.ifBlank { code }.replaceFirstChar { it.titlecase(locale) }
}

/** 글자 사이에 띄어쓰기를 하지 않는 언어 (TranslationPipeline과 같은 목록). */
private val NO_SPACE_LANGUAGES = setOf("ja", "zh", "th", "lo", "km", "my")

/**
 * 문단형 결과: 번역된 블록의 번역문을 화면 순서대로 한 문단으로 잇는다 (블록 · 문장 구분 없음).
 * 번역된 블록이 없으면 null.
 */
internal fun paragraphText(items: List<TranslatedItem>, targetLanguage: String): String? {
    val parts = items.mapNotNull { it.translated?.trim()?.takeIf(String::isNotEmpty) }
    if (parts.isEmpty()) return null
    return parts.joinToString(if (targetLanguage in NO_SPACE_LANGUAGES) "" else " ")
}

/** 전체 복사: 번역문을 빈 줄로 잇는다. 번역하지 못한 블록은 원문. */
internal fun copyAllText(items: List<TranslatedItem>): String =
    items.joinToString("\n\n") { it.translated ?: it.original }
