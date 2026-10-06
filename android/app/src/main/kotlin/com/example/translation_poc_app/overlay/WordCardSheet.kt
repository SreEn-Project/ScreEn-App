package com.example.translation_poc_app.overlay

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
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.translation_poc_app.R
import com.example.translation_poc_app.data.vocabulary.VocabularyRepository
import com.example.translation_poc_app.data.vocabulary.WordbookRow
import com.example.translation_poc_app.translate.TranslationError
import com.example.translation_poc_app.translate.WordEntry
import kotlinx.coroutines.delay

/** 단어 사전 카드(X-01)와 단어장 선택(X-02)이 보여 줄 상태 (AD-02, AD-03). */
internal sealed interface WordCardState {
    val target: WordTarget

    data class Loading(override val target: WordTarget) : WordCardState

    /** 번역도 풀이도 못 얻었다. */
    data class Failed(override val target: WordTarget, val error: TranslationError?) : WordCardState

    /** 카드. [saveFailed]면 저장하려다 실패한 직후. */
    data class Ready(override val target: WordTarget, val entry: WordEntry, val saveFailed: Boolean = false) : WordCardState

    /** 저장할 단어장을 고르는 중 (X-02). */
    data class Picking(override val target: WordTarget, val entry: WordEntry, val books: List<WordbookRow>) : WordCardState

    data class Saved(override val target: WordTarget, val entry: WordEntry, val bookName: String) : WordCardState
}

internal class WordCardActions(
    val onClose: () -> Unit,
    /** 카드의 "단어장에 저장". */
    val onSave: () -> Unit,
    /** 단어장 선택에서 카드로 돌아간다. */
    val onBack: () -> Unit,
    val onPick: (wordbookId: Long) -> Unit,
    /** 새 단어장을 만들고 저장한다. 이름은 호출 쪽이 다듬는다. */
    val onCreate: (name: String) -> Unit,
)

private const val SAVED_CLOSE_MS = 1_400L

/** 아래에서 올라오는 단어 카드 시트. 바깥(어두운 부분)을 누르거나 뒤로 가기로 닫는다. */
@Composable
internal fun WordCardSheet(state: WordCardState, actions: WordCardActions) {
    val colors = OverlayTheme.colors
    val noRipple = remember { MutableInteractionSource() }
    LaunchedEffect(state is WordCardState.Saved) {
        if (state is WordCardState.Saved) {
            delay(SAVED_CLOSE_MS)
            actions.onClose()
        }
    }
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(colors.scrim)
            .clickable(interactionSource = noRipple, indication = null, onClick = actions.onClose)
            // 새 단어장 이름을 칠 때 키보드가 시트를 가리지 않게 한다.
            .windowInsetsPadding(WindowInsets.ime),
        contentAlignment = Alignment.BottomCenter,
    ) {
        SheetSurface {
            when (state) {
                is WordCardState.Loading -> Loading(state, actions)
                is WordCardState.Failed -> Failed(state, actions)
                is WordCardState.Ready -> Card(state, actions)
                is WordCardState.Picking -> Picker(state, actions)
                is WordCardState.Saved -> SavedMessage(state)
            }
        }
    }
}

@Composable
private fun ColumnScope.Header(word: String, actions: WordCardActions, content: @Composable ColumnScope.() -> Unit = {}) {
    val colors = OverlayTheme.colors
    Row(verticalAlignment = Alignment.Top) {
        Column(Modifier.weight(1f).padding(top = 4.dp)) {
            BasicText(word, style = OverlayTheme.title.copy(fontSize = 24.sp, color = colors.onSurface))
            content()
        }
        PlainIconButton(Symbol.CLOSE, stringResource(R.string.result_close), colors.onSurface, actions.onClose)
    }
}

@Composable
private fun ColumnScope.Loading(state: WordCardState.Loading, actions: WordCardActions) {
    val colors = OverlayTheme.colors
    Header(state.target.word, actions)
    Spacer(Modifier.height(16.dp))
    BasicText(stringResource(R.string.word_loading), style = OverlayTheme.body.copy(color = colors.onSurfaceVariant))
    Spacer(Modifier.height(24.dp))
}

@Composable
private fun ColumnScope.Failed(state: WordCardState.Failed, actions: WordCardActions) {
    val colors = OverlayTheme.colors
    val (title, body) = translationFailureText(state.error)
    Header(state.target.word, actions)
    Spacer(Modifier.height(16.dp))
    BasicText(stringResource(title), style = OverlayTheme.label.copy(color = colors.onSurface))
    Spacer(Modifier.height(4.dp))
    BasicText(stringResource(body), style = OverlayTheme.body.copy(color = colors.onSurfaceVariant))
    Spacer(Modifier.height(24.dp))
    PillButton(
        text = stringResource(R.string.result_close),
        style = PillStyle.SECONDARY,
        onClick = actions.onClose,
        modifier = Modifier.fillMaxWidth(),
    )
}

