package com.burnout.app.ui.dashboard.components

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.VectorConverter
import androidx.compose.animation.core.tween
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.TextUnit

private val EaseOutCubic = CubicBezierEasing(0.215f, 0.61f, 0.355f, 1f)

/**
 * Port of delayed_animated_number.dart: animates a number from 0 up to
 * [value], starting ~300ms after first composition, so numbers "count up"
 * into place instead of popping in instantly.
 *
 * Uses standard Material 3 Text parameters so font families and app themes
 * resolve automatically without relying on LocalTextStyle.
 */
@Composable
fun DelayedAnimatedNumber(
    value: Double,
    formatter: (Double) -> String,
    modifier: Modifier = Modifier,
    fontSize: TextUnit = TextUnit.Unspecified,
    fontWeight: FontWeight? = null,
    color: Color = Color.Unspecified,
    lineHeight: TextUnit = TextUnit.Unspecified,
) {
    var hasAnimated by rememberSaveable { mutableStateOf(false) }

    val animatable = remember {
        Animatable(
            initialValue = if (hasAnimated) value.toFloat() else 0f,
            typeConverter = Float.VectorConverter
        )
    }

    LaunchedEffect(value) {
        if (!hasAnimated) {
            kotlinx.coroutines.delay(300)
            animatable.animateTo(
                targetValue = value.toFloat(),
                animationSpec = tween(durationMillis = 700, easing = EaseOutCubic),
            )
            hasAnimated = true
        } else {
            animatable.snapTo(value.toFloat())
        }
    }

    Text(
        text = formatter(animatable.value.toDouble()),
        modifier = modifier,
        color = color,
        fontSize = fontSize,
        fontWeight = fontWeight,
        lineHeight = lineHeight,
    )
}