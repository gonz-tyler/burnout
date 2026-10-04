package com.burnout.app.ui.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.LocalFireDepartment
import androidx.compose.material.icons.rounded.MonitorWeight
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.burnout.app.R
import com.burnout.app.data.datastore.FeatureToggles
import com.burnout.app.data.pantheonGods
import com.burnout.app.data.local.entity.BodyMeasurement
import com.burnout.app.domain.model.Sex
import com.burnout.app.domain.model.Style
import com.burnout.app.domain.service.MuscleAnalysisService
import com.burnout.app.ui.dashboard.components.*
import com.burnout.app.ui.theme.AppTheme
import com.burnout.app.util.UnitSystem
import com.burnout.app.util.WeightConverter
import com.burnout.app.ui.viewmodel.WorkoutViewModel

/**
 * Port of dashboard_screen.dart. Composes the whole "Home" tab: the floating
 * bubble hero (streak / v-taper / tonnage), the muscle-focus diagram +
 * period selector + imbalance warnings, the horizontally-scrolling Pantheon,
 * and the physique tracker (body comp + Grecian ideals).
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    viewModel: WorkoutViewModel,
    features: FeatureToggles,
    sex: Sex,
    style: Style,
    unitSystem: UnitSystem,
    frontSvgRawResId: Int,
    backSvgRawResId: Int,
    onOpenStrengthLevel: (godName: String, exerciseName: String, variations: List<String>) -> Unit,
    bottomPadding: Dp = 0.dp,
) {
    var selectedPeriod by remember { mutableStateOf("WEEK") }
    var showMuscleInfo by remember { mutableStateOf(false) }
    var showMeasurementSheet by remember { mutableStateOf(false) }
    val uiState by viewModel.uiState.collectAsState()

    val weightUnitString = if (unitSystem == UnitSystem.METRIC) "kg" else "lbs"

    val allWorkouts = uiState.workoutSessions
    val allExercises = uiState.exercises

    // The ideals calculator still takes the old string; derive it from sex (single source of truth)
    val genderString = if (sex == Sex.FEMALE) "female" else "male"

    val muscleIntensity = when (selectedPeriod) {
        "WEEK" -> MuscleAnalysisService.getWeeklyMuscleIntensity(allWorkouts, allExercises)
        "MONTH" -> MuscleAnalysisService.getMonthlyMuscleIntensity(allWorkouts, allExercises)
        "ALL TIME" -> MuscleAnalysisService.getAllTimeMuscleIntensity(allWorkouts, allExercises)
        else -> emptyMap()
    }
    val warnings = MuscleAnalysisService.getMuscleImbalanceWarnings(muscleIntensity)

    val latest = uiState.latestMeasurement
    val wristSize = latest?.wristSize ?: 17.5
    val ideals = viewModel.getIdealProportions(wristSize, genderString)

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = 16.dp,
            end = 16.dp,
            top = 8.dp,
            bottom = 8.dp + bottomPadding
        ),
    ) {
        // --- SECTION 1: FLOATING BUBBLE OVERVIEW ---
        item {
            Box(modifier = Modifier.fillMaxWidth().height(560.dp)) {
                if (features.streak) {
                    Box(
                        modifier = Modifier
                            .align(Alignment.TopStart)
                            .padding(start = 12.dp, top = 60.dp)
                            .rotate(-3.15f), // -0.055 rad
                    ) {
                        StatBubble(
                            title = stringResource(R.string.streak).uppercase(),
                            value = "${uiState.currentStreak}",
                            unit = stringResource(R.string.days),
                            icon = Icons.Rounded.LocalFireDepartment,
                            bgColor = if (uiState.hasWorkedOutToday)
                                MaterialTheme.colorScheme.tertiaryContainer
                            else
                                MaterialTheme.colorScheme.surfaceContainerHighest,
                            fgColor = if (uiState.hasWorkedOutToday)
                                MaterialTheme.colorScheme.onTertiaryContainer
                            else
                                MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }

                Box(
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(end = 12.dp, top = 440.dp)
                        .rotate(3.72f), // 0.065 rad
                ) {
                    StatBubble(
                        title = stringResource(R.string.tonnage).uppercase(),
                        value = "%.1fk".format(WeightConverter.displayWeight(uiState.totalVolume, unitSystem) / 1000),
                        unit = weightUnitString,
                        icon = Icons.Rounded.MonitorWeight,
                        bgColor = MaterialTheme.colorScheme.primaryContainer,
                        fgColor = MaterialTheme.colorScheme.onPrimaryContainer,
                    )
                }

                Box(
                    modifier = Modifier
                        .align(Alignment.TopCenter) // Position Alignment (e.g., TopCenter, Center, etc.)
                        .padding(top = 160.dp)      // Vertical position inside hero container (increase/decrease to move up/down)
                ) {
                    VTaperBubble(
                        latest = latest,
                        // Optional explicit size modifier (e.g. modifier = Modifier.width(220.dp))
                        modifier = Modifier.width(220.dp).height(260.dp)
                    )
                }
            }
        }

        item { Spacer(Modifier.height(48.dp)) }

        // --- SECTION 2: MUSCLE FOCUS ---
        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(stringResource(R.string.muscle_focus), style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                IconButton(onClick = { showMuscleInfo = true }) {
                    Icon(Icons.Rounded.Info, contentDescription = stringResource(R.string.about_muscle_analysis))
                }
            }
        }
        item { Spacer(Modifier.height(12.dp)) }
        item {
            PeriodSelector(
                selectedPeriod = selectedPeriod,
                onPeriodSelected = { selectedPeriod = it },
            )
        }
        item { Spacer(Modifier.height(16.dp)) }
        item {
            Column {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(MaterialTheme.colorScheme.surfaceContainer, RoundedCornerShape(AppTheme.radiusL))
                        .padding(20.dp),
                ) {
                    MuscleDiagramWidget(
                        muscleIntensity = muscleIntensity,
                        frontSvgRawResId = frontSvgRawResId,
                        backSvgRawResId = backSvgRawResId,
                    )
                    Spacer(Modifier.height(24.dp))
                    IntensityLegend()
                }
                if (warnings.isNotEmpty()) {
                    Spacer(Modifier.height(16.dp))
                    warnings.forEach { WarningCard(warning = stringResource(it)) }
                }
            }
        }

        item { Spacer(Modifier.height(32.dp)) }

        // --- SECTION 3: THE PANTHEON ---
        if (features.godsEnabled) {
            item {
                Text(
                    stringResource(R.string.pantheon),
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold
                )
            }
            item { Spacer(Modifier.height(4.dp)) }
            item {
                Text(
                    stringResource(R.string.legendary_feats),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    fontSize = 13.sp,
                )
            }
            item { Spacer(Modifier.height(16.dp)) }
            item {
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    items(pantheonGods.size) { index ->
                        val god = pantheonGods[index]
                        val godName = when (features.gods) {
                            "gods" -> stringResource(god.godRes)
                            "goddesses" -> stringResource(god.goddessRes)
                            else -> stringResource(god.bothRes)
                        }


                        val prWeight = WeightConverter.displayWeight(
                            viewModel.getPersonalRecord(god.lift),
                            unitSystem,
                        )
                        GodCard(
                            godName = godName,
                            liftName = god.lift.uppercase(),
                            weight = prWeight,
                            unitString = weightUnitString,
                            color = god.color,
                            icon = god.icon,
                            index = index,
                            onTap = { onOpenStrengthLevel(godName, god.lift, god.variations) },
                        )
                    }
                }
            }
        }

        item { Spacer(Modifier.height(32.dp)) }

        // --- SECTION 4: PHYSIQUE TRACKER ---
        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(stringResource(R.string.physique_data), style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                FilledTonalButton(onClick = { showMeasurementSheet = true }) {
                    Icon(Icons.Rounded.Add, contentDescription = null, modifier = Modifier.width(18.dp))
                    Spacer(Modifier.width(4.dp))
                    Text(stringResource(R.string.log))
                }
            }
        }
        item { Spacer(Modifier.height(16.dp)) }
        if (uiState.measurements.isNotEmpty()) {
            item {
                Column {
                    BodyCompCard(measurements = uiState.measurements, unitSystem = unitSystem, goalsEnabled = features.goals)
                    if (features.ideals) {
                        Spacer(Modifier.height(12.dp))
                        IdealsCard(
                            current = latest,
                            ideals = ideals,
                            unitSystem = unitSystem,
                            sex = sex,
                            style = style
                        )
                    }
                }
            }
        }

        item { Spacer(Modifier.height(AppTheme.bottomNavClearance)) }
    }

    if (showMuscleInfo) {
        MuscleInfoDialog(onDismiss = { showMuscleInfo = false })
    }

    if (showMeasurementSheet) {
        MeasurementSheet(
            latest = latest,
            unitSystem = unitSystem,
            goalsEnabled = features.goals,
            onDismiss = { showMeasurementSheet = false },
            onSave = {
                viewModel.addMeasurement(it)
                showMeasurementSheet = false
            },

        )
    }
}