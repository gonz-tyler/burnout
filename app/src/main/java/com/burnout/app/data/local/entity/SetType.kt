package com.burnout.app.data.local.entity

import androidx.annotation.StringRes
import com.burnout.app.R
import kotlinx.serialization.Serializable

@Serializable
enum class SetType { WARMUP, NORMAL, FAILURE, DROPSET }

// Port of the SetTypeAbbreviation extension in enums.dart.
@get:StringRes
val SetType.abbreviationRes: Int
    get() = when (this) {
        SetType.WARMUP -> R.string.set_type_warmup_abbr
        SetType.NORMAL -> R.string.set_type_normal_abbr
        SetType.FAILURE -> R.string.set_type_failure_abbr
        SetType.DROPSET -> R.string.set_type_dropset_abbr
    }