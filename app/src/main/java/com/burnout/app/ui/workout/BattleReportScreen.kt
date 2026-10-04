package com.burnout.app.ui.workout

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.ArrowDownward
import androidx.compose.material.icons.rounded.ArrowUpward
import androidx.compose.material.icons.rounded.EmojiEvents
import androidx.compose.material.icons.rounded.HorizontalRule
import androidx.compose.material.icons.rounded.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.burnout.app.R
import com.burnout.app.data.local.entity.Exercise
import com.burnout.app.data.local.entity.ProgressionProfile
import com.burnout.app.domain.model.ExerciseResult
import com.burnout.app.domain.model.WeightMode
import com.burnout.app.ui.viewmodel.ActiveWorkoutViewModel
import com.burnout.app.ui.viewmodel.WorkoutViewModel
import com.burnout.app.util.UnitSystem
import com.burnout.app.util.WeightConverter
import kotlin.math.roundToInt

private const val DEFAULT_LOW_REP_THRESHOLD = 5

@Composable
fun BattleReportScreen(
    onSaveComplete: () -> Unit,
    activeWorkoutViewModel: ActiveWorkoutViewModel = hiltViewModel(),
    workoutViewModel: WorkoutViewModel = hiltViewModel()
) {
    val activeState by activeWorkoutViewModel.uiState.collectAsState()
    val workoutState by workoutViewModel.uiState.collectAsState()

    val results = activeState.battleResults
    val routineId = activeState.routine?.id
    val durationMinutes = activeState.battleDurationMinutes

    val unitSystem = if (workoutState.unitSystem.equals("imperial", ignoreCase = true)) {
        UnitSystem.IMPERIAL
    } else {
        UnitSystem.METRIC
    }

    val profile = ProgressionProfile.STANDARD

    var resultsVersion by remember { mutableIntStateOf(0) }
    val prCount = results.count { it.isPr }

    Scaffold(
        containerColor = Color.Black,
        bottomBar = {
            Surface(color = Color.Black, tonalElevation = 8.dp) {
                Button(
                    onClick = {
                        if (routineId != null) {
                            workoutViewModel.updateRoutineWeights(routineId, results)
                        }
                        onSaveComplete()
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(24.dp)
                        .height(64.dp),
                    shape = RoundedCornerShape(AppRadius.L),
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
                ) {
                    Text("ETCH IN STONE", fontWeight = FontWeight.Black, fontSize = 16.sp, letterSpacing = 2.sp)
                }
            }
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            contentPadding = PaddingValues(16.dp)
        ) {
            item {
                VictoryHeader(durationMinutes = durationMinutes, prCount = prCount)
                Spacer(Modifier.height(16.dp))
            }
            items(results, key = { it.exerciseId }) { result ->
                key(resultsVersion) {
                    val exercise = workoutState.exercises.find { it.id == result.exerciseId }

                    if (exercise == null) {
                        MissingExerciseCard(result)
                    } else if (!exercise.hasWeightProgression) {
                        CardioSummaryCard(result)
                    } else {
                        AdjustmentCard(
                            result = result,
                            exercise = exercise,
                            unitSystem = unitSystem,
                            profile = profile,
                            onRate = { rating ->
                                adjustWeight(result, rating, exercise, profile)
                                resultsVersion++
                            }
                        )
                    }
                    Spacer(Modifier.height(16.dp))
                }
            }
        }
    }
}

object AppRadius {
    val L = 28.dp
}

@Composable
private fun VictoryHeader(durationMinutes: Int, prCount: Int) {
    val theme = MaterialTheme.colorScheme
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 24.dp, bottom = 40.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .size(100.dp)
                .background(Color(0xFFFFC107).copy(alpha = 0.1f), CircleShape)
                .border(2.dp, Color(0xFFFFC107).copy(alpha = 0.2f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                Icons.Rounded.EmojiEvents,
                contentDescription = null,
                tint = Color(0xFFFFC107),
                modifier = Modifier.size(56.dp)
            )
        }
        Spacer(Modifier.height(24.dp))
        Text(
            "VICTORY",
            style = MaterialTheme.typography.displaySmall.copy(
                fontWeight = FontWeight.Black,
                letterSpacing = 12.sp,
                color = Color.White
            )
        )
        Spacer(Modifier.height(12.dp))
        Surface(
            color = theme.primary.copy(alpha = 0.1f),
            shape = RoundedCornerShape(16.dp)
        ) {
            Text(
                "$durationMinutes MIN · $prCount PR${if (prCount == 1) "" else "S"}",
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp),
                color = theme.primary,
                style = MaterialTheme.typography.labelLarge.copy(
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                )
            )
        }
    }
}