/** X-01 단어 사전 카드: 단어 · 번역 · (AI) 뜻 · 발음 · 품사 · 문맥 뜻, 저장 버튼. */
@Composable
private fun ColumnScope.Card(state: WordCardState.Ready, actions: WordCardActions) {
    val colors = OverlayTheme.colors
    val entry = state.entry
    val definition = entry.definition
    Header(entry.word, actions) {
        if (definition?.pronunciation != null || definition?.partOfSpeech != null) {
            Spacer(Modifier.height(6.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                definition.pronunciation?.let {
                    BasicText(it, style = OverlayTheme.caption.copy(color = colors.onSurfaceVariant))
                    Spacer(Modifier.width(8.dp))
                }
                definition.partOfSpeech?.let { OverlayBadge(it) }
            }
        }
    }
    Spacer(Modifier.height(16.dp))
    Column(Modifier.weight(1f, fill = false).verticalScroll(rememberScrollState())) {
        Block(stringResource(R.string.word_label_translation), entry.translation)
        definition?.meaning?.takeIf { it != entry.translation }?.let {
            Block(stringResource(R.string.word_label_meaning), it)
        }
        definition?.contextMeaning?.let { Block(stringResource(R.string.word_label_context), it) }
        entry.sentence?.let {
            Spacer(Modifier.height(4.dp))
            BasicText(
                stringResource(R.string.word_label_sentence),
                style = OverlayTheme.caption.copy(color = colors.onSurfaceVariant),
            )
            Spacer(Modifier.height(2.dp))
            BasicText(
                it,
                style = OverlayTheme.caption.copy(color = colors.onSurfaceVariant, fontStyle = FontStyle.Italic),
            )
        }
        if (definition == null) {
            Spacer(Modifier.height(12.dp))
            BasicText(
                stringResource(if (entry.aiError == null) R.string.word_ai_hint else R.string.word_ai_failed),
                style = OverlayTheme.caption.copy(color = colors.onSurfaceVariant),
            )
        }
    }
    Spacer(Modifier.height(16.dp))
    if (state.saveFailed) {
        BasicText(
            stringResource(R.string.word_save_failed),
            style = OverlayTheme.caption.copy(color = colors.error),
            modifier = Modifier.padding(bottom = 8.dp),
        )
    }
    PillButton(
        text = stringResource(R.string.word_save),
        onClick = actions.onSave,
        modifier = Modifier.fillMaxWidth(),
    )
}

@Composable
private fun Block(label: String, text: String) {
    val colors = OverlayTheme.colors
    BasicText(label, style = OverlayTheme.caption.copy(color = colors.onSurfaceVariant))
    Spacer(Modifier.height(2.dp))
    BasicText(text, style = OverlayTheme.translated.copy(color = colors.onSurface))
    Spacer(Modifier.height(12.dp))
}

/** X-02 단어장 선택: 단어장 목록 + 새 단어장 만들기. */
@Composable
private fun ColumnScope.Picker(state: WordCardState.Picking, actions: WordCardActions) {
    val colors = OverlayTheme.colors
    var name by remember { mutableStateOf("") }
    Row(verticalAlignment = Alignment.CenterVertically) {
        BasicText(
            stringResource(R.string.word_pick_title),
            style = OverlayTheme.title.copy(color = colors.onSurface),
            modifier = Modifier.weight(1f),
        )
        PlainIconButton(Symbol.CLOSE, stringResource(R.string.result_close), colors.onSurface, actions.onClose)
    }
    Spacer(Modifier.height(4.dp))
    BasicText(
        state.entry.word,
        style = OverlayTheme.caption.copy(color = colors.onSurfaceVariant),
    )
    Spacer(Modifier.height(12.dp))
    Column(
        modifier = Modifier.weight(1f, fill = false).verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        if (state.books.isEmpty()) {
            BasicText(
                stringResource(R.string.word_no_books),
                style = OverlayTheme.body.copy(color = colors.onSurfaceVariant),
            )
        }
        state.books.forEach { book ->
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(20.dp))
                    .background(colors.background)
                    .pressable(onClick = { actions.onPick(book.id) })
                    .padding(horizontal = 16.dp, vertical = 14.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                BasicText(
                    book.name,
                    style = OverlayTheme.label.copy(color = colors.onSurface),
                    modifier = Modifier.weight(1f),
                )
                BasicText(
                    stringResource(R.string.word_book_count, book.wordCount),
                    style = OverlayTheme.caption.copy(color = colors.onSurfaceVariant),
                )
            }
        }
    }
    Spacer(Modifier.height(16.dp))
    // 새 단어장 만들기: 이름을 치고 만들면 바로 저장한다.
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        Box(
            modifier = Modifier
                .weight(1f)
                .clip(RoundedCornerShape(20.dp))
                .background(colors.background)
                .padding(horizontal = 16.dp, vertical = 14.dp),
        ) {
            if (name.isEmpty()) {
                BasicText(
                    stringResource(R.string.word_new_book_hint),
                    style = OverlayTheme.body.copy(color = colors.onSurfaceVariant),
                )
            }
            BasicTextField(
                value = name,
                onValueChange = { name = it.take(VocabularyRepository.MAX_NAME_LENGTH) },
                singleLine = true,
                textStyle = OverlayTheme.body.copy(color = colors.onSurface, textAlign = TextAlign.Start),
                cursorBrush = SolidColor(colors.primary),
                modifier = Modifier.fillMaxWidth(),
            )
        }
        PillButton(
            text = stringResource(R.string.word_create),
            onClick = { actions.onCreate(name) },
            enabled = name.isNotBlank(),
        )
    }
    Spacer(Modifier.height(8.dp))
    PillButton(
        text = stringResource(R.string.word_back),
        style = PillStyle.SECONDARY,
        onClick = actions.onBack,
        modifier = Modifier.fillMaxWidth(),
    )
}

@Composable
private fun ColumnScope.SavedMessage(state: WordCardState.Saved) {
    val colors = OverlayTheme.colors
    Column(
        modifier = Modifier.fillMaxWidth().padding(top = 8.dp, bottom = 8.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        SymbolBadge(Symbol.CHECK, size = 56.dp)
        Spacer(Modifier.height(16.dp))
        BasicText(
            stringResource(R.string.word_saved, state.bookName),
            style = OverlayTheme.title.copy(color = colors.onSurface, textAlign = TextAlign.Center),
        )
        Spacer(Modifier.height(4.dp))
        BasicText(state.entry.word, style = OverlayTheme.caption.copy(color = colors.onSurfaceVariant))
    }
}
