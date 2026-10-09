package com.burnout.app.ui.dashboard.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.AccessibilityNew
import androidx.compose.material.icons.rounded.Lock
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.burnout.app.R
import com.burnout.app.data.local.entity.BodyMeasurement
import com.core.designsystem.theme.AppTheme

/**
 * The big focal "V-Taper ratio" bubble in the dashboard's hero section.
 */
@Composable
fun VTaperBubble(
    latest: BodyMeasurement?,
    modifier: Modifier = Modifier, // <-- Allows setting width/height/size externally
    lockedLabel: String = stringResource(R.string.log_for_vtaper),
    vTaperLabel: String = stringResource(R.string.vtaper_ratio).uppercase(),
) {
    val theme = MaterialTheme.colorScheme

    if (latest == null || latest.shoulders == null || latest.waist == null || latest.waist == 0.0) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = modifier
                .background(theme.surfaceContainerLowest, RoundedCornerShape(AppTheme.radiusL))
                .padding(horizontal = 24.dp, vertical = 16.dp),
        ) {
            Icon(
                imageVector = Icons.Rounded.Lock,
                contentDescription = null,
                tint = theme.onSurfaceVariant,
                modifier = Modifier.padding(end = 12.dp),
            )
            Text(
                text = lockedLabel,
                color = theme.onSurfaceVariant,
                fontSize = 13.sp,
                fontWeight = FontWeight.SemiBold,
            )
        }
        return
    }

    val ratio = latest.shoulders / latest.waist
    val rating = when {
        ratio < 1.4 -> stringResource(R.string.mortal).uppercase()
        ratio < 1.55 -> stringResource(R.string.hero).uppercase()
        ratio < 1.65 -> stringResource(R.string.demigod).uppercase()
        else -> stringResource(R.string.god).uppercase()
    }

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(55.dp)) // <-- Adjust corner rounding here
            .background(theme.secondaryContainer),
        contentAlignment = Alignment.Center,
    ) {
        Box(modifier = Modifier.fillMaxSize().background(theme.primary.copy(alpha = 0.2f)))

        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            // <-- Adjust internal card padding here to expand or contract content size
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 24.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Rounded.AccessibilityNew,
                    contentDescription = null,
                    tint = theme.onSecondaryContainer,
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    text = vTaperLabel,
                    color = theme.onSecondaryContainer.copy(alpha = 0.8f),
                    fontSize = 12.sp,
                    letterSpacing = 2.sp,
                    fontWeight = FontWeight.ExtraBold,
                )
            }
            Spacer(Modifier.height(8.dp))
            DelayedAnimatedNumber(
                value = ratio,
                formatter = { "%.2f".format(it) },
                fontSize = 64.sp,
                fontWeight = FontWeight.Bold,
                color = theme.onSecondaryContainer,
                lineHeight = 64.sp,
            )
            Spacer(Modifier.height(8.dp))
            Box(
                modifier = Modifier
                    .background(theme.onSecondaryContainer.copy(alpha = 0.1f), RoundedCornerShape(20.dp))
                    .padding(horizontal = 12.dp, vertical = 6.dp),
            ) {
                Text(
                    text = rating,
                    color = theme.onSecondaryContainer,
                    fontWeight = FontWeight.Bold,
                    fontSize = 12.sp,
                    letterSpacing = 1.5.sp,
                )
            }
        }
    }
}