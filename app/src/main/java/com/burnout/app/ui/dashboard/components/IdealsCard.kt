package com.burnout.app.ui.dashboard.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.Straighten
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.burnout.app.R
import com.burnout.app.data.local.entity.BodyMeasurement
import com.burnout.app.domain.model.Sex
import com.burnout.app.domain.model.Style
import com.core.designsystem.theme.AppTheme
import com.burnout.app.util.LengthConverter
import com.burnout.app.util.UnitSystem
import kotlin.math.abs
import kotlin.math.max

/** Placeholder WHR target, used when the ideals map has no "WHR" entry. Tune to taste. */
private const val DEFAULT_WHR_TARGET = 0.75

/**
 * Everyone sees every measurement. Only the goals differ:
 *  - HARD + male   -> V-taper goals on each measurement (from the ideals map)
 *  - HARD + female -> a waist-to-hip ratio (WHR) goal
 *  - SOFT (either) -> pure tracker: values and left/right balance, no goals
 */
@Composable
fun IdealsCard(
    current: BodyMeasurement?,
    ideals: Map<String, Double>,
    unitSystem: UnitSystem,
    sex: Sex,
    style: Style
) {
    val isFemale = sex == Sex.FEMALE
    val isHard = style == Style.HARD
    val showVTaperGoals = isHard && !isFemale
    val showWhrGoal = isHard && isFemale

    // Null goal = row renders as a plain value with no bar, target or colouring.
    fun goal(key: String): Double? = if (showVTaperGoals) ideals[key] else null

    val lengthUnitString = if (unitSystem == UnitSystem.METRIC) "cm" else "in"
    val displayWrist = LengthConverter.displayLength(current?.wristSize ?: 17.5, unitSystem)

    val cardTitle = when {
        !isHard -> stringResource(R.string.measurements_title)
        isFemale -> stringResource(R.string.ideals_title_amazon)
        else -> stringResource(R.string.ideals_title_hero)
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .border(BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant), RoundedCornerShape(AppTheme.radiusL))
            .clip(RoundedCornerShape(AppTheme.radiusL))
            .padding(vertical = 8.dp),
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .padding(start = 20.dp, top = 12.dp, end = 20.dp, bottom = 12.dp),
        ) {
            Icon(Icons.Rounded.Straighten, contentDescription = null, tint = MaterialTheme.colorScheme.primary, modifier = Modifier.width(20.dp))
            Spacer(Modifier.width(8.dp))
            Text(cardTitle, fontWeight = FontWeight.Bold, fontSize = 16.sp)
            Spacer(Modifier.weight(1f))
            if (showVTaperGoals) {
                // The V-taper ideals are derived from the wrist anchor
                Text(
                    stringResource(R.string.anchor_wrist, displayWrist, lengthUnitString),
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
        HorizontalDivider()

        // --- All measurements, for every user ---
        IdealRow(label = stringResource(R.string.neck), currentRaw = current?.neck, idealRaw = goal("Neck"), unitSystem = unitSystem, isMaximum = false)
        IdealRow(label = stringResource(R.string.shoulders), currentRaw = current?.shoulders, idealRaw = goal("Shoulders"), unitSystem = unitSystem, isMaximum = false)
        IdealRow(label = stringResource(R.string.chest), currentRaw = current?.chest, idealRaw = goal("Chest"), unitSystem = unitSystem, isMaximum = false)
        IdealRow(label = stringResource(R.string.waist), currentRaw = current?.waist, idealRaw = goal("Waist"), unitSystem = unitSystem, isMaximum = true)
        IdealRow(label = stringResource(R.string.hips), currentRaw = current?.hips, idealRaw = goal("Hips"), unitSystem = unitSystem, isMaximum = true)
        IdealRow(label = stringResource(R.string.glutes), currentRaw = current?.glutes, idealRaw = null, unitSystem = unitSystem, isMaximum = false)

        // --- Hardcore female: the goal is the waist-to-hip ratio ---
        if (showWhrGoal) {
            val waistVal = current?.waist ?: 0.0
            val hipVal = current?.hips ?: 0.0
            if (waistVal > 0 && hipVal > 0) {
                WhrGoalRow(whr = waistVal / hipVal, target = ideals["WHR"] ?: DEFAULT_WHR_TARGET)
            }
        }

        HorizontalDivider(modifier = Modifier.padding(horizontal = 20.dp, vertical = 4.dp))

        // --- Balance (left/right). Goals only exist for hardcore male. ---
        SymmetryRow(stringResource(R.string.biceps), current?.leftBicep, current?.rightBicep, goal("Bicep"), unitSystem)
        SymmetryRow(stringResource(R.string.forearms), current?.leftForearm, current?.rightForearm, goal("Forearm"), unitSystem)
        SymmetryRow(stringResource(R.string.thighs), current?.leftThigh, current?.rightThigh, goal("Thigh"), unitSystem)
        SymmetryRow(stringResource(R.string.calves), current?.leftCalf, current?.rightCalf, goal("Calf"), unitSystem)

        if (!isHard || showWhrGoal) {
            Spacer(Modifier.height(8.dp))
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                shape = RoundedCornerShape(12.dp),
                color = MaterialTheme.colorScheme.surfaceContainer
            ) {
                Row(
                    modifier = Modifier.padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Rounded.Info,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.width(18.dp)
                    )
                    Spacer(Modifier.width(10.dp))
                    Text(
                        text = if (!isHard)
                            stringResource(R.string.focus_message_easy)
                        else
                            stringResource(R.string.focus_message_hard),
                        fontSize = 11.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        lineHeight = 15.sp
                    )
                }
            }
        }

        Spacer(Modifier.height(8.dp))
    }
}

