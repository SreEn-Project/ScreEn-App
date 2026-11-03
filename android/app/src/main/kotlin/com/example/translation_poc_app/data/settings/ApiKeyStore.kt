package com.example.translation_poc_app.data.settings

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import java.security.KeyStore
import java.security.MessageDigest
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.PBEKeySpec
import javax.crypto.spec.GCMParameterSpec

/**
 * AI 번역 API 키 보관 (NA-13). Android Keystore의 AES 키로 암호화해 앱 전용 저장소에만 둔다.
 * 엔진(Gemini · Groq)마다 따로 두고, 키 접근 PIN(4자리)은 두 키가 같이 쓴다. PIN은 salt + PBKDF2 해시만 같은 Keystore 키로 암호화해 두고, 원문은 저장하지 않는다.
 * 키 값은 로그 · 설정 이벤트로 내보내지 않는다. 설정 화면이 가려서 보여 주려고 Flutter로는 [get]으로만 준다.
 */
class ApiKeyStore(context: Context) {
    private val prefs = context.applicationContext.getSharedPreferences(FILE, Context.MODE_PRIVATE)

    /** 엔진마다 키를 따로 보관한다. AI 엔진이 아니면 항상 null. */
    fun get(engine: Engine): String? = entry(engine)?.let { decrypt(it) }?.let { String(it) }

    fun set(engine: Engine, key: String) {
        val entry = entry(engine) ?: return
        encrypt(entry, key.filterNot { it.isWhitespace() }.toByteArray())
    }

    fun clear(engine: Engine) {
        val entry = entry(engine) ?: return
        prefs.edit().remove(entry).apply()
    }

    private fun entry(engine: Engine): String? = when (engine) {
        Engine.GEMINI -> GEMINI_ENTRY
        Engine.GROQ -> GROQ_ENTRY
        Engine.ML_KIT, Engine.GEMMA -> null
    }

    /** Gemma 모델을 받을 때 쓰는 Hugging Face 토큰 (#174). 키와 같은 Keystore 키로 암호화한다. */
    fun huggingFaceToken(): String? = decrypt(HF_ENTRY)?.let { String(it) }?.takeIf { it.isNotBlank() }

    fun setHuggingFaceToken(token: String) {
        encrypt(HF_ENTRY, token.filterNot { it.isWhitespace() }.toByteArray())
    }

    fun clearHuggingFaceToken() {
        prefs.edit().remove(HF_ENTRY).apply()
    }

    /** 키 접근 PIN이 켜져 있는지. PIN 자료가 있으나 읽을 수 없으면(Keystore 키 분실) 켜진 것으로 본다. */
    fun isPinEnabled(): Boolean = prefs.contains(PIN_ENTRY)

    /** PIN이 없으면 항상 true. */
    fun verifyPin(pin: String): Boolean {
        if (!isPinEnabled()) return true
        val stored = decrypt(PIN_ENTRY) ?: return false
        if (stored.size != SALT_BYTES + HASH_BYTES) return false
        val salt = stored.copyOfRange(0, SALT_BYTES)
        val expected = stored.copyOfRange(SALT_BYTES, stored.size)
        return MessageDigest.isEqual(expected, hash(pin, salt))
    }

    /** PIN을 켜거나 바꾼다. 이미 PIN이 있으면 [currentPin]이 맞아야 한다. 형식이 틀려도 false. */
    fun setPin(newPin: String, currentPin: String?): Boolean {
        if (!isValidPin(newPin)) return false
        if (isPinEnabled() && (currentPin == null || !verifyPin(currentPin))) return false
        val salt = ByteArray(SALT_BYTES).also { SecureRandom().nextBytes(it) }
        encrypt(PIN_ENTRY, salt + hash(newPin, salt))
        return true
    }

    fun clearPin(currentPin: String): Boolean {
        if (!verifyPin(currentPin)) return false
        prefs.edit().remove(PIN_ENTRY).apply()
        return true
    }

    /** PIN 분실: 키와 PIN을 함께 지운다. */
    fun reset() {
        prefs.edit().remove(GEMINI_ENTRY).remove(GROQ_ENTRY).remove(HF_ENTRY).remove(PIN_ENTRY).apply()
    }

    private fun isValidPin(pin: String) = pin.length == PIN_LENGTH && pin.all { it in '0'..'9' }

    private fun hash(pin: String, salt: ByteArray): ByteArray {
        val spec = PBEKeySpec(pin.toCharArray(), salt, PBKDF_ROUNDS, HASH_BYTES * 8)
        return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).encoded
    }

    private fun encrypt(entry: String, plain: ByteArray) {
        val cipher = Cipher.getInstance(TRANSFORM)
        cipher.init(Cipher.ENCRYPT_MODE, secretKey())
        val encrypted = cipher.iv + cipher.doFinal(plain)
        prefs.edit().putString(entry, Base64.encodeToString(encrypted, Base64.NO_WRAP)).apply()
    }

    private fun decrypt(entry: String): ByteArray? {
        val stored = prefs.getString(entry, null) ?: return null
        return try {
            val raw = Base64.decode(stored, Base64.NO_WRAP)
            val cipher = Cipher.getInstance(TRANSFORM)
            cipher.init(Cipher.DECRYPT_MODE, secretKey(), GCMParameterSpec(TAG_BITS, raw.copyOfRange(0, IV_BYTES)))
            cipher.doFinal(raw, IV_BYTES, raw.size - IV_BYTES)
        } catch (e: Exception) {
            // Keystore 키가 사라진 경우(백업 복원 등) 읽을 수 없다 → 없음으로 취급한다 (등록됨으로 보이지 않게).
            null
        }
    }

    private fun secretKey(): SecretKey {
        val store = KeyStore.getInstance(PROVIDER).apply { load(null) }
        (store.getKey(ALIAS, null) as? SecretKey)?.let { return it }
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, PROVIDER)
        generator.init(
            KeyGenParameterSpec.Builder(ALIAS, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .build(),
        )
        return generator.generateKey()
    }

    private companion object {
        const val FILE = "api_key_store"
        const val GEMINI_ENTRY = "gemini"
        const val GROQ_ENTRY = "groq"
        const val HF_ENTRY = "huggingface"
        const val PIN_ENTRY = "pin"
        const val PIN_LENGTH = 4
        const val SALT_BYTES = 16
        const val HASH_BYTES = 32
        const val PBKDF_ROUNDS = 10_000
        const val ALIAS = "screen_api_key"
        const val PROVIDER = "AndroidKeyStore"
        const val TRANSFORM = "AES/GCM/NoPadding"
        const val IV_BYTES = 12
        const val TAG_BITS = 128
    }
}
