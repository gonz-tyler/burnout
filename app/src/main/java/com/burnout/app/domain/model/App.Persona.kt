package com.burnout.app.domain.model

import androidx.compose.ui.graphics.Color

enum class AppPersona(
    val storageKey: String,
    val baseGender: String,
    val titlePrefix: String,
    val laborsSectionTitle: String,
    val showHardcoreLabors: Boolean,
    val defaultSeedColor: Long
) {
    GRECIAN_HERO(
        storageKey = "grecian_hero",
        baseGender = "male",
        titlePrefix = "Grecian",
        laborsSectionTitle = "Herculean Labors",
        showHardcoreLabors = true,
        defaultSeedColor = 0xFFC9A24B // Classic Gold
    ),
    AMAZONIAN_WARRIOR(
        storageKey = "amazonian_warrior",
        baseGender = "female",
        titlePrefix = "Amazonian",
        laborsSectionTitle = "Amazonian Labors",
        showHardcoreLabors = true,
        defaultSeedColor = 0xFFB71C1C // Crimson Bronze
    ),
    SOFT_GODDESS(
        storageKey = "soft_goddess",
        baseGender = "female",
        titlePrefix = "Goddess",
        laborsSectionTitle = "Milestones & Rituals",
        showHardcoreLabors = false,
        defaultSeedColor = 0xFFE8B4B8 // Soft Rose Gold
    );

    companion object {
        fun fromKey(key: String): AppPersona {
            return entries.find { it.storageKey == key } ?: GRECIAN_HERO
        }

        fun fromGender(gender: String): AppPersona {
            return when (gender.lowercase()) {
                "female" -> AMAZONIAN_WARRIOR
                "female_soft" -> SOFT_GODDESS
                else -> GRECIAN_HERO
            }
        }
    }
}