package com.burnout.app.ui.dashboard.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.WarningAmber
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.burnout.app.ui.theme.AppTheme

private val AmberFill = Color(0x26FFC107) // rgba(255,193,7,0.15)
private val AmberBorder = Color(0x4DFFC107) // rgba(255,193,7,0.3)
private val AmberText = Color(0xFFFF8F00) // rgba(255,143,0,1)

/** Amber banner used to flag a muscle-group imbalance warning. */
@Composable
fun WarningCard(warning: String, modifier: Modifier = Modifier) {
    Row(
        verticalAlignment = Alignment.Top,
        modifier = modifier
            .fillMaxWidth()
            .padding(bottom = 8.dp)
            .background(AmberFill, RoundedCornerShape(AppTheme.radiusS))
            .border(BorderStroke(1.dp, AmberBorder), RoundedCornerShape(AppTheme.radiusS))
            .padding(12.dp),
    ) {
        Icon(
            imageVector = Icons.Rounded.WarningAmber,
            contentDescription = null,
            tint = AmberText,
            modifier = Modifier,
        )
        Spacer(Modifier.width(12.dp))
        Text(
            text = warning,
            color = AmberText,
            fontSize = 13.sp,
            fontWeight = androidx.compose.ui.text.font.FontWeight.Medium,
            modifier = Modifier.weight(1f, fill = true),
        )
    }
}
