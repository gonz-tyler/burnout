package com.burnout.app.ui.dashboard.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.burnout.app.R
import com.burnout.app.domain.model.StatsPeriod
import com.core.designsystem.theme.AppTheme
import kotlinx.coroutines.delay

/** Row of WEEK / MONTH / ALL TIME pills controlling the muscle-focus period. */
@Composable
fun PeriodSelector(
    selectedPeriod: StatsPeriod,
    onPeriodSelected: (StatsPeriod) -> Unit,
    periods: List<StatsPeriod> = StatsPeriod.entries,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(40.dp)
            .background(MaterialTheme.colorScheme.surfaceContainer, RoundedCornerShape(20.dp)),
    ) {
        periods.forEach { period ->
            PeriodPill(
                title = stringResource(period.labelRes).uppercase(),
                isSelected = selectedPeriod == period,
                onTap = { onPeriodSelected(period) },
                modifier = Modifier.weight(1f),
            )
        }
    }
}

@Composable
private fun RowScope.PeriodPill(
    title: String,
    isSelected: Boolean,
    onTap: () -> Unit,
    modifier: Modifier = Modifier,
) {
    var isAnimating by remember { mutableStateOf(false) }
    val scale by animateFloatAsState(
        targetValue = if (isAnimating) 1.05f else 1f,
        animationSpec = tween(250),
        label = "pill-scale",
    )

    androidx.compose.runtime.LaunchedEffect(isAnimating) {
        if (isAnimating) {
            delay(250)
            isAnimating = false
        }
    }

    Box(
        modifier = modifier
            .padding(4.dp)
            .scale(scale)
            .background(
                color = if (isSelected) MaterialTheme.colorScheme.primary else androidx.compose.ui.graphics.Color.Transparent,
                shape = RoundedCornerShape(AppTheme.radiusS),
            )
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
            ) {
                onTap()
                isAnimating = true
            },
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = title,
            color = if (isSelected) MaterialTheme.colorScheme.onPrimary else MaterialTheme.colorScheme.onSurfaceVariant,
            fontWeight = FontWeight.Bold,
            style = MaterialTheme.typography.labelLarge,
            modifier = Modifier.padding(vertical = 8.dp),
        )
    }
}
