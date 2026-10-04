package com.burnout.app.ui.dashboard.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * A small floating pill showing one stat (streak, tonnage, etc.) with an
 * icon, value + unit, and a title label. Port of stat_bubble.dart.
 */
@Composable
fun StatBubble(
    title: String,
    value: String,
    unit: String,
    icon: ImageVector,
    bgColor: Color,
    fgColor: Color,
) {
    Row(
        modifier = Modifier
            .background(bgColor, RoundedCornerShape(40.dp))
            .padding(horizontal = 24.dp, vertical = 18.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = fgColor, modifier = Modifier)
        Spacer(Modifier.width(12.dp))
        Column {
            Row(verticalAlignment = Alignment.Bottom) {
                Text(
                    text = value,
                    fontSize = 26.sp,
                    fontWeight = FontWeight.Black,
                    color = fgColor,
                    lineHeight = 26.sp,
                )
                Spacer(Modifier.width(4.dp))
                Text(
                    text = unit,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = fgColor.copy(alpha = 0.7f),
                )
            }
            Text(
                text = title,
                color = fgColor.copy(alpha = 0.7f),
                fontSize = 10.sp,
                letterSpacing = 1.2.sp,
                fontWeight = FontWeight.ExtraBold,
            )
        }
    }
}
