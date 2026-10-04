package com.burnout.app.domain.model

import androidx.annotation.StringRes
import com.burnout.app.R

/** Drives strength standards, body-ideal ratios and the muscle diagram figure. */
enum class Sex { MALE, FEMALE }

/** Drives the feel: which features are on by default, and the tone. */
enum class Style { HARD, SOFT }

/**
 * Derived from Sex + Style, never stored.
 * nameRes is a string resource ID; resolve it in the UI with stringResource(persona.nameRes).
 * defaultSeed is only used while the user hasn't picked a colour themselves.
 * TODO: copy the per-persona colours over from your old AppPersona.defaultSeedColor values.
 */
enum class Persona(@StringRes val nameRes: Int, val defaultSeed: Int) {
    GRECIAN_HERO(R.string.persona_grecian_hero, 0xFFC9A24B.toInt()),
    PHILOSOPHER(R.string.persona_philosopher, 0xFFC9A24B.toInt()),
    AMAZONIAN_WARRIOR(R.string.persona_amazonian_warrior, 0xFFC9A24B.toInt()),
    MUSE(R.string.persona_muse, 0xFFC9A24B.toInt());

    companion object {
        fun from(sex: Sex, style: Style): Persona = when (sex) {
            Sex.MALE -> if (style == Style.HARD) GRECIAN_HERO else PHILOSOPHER
            Sex.FEMALE -> if (style == Style.HARD) AMAZONIAN_WARRIOR else MUSE
        }
    }
}