@Composable
private fun WhrGoalRow(whr: Double, target: Double) {
    val diff = whr - target
    val onTarget = diff <= 0.0
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 10.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(stringResource(R.string.waist_to_hip_ratio), fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
            Row(verticalAlignment = Alignment.CenterVertically) {
                Surface(
                    shape = RoundedCornerShape(6.dp),
                    color = MaterialTheme.colorScheme.secondaryContainer
                ) {
                    Text(
                        text = "%.2f".format(whr),
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSecondaryContainer,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                    )
                }
                Text(
                    text = "  / %.2f".format(target),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
        Spacer(Modifier.height(6.dp))
        // Lower is better here, so the bar fills as the ratio comes down to the target.
        LinearProgressIndicator(
            progress = { (target / whr).toFloat().coerceIn(0f, 1f) },
            modifier = Modifier
                .fillMaxWidth()
                .height(6.dp)
                .clip(RoundedCornerShape(3.dp)),
            color = MaterialTheme.colorScheme.primary,
            trackColor = MaterialTheme.colorScheme.surfaceContainerHighest,
        )
        Spacer(Modifier.height(4.dp))
        Text(
            text = if (onTarget) stringResource(R.string.on_target) else stringResource(R.string.down_to_goal, diff),
            color = if (onTarget) Color(0xFF388E3C) else MaterialTheme.colorScheme.error,
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold,
        )
    }
}

@Composable
private fun IdealRow(
    label: String,
    currentRaw: Double?,
    idealRaw: Double?,
    unitSystem: UnitSystem,
    isMaximum: Boolean,
) {
    val current = LengthConverter.displayLength(currentRaw, unitSystem)
    val ideal = LengthConverter.displayLength(idealRaw, unitSystem)
    val lengthUnitString = if (unitSystem == UnitSystem.METRIC) "cm" else "in"

    val hasValue = current > 0
    val valueStr = if (hasValue) "%.1f".format(current) else "--"
    val idealStr = if (ideal > 0) "/ %.1f".format(ideal) else ""

    var isOverflow = false
    var diffAmount = 0.0
    if (hasValue && ideal > 0 && current > ideal) {
        isOverflow = true
        diffAmount = current - ideal
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 10.dp),
    ) {
        Text(
            label,
            fontWeight = FontWeight.SemiBold,
            fontSize = 13.sp,
            modifier = Modifier.weight(3f),
        )
        Column(modifier = Modifier.weight(4f)) {
            Row(verticalAlignment = Alignment.Bottom) {
                Text(
                    valueStr,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    color = if (isMaximum && isOverflow) MaterialTheme.colorScheme.error else Color.Unspecified,
                )
                if (ideal > 0) {
                    Text(
                        " $lengthUnitString $idealStr",
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
            Spacer(Modifier.height(6.dp))
            if (hasValue && ideal > 0) {
                if (isOverflow) {
                    Box {
                        Box(
                            modifier = Modifier
                                .height(6.dp)
                                .fillMaxWidth()
                                .background(
                                    color = if (isMaximum) MaterialTheme.colorScheme.error else Color(0xFF4CAF50),
                                    shape = RoundedCornerShape(3.dp),
                                ),
                        )
                        if (isMaximum) {
                            val fraction = (ideal / current).toFloat().coerceIn(0f, 1f)
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth(fraction)
                                    .height(6.dp)
                                    .background(MaterialTheme.colorScheme.primary, RoundedCornerShape(3.dp)),
                            )
                        }
                    }
                } else {
                    LinearProgressIndicator(
                        progress = { (current / ideal).toFloat().coerceIn(0f, 1f) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(6.dp)
                            .clip(RoundedCornerShape(3.dp)),
                        color = MaterialTheme.colorScheme.primary,
                        trackColor = MaterialTheme.colorScheme.surfaceContainerHighest,
                    )
                }
                if (isOverflow) {
                    Spacer(Modifier.height(4.dp))
                    Text(
                        text = if (isMaximum)
                            stringResource(R.string.lose_to_goal, diffAmount, lengthUnitString)
                        else
                            stringResource(R.string.over_ideal, diffAmount, lengthUnitString),
                        color = if (isMaximum) MaterialTheme.colorScheme.error else Color(0xFF388E3C),
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                    )
                }
            }
        }
    }
}

@Composable
private fun SymmetryRow(
    label: String,
    leftRaw: Double?,
    rightRaw: Double?,
    idealRaw: Double?,
    unitSystem: UnitSystem,
) {
    val left = LengthConverter.displayLength(leftRaw, unitSystem)
    val right = LengthConverter.displayLength(rightRaw, unitSystem)
    val ideal = LengthConverter.displayLength(idealRaw, unitSystem)
    val lengthUnitString = if (unitSystem == UnitSystem.METRIC) "cm" else "in"

    val hasBoth = left > 0 && right > 0
    val lStr = if (left > 0) "%.1f".format(left) else "--"
    val rStr = if (right > 0) "%.1f".format(right) else "--"
    val idealStr = if (ideal > 0) "%.1f".format(ideal) else "--"

    val maxVal = max(left, right)
    val diffPct = if (hasBoth && maxVal > 0) (abs(left - right) / maxVal) * 100.0 else 0.0

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 10.dp),
    ) {
        Text(label, fontWeight = FontWeight.SemiBold, fontSize = 13.sp, modifier = Modifier.weight(3f))
        Column(modifier = Modifier.weight(4f)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                SymBadge(stringResource(R.string.side_left_short, lStr))
                Spacer(Modifier.width(6.dp))
                SymBadge(stringResource(R.string.side_right_short, rStr))

                if (hasBoth) {
                    Spacer(Modifier.width(8.dp))
                    ImbalanceBadge(diffPct)
                }
            }
            if (ideal > 0) {
                Spacer(Modifier.height(6.dp))
                Text(
                    stringResource(R.string.goal_length, idealStr, lengthUnitString),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Composable
private fun SymBadge(text: String) {
    Box(
        modifier = Modifier
            .background(MaterialTheme.colorScheme.primaryContainer, RoundedCornerShape(4.dp))
            .padding(horizontal = 6.dp, vertical = 4.dp),
    ) {
        Text(
            text,
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onPrimaryContainer,
        )
    }
}

@Composable
private fun ImbalanceBadge(diffPct: Double) {
    val isBalanced = diffPct < 3.5
    val bgColor = if (isBalanced) Color(0xFFE8F5E9) else Color(0xFFFFF3E0)
    val textColor = if (isBalanced) Color(0xFF2E7D32) else Color(0xFFE65100)

    Box(
        modifier = Modifier
            .background(bgColor, RoundedCornerShape(4.dp))
            .padding(horizontal = 6.dp, vertical = 4.dp),
    ) {
        Text(
            text = if (isBalanced) stringResource(R.string.balanced) else stringResource(R.string.unbalanced, diffPct),
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold,
            color = textColor,
        )
    }
}