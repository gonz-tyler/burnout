package com.burnout.app.ui.dashboard.components

import com.burnout.app.R
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Lock
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * One card in the horizontally-scrolling "Pantheon" list — shows a lift's
 * personal record, or a locked state if there isn't one yet.
 * Port of god_card.dart, including the alternating asymmetric corner radius.
 */
@Composable
fun GodCard(
    godName: String,
    liftName: String,
    weight: Double,
    unitString: String,
    color: Color,
    icon: ImageVector,
    index: Int,
    onTap: () -> Unit,
    lockedLabel: String = stringResource(R.string.locked).uppercase(),
    maxLabel: String = stringResource(R.string.max).uppercase(),
) {
    val isLocked = weight == 0.0
    val bgColor = if (isLocked) MaterialTheme.colorScheme.surfaceContainerHighest else color
    val isEven = index % 2 == 0

    val shape = RoundedCornerShape(
        topStart = if (isEven) 40.dp else 12.dp,
        topEnd = if (isEven) 12.dp else 40.dp,
        bottomStart = if (isEven) 12.dp else 40.dp,
        bottomEnd = if (isEven) 40.dp else 12.dp,
    )

    Box(
        modifier = Modifier
            .width(140.dp)
            .height(180.dp)
            .clip(shape)
            .background(bgColor)
            .clickable(onClick = onTap),
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier
                .size(130.dp)
                .align(Alignment.BottomEnd)
                .offset(x = 24.dp, y = 24.dp)
                .rotate(-11.5f), // -0.2 rad
            tint = if (isLocked)
                MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.1f)
            else
                Color.White.copy(alpha = 0.15f),
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            verticalArrangement = androidx.compose.foundation.layout.Arrangement.SpaceBetween,
        ) {
            Column {
                Text(
                    text = godName,
                    color = if (isLocked) MaterialTheme.colorScheme.onSurfaceVariant else Color.White.copy(alpha = 0.7f),
                    fontWeight = FontWeight.Black,
                    fontSize = 10.sp,
                    letterSpacing = 1.5.sp,
                )
                Spacer(Modifier.height(2.dp))
                Text(
                    text = liftName,
                    color = if (isLocked) MaterialTheme.colorScheme.onSurface else Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 13.sp,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
            }

            if (isLocked) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Rounded.Lock,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f),
                        modifier = Modifier.size(16.dp),
                    )
                    Spacer(Modifier.width(4.dp))
                    Text(
                        text = lockedLabel,
                        color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.8f),
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                    )
                }
            } else {
                Column {
                    Text(
                        text = "%.1f".format(weight),
                        color = Color.White,
                        fontSize = 26.sp,
                        fontWeight = FontWeight.Black,
                        lineHeight = 26.sp,
                    )
                    Text(
                        text = "${unitString.uppercase()} $maxLabel",
                        color = Color.White.copy(alpha = 0.8f),
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                    )
                }
            }
        }
    }
}
