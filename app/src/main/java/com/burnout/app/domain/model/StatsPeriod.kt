package com.burnout.app.domain.model

import androidx.annotation.StringRes
import com.burnout.app.R

enum class StatsPeriod(@StringRes val labelRes: Int) {
    WEEK(R.string.week),
    MONTH(R.string.month),
    ALL_TIME(R.string.all_time),
}