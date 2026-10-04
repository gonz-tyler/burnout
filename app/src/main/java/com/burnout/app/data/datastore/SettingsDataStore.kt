package com.burnout.app.data.datastore

import android.content.Context
import android.util.Log
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.burnout.app.domain.model.Persona
import com.burnout.app.domain.model.Gods
import com.burnout.app.domain.model.Sex
import com.burnout.app.domain.model.Style
import com.burnout.app.domain.service.GoalChange
import com.burnout.app.domain.service.StreakState
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import org.json.JSONArray
import org.json.JSONObject
import java.io.IOException
import java.time.LocalDate
import javax.inject.Inject
import javax.inject.Singleton

private val Context.dataStore by preferencesDataStore(name = "settings")

/**
 * Everything MainActivity needs before it can draw the first frame, read atomically from a
 * single snapshot. distinctUntilChanged() below means unrelated writes (e.g. streak updates)
 * don't re-emit this and don't recompose the root.
 */
data class UiSettings(
    val seedColor: Int,
    val themeMode: String,       // "light" | "dark" | "system"
    val dynamicColor: Boolean,
    val paletteStyle: String,    // PaletteStyle.name, parsed in the UI layer
    val language: String,

)

/** Per-feature switches. Each defaults to the style's preset until the user changes it. */
data class FeatureToggles(
    val streak: Boolean,
    val labors: Boolean,
    val ideals: Boolean,
    val goals: Boolean,
    val gods: String,
    val godsEnabled: Boolean,
) {
}

