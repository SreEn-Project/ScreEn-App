package com.example.translation_poc_app.selection

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Intent
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.ScrollView
import android.widget.TextView
import com.example.translation_poc_app.AppGraph
import com.example.translation_poc_app.R
import com.example.translation_poc_app.overlay.languageDisplayName
import com.example.translation_poc_app.overlay.translationFailureText
import com.example.translation_poc_app.translate.MlKitTranslationEngine
import com.example.translation_poc_app.translate.ModelDownloadPolicy
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * 다른 앱의 글자 선택 메뉴에서 "번역"을 누르면 뜨는 작은 팝업 (NA-24, ACTION_PROCESS_TEXT).
 * 서비스 · 캡처 권한 없이 혼자 번역하고, 성공하면 번역 기록(NA-23)에 남긴다.
 * 닫으면(바깥 탭 · 뒤로 가기 · 닫기) 원래 앱으로 돌아간다. 선택한 글을 바꾸지는 않으므로 결과는 돌려주지 않는다.
 * 화면은 Flutter · Compose 없이 뷰로 직접 그려 가볍게 뜨게 했다.
 */
class ProcessTextActivity : Activity() {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private var engine: MlKitTranslationEngine? = null
    private lateinit var card: LinearLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val text = selectedText()?.toString()?.take(SelectionTranslator.MAX_LENGTH)
        if (text.isNullOrBlank()) {
            finish()
            return
        }
        setContentView(buildRoot())
        showLoading()
        scope.launch {
            val settings = AppGraph.settingsRepository(this@ProcessTextActivity)
            val mlKit = MlKitTranslationEngine(
                downloadPolicyProvider = { ModelDownloadPolicy(settings.current().wifiOnlyModelDownload) },
            ).also { engine = it }
            val outcome = SelectionTranslator(mlKit).translate(text, settings.current().targetLanguage)
            if (outcome is SelectionOutcome.Translated) saveHistory(outcome)
            show(outcome)
        }
    }

    private fun selectedText(): CharSequence? =
        intent?.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)
            ?: intent?.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT_READONLY)

    override fun onDestroy() {
        scope.cancel()
        engine?.close()
        super.onDestroy()
    }

    /** 액티비티가 닫혀도 저장은 끝내도록 앱 전체 범위에서 돌린다. 실패해도 번역에는 영향이 없다. */
    private fun saveHistory(outcome: SelectionOutcome.Translated) {
        val context = applicationContext
        saveScope.launch {
            try {
                AppGraph.historyRepository(context).record(outcome.toHistoryOutcome())
            } catch (e: Exception) {
                Log.w(TAG, "번역 기록 저장 실패", e)
            }
        }
    }

    // ---- 화면 ----

    private fun buildRoot(): View {
        val root = FrameLayout(this).apply {
            setBackgroundColor(getColor(R.color.overlay_scrim))
            setOnClickListener { finish() }
        }
        card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = rounded(getColor(R.color.brand_surface), 28)
            setPadding(dp(20), dp(20), dp(20), dp(12))
            isClickable = true // 카드 안을 눌러도 닫히지 않게
            elevation = dp(8).toFloat()
        }
        val params = FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT,
            Gravity.CENTER,
        ).apply { setMargins(dp(24), dp(24), dp(24), dp(24)) }
        root.addView(card, params)
        return root
    }

    private fun showLoading() {
        card.removeAllViews()
        val row = LinearLayout(this).apply { gravity = Gravity.CENTER_VERTICAL }
        row.addView(ProgressBar(this).apply { isIndeterminate = true }, LinearLayout.LayoutParams(dp(24), dp(24)))
        row.addView(
            label(getString(R.string.selection_translating), 15f, R.color.brand_on_surface_variant)
                .apply { setPadding(dp(12), 0, 0, 0) },
        )
        card.addView(row)
        card.addView(buttonRow(null))
    }

    private fun show(outcome: SelectionOutcome) {
        card.removeAllViews()
        val locale = resources.configuration.locales[0]
        when (outcome) {
            is SelectionOutcome.Translated -> {
                card.addView(
                    label(
                        getString(
                            R.string.selection_languages,
                            languageDisplayName(outcome.sourceLanguage, locale),
                            languageDisplayName(outcome.targetLanguage, locale),
                        ),
                        13f,
                        R.color.brand_primary,
                        bold = true,
                    ),
                )
                card.addView(
                    label(outcome.original, 13f, R.color.brand_on_surface_variant).apply {
                        maxLines = 3
                        ellipsize = TextUtils.TruncateAt.END
                        setPadding(0, dp(8), 0, 0)
                    },
                )
                val translated = label(outcome.translated, 16f, R.color.brand_on_surface).apply {
                    setLineSpacing(0f, 1.25f)
                    setPadding(0, dp(8), 0, dp(8))
                    setTextIsSelectable(true)
                }
                card.addView(
                    ScrollView(this).apply { addView(translated) },
                    LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT),
                )
                card.addView(buttonRow(outcome.translated))
            }
            is SelectionOutcome.AlreadyInTarget -> message(
                getString(R.string.result_already_target_title),
                getString(R.string.result_already_target_body, languageDisplayName(outcome.targetLanguage, locale)),
            )
            SelectionOutcome.Empty -> finish()
            is SelectionOutcome.Failed -> {
                val (title, body) = translationFailureText(outcome.error)
                message(getString(title), getString(body))
            }
        }
    }

    private fun message(title: String, body: String) {
        card.addView(label(title, 18f, R.color.brand_on_surface, bold = true))
        card.addView(label(body, 15f, R.color.brand_on_surface_variant).apply { setPadding(0, dp(8), 0, dp(8)) })
        card.addView(buttonRow(null))
    }

    /** 오른쪽 아래 버튼들: 닫기(글자 버튼) · 복사(채운 버튼, [copyText]가 있을 때만). */
    private fun buttonRow(copyText: String?): View {
        val row = LinearLayout(this).apply {
            gravity = Gravity.END or Gravity.CENTER_VERTICAL
            setPadding(0, dp(8), 0, 0)
        }
        row.addView(pill(getString(R.string.result_close), filled = false) { finish() })
        if (copyText != null) {
            val copy = pill(getString(R.string.result_copy), filled = true) {}
            copy.setOnClickListener {
                getSystemService(ClipboardManager::class.java)
                    .setPrimaryClip(ClipData.newPlainText(null, copyText))
                copy.text = getString(R.string.result_copied)
            }
            row.addView(copy)
        }
        return row
    }

    private fun pill(text: String, filled: Boolean, onClick: () -> Unit): TextView =
        label(text, 14f, if (filled) R.color.brand_on_primary else R.color.brand_primary, bold = true).apply {
            gravity = Gravity.CENTER
            minHeight = dp(40)
            setPadding(dp(16), 0, dp(16), 0)
            if (filled) background = rounded(getColor(R.color.brand_primary), 50)
            isClickable = true
            setOnClickListener { onClick() }
        }

    private fun label(text: String, sp: Float, colorRes: Int, bold: Boolean = false) = TextView(this).apply {
        this.text = text
        setTextSize(TypedValue.COMPLEX_UNIT_SP, sp)
        setTextColor(getColor(colorRes))
        if (bold) typeface = Typeface.DEFAULT_BOLD
    }

    private fun rounded(fill: Int, radiusDp: Int) = GradientDrawable().apply {
        setColor(fill)
        cornerRadius = dp(radiusDp).toFloat()
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

    private companion object {
        const val TAG = "ProcessTextActivity"
        val saveScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    }
}