@Composable
private fun AdjustmentCard(
    result: ExerciseResult,
    exercise: Exercise,
    unitSystem: UnitSystem,
    profile: ProgressionProfile,
    onRate: (Int) -> Unit
) {
    val theme = MaterialTheme.colorScheme
    val unitString = if (unitSystem == UnitSystem.METRIC) "kg" else "lbs"
    val isPr = result.isPr
    val borderColor = if (isPr) Color(0xFFFFC107).copy(alpha = 0.4f) else theme.outlineVariant.copy(alpha = 0.2f)
    
    val displayWeightUsed = WeightConverter.displayWeight(result.weightUsed, unitSystem)
    val displayNextWeight = WeightConverter.displayWeight(result.nextWeight, unitSystem)

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .border(if (isPr) 2.dp else 1.dp, borderColor, RoundedCornerShape(24.dp)),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1C222B))
    ) {
        Column(modifier = Modifier.padding(24.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (isPr) {
                    Icon(Icons.Rounded.Star, contentDescription = "Personal record", tint = Color(0xFFFFC107), modifier = Modifier.size(22.dp))
                    Spacer(Modifier.width(8.dp))
                }
                Text(
                    result.exerciseName.uppercase(),
                    modifier = Modifier.weight(1f),
                    color = Color.White,
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontWeight = FontWeight.Black,
                        letterSpacing = 1.5.sp
                    )
                )
                Text(
                    "${"%.1f".format(displayWeightUsed).trimEnd('0').trimEnd('.')} $unitString",
                    color = Color.Gray,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp
                )
            }

            Spacer(Modifier.height(24.dp))
            Text(
                "BATTLE RATING",
                color = Color.Gray,
                style = MaterialTheme.typography.labelSmall.copy(
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 2.sp
                )
            )
            Spacer(Modifier.height(16.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                RatingButton(modifier = Modifier.weight(1f), result, 1, "EASY", Color(0xFF4CAF50), onRate)
                RatingButton(modifier = Modifier.weight(1f), result, 3, "GOOD", theme.primary, onRate)
                RatingButton(modifier = Modifier.weight(1f), result, 4, "HARD", Color(0xFFFF9800), onRate)
                RatingButton(modifier = Modifier.weight(1f), result, 5, "FAIL", Color(0xFFF44336), onRate)
            }

            Spacer(Modifier.height(24.dp))
            HorizontalDivider(color = Color.White.copy(alpha = 0.1f))
            Spacer(Modifier.height(20.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    if (result.nextTargetReps != null) "NEXT TARGET REPS" else "NEXT TARGET WEIGHT",
                    color = Color.Gray,
                    style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
                )
                
                Row(verticalAlignment = Alignment.CenterVertically) {
                    if (result.nextTargetReps != null) {
                        val diff = result.nextTargetReps!! - result.repsAchieved
                        DirectionIndicator(diff.toDouble())
                        Spacer(Modifier.width(6.dp))
                        Text(
                            "${result.nextTargetReps} REPS",
                            color = if (diff > 0) Color(0xFF4CAF50) else if (diff < 0) Color(0xFFF44336) else Color.White,
                            style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Black)
                        )
                    } else {
                        val diff = result.nextWeight - result.weightUsed
                        DirectionIndicator(diff)
                        Spacer(Modifier.width(6.dp))
                        Text(
                            "${"%.1f".format(displayNextWeight).trimEnd('0').trimEnd('.')} $unitString",
                            color = if (diff > 0) Color(0xFF4CAF50) else if (diff < 0) Color(0xFFF44336) else Color.White,
                            style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Black)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun DirectionIndicator(diff: Double) {
    val icon = when {
        diff > 0 -> Icons.Rounded.ArrowUpward
        diff < 0 -> Icons.Rounded.ArrowDownward
        else -> Icons.Rounded.HorizontalRule
    }
    val color = when {
        diff > 0 -> Color(0xFF4CAF50)
        diff < 0 -> Color(0xFFF44336)
        else -> Color.Gray
    }
    Icon(icon, contentDescription = null, tint = color, modifier = Modifier.size(20.dp))
}

@Composable
private fun RatingButton(
    modifier: Modifier = Modifier,
    result: ExerciseResult,
    rating: Int,
    label: String,
    color: Color,
    onRate: (Int) -> Unit
) {
    val isSelected = result.difficultyRating == rating
    Box(
        modifier = modifier
            .padding(horizontal = 4.dp)
            .clip(RoundedCornerShape(12.dp))
            .background(if (isSelected) color.copy(alpha = 0.15f) else Color(0xFF2C343E))
            .border(2.dp, if (isSelected) color else Color.Transparent, RoundedCornerShape(12.dp))
            .clickable { onRate(rating) }
            .padding(vertical = 12.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(label, color = if (isSelected) color else Color.Gray, fontSize = 11.sp, fontWeight = FontWeight.Black, letterSpacing = 1.sp)
    }
}

@Composable
private fun CardioSummaryCard(result: ExerciseResult) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1C222B))
    ) {
        Column(modifier = Modifier.padding(24.dp)) {
            Text(result.exerciseName.uppercase(), color = Color.White, style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Black, letterSpacing = 1.5.sp))
            Spacer(Modifier.height(4.dp))
            Text("Logged — no weight target to adjust.", color = Color.Gray, fontSize = 13.sp)
        }
    }
}