// Replaces ThemeSettingsProvider, LanguageProvider, GenderSettingsProvider,
// UnitSettingsProvider, and the seed-color part of your Appainter setup.
// These are key-value prefs, not relational data, so DataStore is the right
// fit rather than another Room table — same role Hive's misc boxes played.
@Singleton
class SettingsDataStore @Inject constructor(
    @ApplicationContext private val context: Context
) {
    companion object {
        // 0xFFC9A24B = the warm antique-gold default from app_theme.dart
        const val DEFAULT_SEED = 0xFFC9A24B.toInt()
        const val DEFAULT_PALETTE_STYLE = "TonalSpot"
        const val LANGUAGE_SYSTEM = "system"
    }

    private object Keys {
        val SEED_COLOR = intPreferencesKey("seed_color_argb")
        val THEME_MODE = stringPreferencesKey("theme_mode") // "light" | "dark" | "system"
        val DYNAMIC_COLOR = booleanPreferencesKey("dynamic_color")
        val PALETTE_STYLE = stringPreferencesKey("palette_style") // PaletteStyle.name
        val UNIT_SYSTEM = stringPreferencesKey("unit_system") // "metric" | "imperial"
        val GODS = stringPreferencesKey("gods_option")
        val LANGUAGE = stringPreferencesKey("language_code")
        val GENDER = stringPreferencesKey("gender") // LEGACY: read-only, only used to migrate
        val SEX = stringPreferencesKey("sex")       // Sex.name
        val STYLE = stringPreferencesKey("style")   // Style.name
        val FEATURE_STREAK = booleanPreferencesKey("feature_streak")
        val FEATURE_LABORS = booleanPreferencesKey("feature_labors")
        val FEATURE_IDEALS = booleanPreferencesKey("feature_ideals")
        val FEATURE_GOALS = booleanPreferencesKey("feature_goals")
        val FEATURE_GODS = booleanPreferencesKey("feature_gods")
        val WEEKLY_GOAL = intPreferencesKey("weekly_goal")
        val REMINDER_TIME = stringPreferencesKey("reminder_time")
        val NOTIFICATIONS_ENABLED = booleanPreferencesKey("notifications_enabled")

        val STREAK_STATE = stringPreferencesKey("streak_state")
    }

    // One shared upstream: an unreadable/corrupt file falls back to defaults instead of
    // crashing every collector.
    private val prefs: Flow<Preferences> = context.dataStore.data.catch {
        if (it is IOException) emit(emptyPreferences()) else throw it
    }

    val uiSettings: Flow<UiSettings> = prefs.map {
        UiSettings(
            seedColor = it.effectiveSeed(),
            themeMode = it[Keys.THEME_MODE] ?: "system",
            dynamicColor = it[Keys.DYNAMIC_COLOR] ?: false,
            paletteStyle = it[Keys.PALETTE_STYLE] ?: DEFAULT_PALETTE_STYLE,
            language = it[Keys.LANGUAGE] ?: LANGUAGE_SYSTEM,
        )
    }.distinctUntilChanged()

    // --- Sex / Style (replaces the single "gender" string) ---------------------------------
    // Lazy migration: until the user sets either one, fall back to the legacy value.
    //   "male" -> MALE+HARD, "female" -> FEMALE+HARD, "female_soft" -> FEMALE+SOFT
    private fun Preferences.resolveSex(): Sex =
        this[Keys.SEX]?.let { runCatching { Sex.valueOf(it) }.getOrNull() }
            ?: if (this[Keys.GENDER]?.startsWith("female") == true) Sex.FEMALE else Sex.MALE

    private fun Preferences.resolveStyle(): Style =
        this[Keys.STYLE]?.let { runCatching { Style.valueOf(it) }.getOrNull() }
            ?: if (this[Keys.GENDER] == "female_soft") Style.SOFT else Style.HARD

    private fun Preferences.resolveGods(): String = this[Keys.GODS] ?: "both"

    // No stored seed = "follow the persona", so switching persona never overwrites a colour
    // the user picked on purpose.
    private fun Preferences.effectiveSeed(): Int =
        this[Keys.SEED_COLOR] ?: Persona.from(resolveSex(), resolveStyle()).defaultSeed

    // Unset = follow the style preset (HARD -> on, SOFT -> off). Existing installs therefore
    // need no migration: their legacy gender already resolves to the right style.
    private fun Preferences.presetOn(): Boolean = resolveStyle() == Style.HARD
    private fun Preferences.streakOn(): Boolean = this[Keys.FEATURE_STREAK] ?: presetOn()
    private fun Preferences.laborsOn(): Boolean = this[Keys.FEATURE_LABORS] ?: presetOn()
    private fun Preferences.idealsOn(): Boolean = this[Keys.FEATURE_IDEALS] ?: presetOn()
    private fun Preferences.goalsOn(): Boolean = this[Keys.FEATURE_GOALS] ?: presetOn()
    private fun Preferences.godsOn(): Boolean = this[Keys.FEATURE_GODS] ?: presetOn()


    val sex: Flow<Sex> = prefs.map { it.resolveSex() }.distinctUntilChanged()
    val style: Flow<Style> = prefs.map { it.resolveStyle() }.distinctUntilChanged()

    /** Derived from sex + style. */
    val persona: Flow<Persona> = prefs.map { Persona.from(it.resolveSex(), it.resolveStyle()) }.distinctUntilChanged()

    val streakEnabled: Flow<Boolean> = prefs.map { it.streakOn() }.distinctUntilChanged()
    val laborsEnabled: Flow<Boolean> = prefs.map { it.laborsOn() }.distinctUntilChanged()
    val idealsEnabled: Flow<Boolean> = prefs.map { it.idealsOn() }.distinctUntilChanged()
    val goalsEnabled: Flow<Boolean> = prefs.map { it.goalsOn() }.distinctUntilChanged()
    val godsEnabled: Flow<Boolean> = prefs.map { it.godsOn() }.distinctUntilChanged()
//    val gods: Flow<String> = prefs.map { it.resolveGods() }.distinctUntilChanged()


    /** All three together, for code that gates several features at once. */
    val features: Flow<FeatureToggles> = prefs.map {
        FeatureToggles(streak = it.streakOn(), labors = it.laborsOn(), ideals = it.idealsOn(), goals = it.goalsOn(), gods = it.resolveGods(), godsEnabled = it.godsOn())
    }.distinctUntilChanged()

    val seedColor: Flow<Int> = prefs.map { it.effectiveSeed() }
    val themeMode: Flow<String> = prefs.map { it[Keys.THEME_MODE] ?: "system" }
    val dynamicColor: Flow<Boolean> = prefs.map { it[Keys.DYNAMIC_COLOR] ?: false }
    val paletteStyle: Flow<String> = prefs.map { it[Keys.PALETTE_STYLE] ?: DEFAULT_PALETTE_STYLE }
    val unitSystem: Flow<String> = prefs.map { it[Keys.UNIT_SYSTEM] ?: "metric" }
    val language: Flow<String> = prefs.map { it[Keys.LANGUAGE] ?: LANGUAGE_SYSTEM }
    val gods: Flow<String> = prefs.map { it[Keys.GODS] ?: "both" }
    /**
     * Bridge for code that still reads the old string. Migrate those call sites to sex/style
     * (e.g. `gender != "female_soft"` -> `style == Style.HARD`) and then delete this.
     * Note MALE+SOFT has no legacy equivalent and maps to "male".
     */
    @Deprecated("Use sex / style / persona")
    val gender: Flow<String> = prefs.map {
        when (it.resolveSex() to it.resolveStyle()) {
            Sex.FEMALE to Style.HARD -> "female"
            Sex.FEMALE to Style.SOFT -> "female_soft"
            else -> "male"
        }
    }
    val weeklyGoal: Flow<Int> = prefs.map { it[Keys.WEEKLY_GOAL] ?: 3 }
    val reminderTime: Flow<String> = prefs.map { it[Keys.REMINDER_TIME] ?: "09:00" }
    val notificationsEnabled: Flow<Boolean> = prefs.map { it[Keys.NOTIFICATIONS_ENABLED] ?: true }

    val streakState: Flow<StreakState> = prefs.map {
        it[Keys.STREAK_STATE]?.let(StreakStateJson::decode) ?: StreakState()
    }

    suspend fun setSeedColor(argb: Int) { context.dataStore.edit { it[Keys.SEED_COLOR] = argb } }
    suspend fun setThemeMode(mode: String) { context.dataStore.edit { it[Keys.THEME_MODE] = mode } }
    suspend fun setDynamicColor(enabled: Boolean) { context.dataStore.edit { it[Keys.DYNAMIC_COLOR] = enabled } }
    suspend fun setPaletteStyle(styleName: String) { context.dataStore.edit { it[Keys.PALETTE_STYLE] = styleName } }
    suspend fun setUnitSystem(system: String) { context.dataStore.edit { it[Keys.UNIT_SYSTEM] = system } }
    suspend fun setLanguage(code: String) { context.dataStore.edit { it[Keys.LANGUAGE] = code } }
    suspend fun setGods(gods: String) { context.dataStore.edit { it[Keys.GODS] = gods } }

    // Setting one axis pins the other, so the legacy "gender" value stops mattering after this.
    suspend fun setSex(sex: Sex) {
        context.dataStore.edit {
            val style = it.resolveStyle()
            it[Keys.SEX] = sex.name
            it[Keys.STYLE] = style.name
        }
    }
    /** Picking a style also applies its preset: HARD turns every feature on, SOFT turns them all off. */
    suspend fun setStyle(style: Style) {
        context.dataStore.edit {
            val sex = it.resolveSex()
            val on = style == Style.HARD
            it[Keys.SEX] = sex.name
            it[Keys.STYLE] = style.name
            it[Keys.FEATURE_STREAK] = on
            it[Keys.FEATURE_LABORS] = on
            it[Keys.FEATURE_IDEALS] = on
        }
    }
    suspend fun setStreakEnabled(enabled: Boolean) { context.dataStore.edit { it[Keys.FEATURE_STREAK] = enabled } }
    suspend fun setLaborsEnabled(enabled: Boolean) { context.dataStore.edit { it[Keys.FEATURE_LABORS] = enabled } }
    suspend fun setIdealsEnabled(enabled: Boolean) { context.dataStore.edit { it[Keys.FEATURE_IDEALS] = enabled } }
    suspend fun setGoalsEnabled(enabled: Boolean) { context.dataStore.edit { it[Keys.FEATURE_GOALS] = enabled } }
    suspend fun setGodsEnabled(enabled: Boolean) { context.dataStore.edit { it[Keys.FEATURE_GODS] = enabled } }

    /** Back to "follow the persona's default colour". */
    suspend fun clearSeedColor() { context.dataStore.edit { it.remove(Keys.SEED_COLOR) } }
    suspend fun setWeeklyGoal(days: Int) { context.dataStore.edit { it[Keys.WEEKLY_GOAL] = days } }
    suspend fun setReminderTime(time: String) { context.dataStore.edit { it[Keys.REMINDER_TIME] = time } }
    suspend fun setNotificationsEnabled(enabled: Boolean) { context.dataStore.edit { it[Keys.NOTIFICATIONS_ENABLED] = enabled } }

    suspend fun updateStreakState(transform: (StreakState) -> StreakState) {
        context.dataStore.edit { prefs ->
            val current = prefs[Keys.STREAK_STATE]?.let(StreakStateJson::decode) ?: StreakState()
            prefs[Keys.STREAK_STATE] = StreakStateJson.encode(transform(current))
        }
    }


    object StreakStateJson {
        fun encode(s: StreakState): String = JSONObject().apply {
            put("start", s.startDate?.toString() ?: JSONObject.NULL)
            put("broken", s.brokenThrough?.toString() ?: JSONObject.NULL)
            put("goals", JSONArray().also { arr ->
                s.goalHistory.forEach {
                    arr.put(JSONObject().put("from", it.effectiveFrom.toString()).put("goal", it.goal))
                }
            })
        }.toString()

        fun decode(json: String): StreakState = runCatching {
            val o = JSONObject(json)
            val goals = o.getJSONArray("goals")
            StreakState(
                startDate = if (o.isNull("start")) null else LocalDate.parse(o.getString("start")),
                brokenThrough = if (o.isNull("broken")) null else LocalDate.parse(o.getString("broken")),
                goalHistory = (0 until goals.length()).map {
                    val g = goals.getJSONObject(it)
                    GoalChange(LocalDate.parse(g.getString("from")), g.getInt("goal"))
                }
            )
        }.onFailure {
            Log.w("SettingsDataStore", "Failed to decode streak state, resetting", it)
        }.getOrDefault(StreakState())
    }
}