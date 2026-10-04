package com.burnout.app.data.local.entity

import kotlinx.serialization.Serializable

@Serializable
enum class SetType { WARMUP, NORMAL, FAILURE, DROPSET }

// Port of the SetTypeAbbreviation extension in enums.dart.
val SetType.abbreviation: String
    get() = when (this) {
        SetType.WARMUP -> "W"
        SetType.NORMAL -> "N"
        SetType.FAILURE -> "F"
        SetType.DROPSET -> "D"
    }
