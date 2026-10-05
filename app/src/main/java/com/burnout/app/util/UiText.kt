package com.burnout.app.util

import androidx.annotation.StringRes
import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource

sealed class UiText {
    // For regular strings (e.g., from an API or hardcoded)
    data class DynamicString(val value: String) : UiText()

    // For string resources, including optional arguments (like your weeklyGoal)
    class StringResource(
        @StringRes val resId: Int,
        vararg val args: Any
    ) : UiText()

    @Composable
    fun asString(): String {
        return when (this) {
            is DynamicString -> value
            is StringResource -> stringResource(resId, *args)
        }
    }
}