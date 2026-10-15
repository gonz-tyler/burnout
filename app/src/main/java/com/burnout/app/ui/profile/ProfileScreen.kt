package com.burnout.app.ui.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ListAlt
import androidx.compose.material.icons.automirrored.rounded.TrendingUp
import androidx.compose.material.icons.rounded.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.burnout.app.R
import com.burnout.app.data.datastore.FeatureToggles
import com.burnout.app.data.pantheonGods
import com.burnout.app.domain.service.LaborsService
import com.burnout.app.ui.profile.components.GodCard
import com.burnout.app.ui.viewmodel.WorkoutViewModel
import com.burnout.app.util.UnitSystem
import com.burnout.app.util.WeightConverter

/**
 * Profile tab. Shared "suite skeleton":
 *   1. Stat card            (same in every app)
 *   2. Achievements slot    (workout app: Pantheon, habit app: milestones)
 *   3. Quick actions        (same pattern in every app)
 * followed by the support / app-info footer.
 */
@Composable
fun ProfileScreen(
    workoutViewModel: com.burnout.app.ui.viewmodel.WorkoutViewModel,
    onNavigateToHistory: () -> kotlin.Unit,
    onNavigateToStrengthProgress: () -> kotlin.Unit,
    onNavigateToSettings: () -> kotlin.Unit,
    onOpenStrengthLevel: () -> Unit,
    features: com.burnout.app.data.datastore.FeatureToggles,
    unitSystem: kotlin.String,
    bottomPadding: androidx.compose.ui.unit.Dp = 0.dp,
) {
    val uiState by workoutViewModel.uiState.collectAsState()

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = 16.dp,
            end = 16.dp,
            top = 16.dp,
            bottom = 16.dp + bottomPadding
        ),
        verticalArrangement = Arrangement.spacedBy(24.dp)
    ) {
        // --- 1. STAT CARD ---
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(28.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            ) {
                Column(modifier = Modifier.padding(20.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(56.dp)
                                .background(MaterialTheme.colorScheme.primary, CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = Icons.Rounded.Person,
                                contentDescription = null,
                                tint = MaterialTheme.colorScheme.onPrimary,
                                modifier = Modifier.size(28.dp)
                            )
                        }
                        Spacer(Modifier.width(16.dp))
                        Column {
                            Text(
                                text = stringResource(R.string.your_progress),
                                style = MaterialTheme.typography.headlineSmall,
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                text = stringResource(R.string.keep_progressing),
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                    Spacer(Modifier.height(20.dp))
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        StatItem(
                            modifier = Modifier.weight(1f),
                            label = stringResource(R.string.total_workouts),
                            value = uiState.routines.size.toString(),
                            icon = Icons.AutoMirrored.Rounded.ListAlt
                        )
                        if (features.labors) {
                            StatItem(
                                modifier = Modifier.weight(1f),
                                label = stringResource(R.string.labors_label),
                                value = "${uiState.completedLaborCount}/${LaborsService.TOTAL_LABOR_COUNT}",
                                icon = Icons.Rounded.Shield
                            )
                        }
                        StatItem(
                            modifier = Modifier.weight(1f),
                            label = stringResource(R.string.total_completions),
                            value = uiState.workoutSessions.size.toString(),
                            icon = Icons.Rounded.CheckCircle
                        )
                    }
                }
            }
        }

        // --- 2. ACHIEVEMENTS SLOT: THE PANTHEON ---
        if (features.godsEnabled) {
            item {
                PantheonSection(
                    gods = features.gods,
                    unitSystem = if (unitSystem == "imperial") UnitSystem.IMPERIAL else UnitSystem.METRIC,
                    personalRecord = { lift -> workoutViewModel.getPersonalRecord(lift) },
                    onOpenStrengthLevel = onOpenStrengthLevel,
                )
            }
        }

        // --- 3. QUICK ACTIONS ---
        item {
            Text(
                text = stringResource(R.string.quick_actions),
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.height(12.dp))
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                ActionCard(
                    title = stringResource(R.string.workout_history),
                    subtitle = stringResource(R.string.view_completed_sessions),
                    icon = Icons.Rounded.History,
                    iconColor = MaterialTheme.colorScheme.tertiary,
                    onClick = onNavigateToHistory
                )
                // New strings: strength_progress, strength_progress_subtitle
                ActionCard(
                    title = stringResource(R.string.strength_progress),
                    subtitle = stringResource(R.string.strength_progress_subtitle),
                    icon = Icons.AutoMirrored.Rounded.TrendingUp,
                    iconColor = MaterialTheme.colorScheme.primary,
                    onClick = onNavigateToStrengthProgress
                )
                ActionCard(
                    title = stringResource(R.string.settings),
                    subtitle = stringResource(R.string.customize_preferences),
                    icon = Icons.Rounded.Settings,
                    iconColor = MaterialTheme.colorScheme.secondary,
                    onClick = onNavigateToSettings
                )
            }
        }
    }
}

/** Horizontally-scrolling PR cards, moved over from the dashboard unchanged. */
@Composable
private fun PantheonSection(
    gods: String,
    unitSystem: UnitSystem,
    personalRecord: (String) -> Double,
    onOpenStrengthLevel: () -> Unit,
) {
    val weightUnitString = if (unitSystem == UnitSystem.METRIC) "kg" else "lbs"

    Column {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    stringResource(R.string.pantheon),
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold
                )
                Spacer(Modifier.height(2.dp))
                Text(
                    stringResource(R.string.legendary_feats),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    fontSize = 13.sp,
                )
            }
            IconButton(onClick = onOpenStrengthLevel) {
                Icon(
                    imageVector = Icons.Rounded.ChevronRight,
                    contentDescription = stringResource(R.string.legendary_feats_title),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
        Spacer(Modifier.height(12.dp))
        LazyRow(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            items(pantheonGods.size) { index ->
                val god = pantheonGods[index]
                val godName = when (gods) {
                    "gods" -> stringResource(god.godRes)
                    "goddesses" -> stringResource(god.goddessRes)
                    else -> stringResource(god.bothRes)
                }
                GodCard(
                    godName = godName,
                    liftName = god.lift.uppercase(),
                    weight = WeightConverter.displayWeight(personalRecord(god.lift), unitSystem),
                    unitString = weightUnitString,
                    color = god.color,
                    icon = god.icon,
                    index = index,
                    onTap = onOpenStrengthLevel,
                )
            }
        }
    }
}

@Composable
private fun StatItem(
    modifier: Modifier = Modifier,
    label: String,
    value: String,
    icon: ImageVector
) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(imageVector = icon, contentDescription = null, modifier = Modifier.size(24.dp))
        Spacer(Modifier.height(8.dp))
        Text(
            text = value,
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold
        )
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
private fun ActionCard(
    title: String,
    subtitle: String,
    icon: ImageVector,
    iconColor: Color,
    onClick: () -> Unit
) {
    Surface(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(28.dp),
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .background(iconColor.copy(alpha = 0.15f), RoundedCornerShape(16.dp)),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = icon, contentDescription = null, tint = iconColor, modifier = Modifier.size(22.dp))
            }
            Spacer(Modifier.width(16.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Icon(
                imageVector = Icons.Rounded.ChevronRight,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}