@Composable
private fun MissingExerciseCard(result: ExerciseResult) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1C222B))
    ) {
        Column(modifier = Modifier.padding(24.dp)) {
            Text(result.exerciseName.uppercase(), color = Color.White, style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Black, letterSpacing = 1.5.sp))
            Spacer(Modifier.height(4.dp))
            Text("This exercise was removed from your library.", color = Color.Gray, fontSize = 13.sp)
        }
    }
}

private fun adjustWeight(result: ExerciseResult, rating: Int, exercise: Exercise, profile: ProgressionProfile) {
    result.difficultyRating = rating

    if (!exercise.hasWeightProgression) return

    val isBodyweightMode = exercise.supportsBodyweight && result.weightMode == WeightMode.BODYWEIGHT
    val threshold = exercise.lowRepThreshold ?: DEFAULT_LOW_REP_THRESHOLD

    if (isBodyweightMode && result.repsAchieved < threshold) {
        applyRepProgression(result, rating)
        return
    }

    applyWeightProgression(result, rating, exercise, profile)
}

private fun applyRepProgression(result: ExerciseResult, rating: Int) {
    result.nextTargetReps = when (rating) {
        1 -> result.repsAchieved + 3
        2 -> result.repsAchieved + 2
        3 -> result.repsAchieved + 1
        4 -> result.repsAchieved
        5 -> (result.repsAchieved - 1).coerceAtLeast(1)
        else -> result.repsAchieved
    }
    result.nextWeight = result.weightUsed
}

private fun applyWeightProgression(result: ExerciseResult, rating: Int, exercise: Exercise, profile: ProgressionProfile) {
    val baseKg = exercise.incrementFor(profile)

    val jumpSmall = baseKg
    val jumpMedium = baseKg * 2
    val jumpLarge = baseKg * 4

    result.nextWeight = when (rating) {
        1 -> result.weightUsed + jumpLarge
        2 -> result.weightUsed + jumpMedium
        3 -> result.weightUsed + jumpSmall
        4 -> result.weightUsed
        5 -> (result.weightUsed * (if (result.weightUsed < 0) 1.1 else 0.9))
        else -> result.weightUsed
    }
    result.nextTargetReps = null
}
