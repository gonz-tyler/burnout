package com.burnout.app.ui.workout

import android.text.format.DateFormat
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.burnout.app.R
import com.burnout.app.data.local.entity.PerformedExercise
import com.burnout.app.data.local.entity.PerformedSet
import com.burnout.app.data.local.entity.SetType
import com.burnout.app.ui.viewmodel.WorkoutViewModel
import com.burnout.app.util.UnitSystem
import com.burnout.app.util.WeightConverter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WorkoutDetailsScreen(
    sessionId: String,
    workoutViewModel: WorkoutViewModel,
    onNavigateBack: () -> Unit
) {
    val uiState by workoutViewModel.uiState.collectAsState()
    val session = uiState.workoutSessions.find { it.id == sessionId } ?: return
    val unitSystem = if (uiState.unitSystem == "imperial") UnitSystem.IMPERIAL else UnitSystem.METRIC

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(DateFormat.format("MMM d, yyyy", session.dateCompleted).toString()) },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = stringResource(R.string.back_description))
                    }
                }
            )
        }
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            items(session.performedExercises) { performedExercise ->
                val exerciseName = uiState.exercises.find { it.id == performedExercise.exerciseId }?.name
                    ?: stringResource(R.string.unknown_exercise)
                
                PerformedExerciseCard(
                    exerciseName = exerciseName,
                    performedExercise = performedExercise,
                    unitSystem = unitSystem
                )
            }
        }
    }
}

@Composable
private fun PerformedExerciseCard(
    exerciseName: String,
    performedExercise: PerformedExercise,
    unitSystem: UnitSystem
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainer)
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Text(
                text = exerciseName,
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface
            )
            Spacer(Modifier.height(16.dp))
            
            // Header Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = stringResource(R.string.sets_label_history),
                    modifier = Modifier.width(48.dp),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    style = MaterialTheme.typography.labelSmall,
                    fontWeight = FontWeight.Bold
                )
                val unitLabel = if (unitSystem == UnitSystem.METRIC) stringResource(R.string.weight_kg) else stringResource(R.string.weight_lbs)
                Text(
                    text = unitLabel,
                    modifier = Modifier.weight(1f),
                    textAlign = androidx.compose.ui.text.style.TextAlign.Center,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    style = MaterialTheme.typography.labelSmall,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = stringResource(R.string.reps_label_short),
                    modifier = Modifier.weight(1f),
                    textAlign = androidx.compose.ui.text.style.TextAlign.Center,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    style = MaterialTheme.typography.labelSmall,
                    fontWeight = FontWeight.Bold
                )
            }
            
            Spacer(Modifier.height(8.dp))
            HorizontalDivider(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.1f))
            Spacer(Modifier.height(8.dp))

            performedExercise.sets.forEachIndexed { index, set ->
                PerformedSetRow(index + 1, set, unitSystem)
            }
        }
    }
}

@Composable
private fun PerformedSetRow(
    displayIndex: Int,
    set: PerformedSet,
    unitSystem: UnitSystem
) {
    val rowColor = when (set.setType) {
        SetType.WARMUP -> Color(0xFFFFA500).copy(alpha = 0.1f)
        SetType.FAILURE -> Color.Red.copy(alpha = 0.1f)
        SetType.DROPSET -> Color(0xFFA020F0).copy(alpha= 0.1f)
        else -> Color.Transparent
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(rowColor, RoundedCornerShape(8.dp))
            .padding(vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = displayIndex.toString(),
            modifier = Modifier.width(48.dp),
            textAlign = androidx.compose.ui.text.style.TextAlign.Center,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface
        )
        
        val displayWeight = WeightConverter.displayWeight(set.weight, unitSystem).toString().removeSuffix(".0")
        Text(
            text = displayWeight,
            modifier = Modifier.weight(1f),
            textAlign = androidx.compose.ui.text.style.TextAlign.Center,
            color = MaterialTheme.colorScheme.onSurface
        )
        
        Text(
            text = set.reps?.toString() ?: "--",
            modifier = Modifier.weight(1f),
            textAlign = androidx.compose.ui.text.style.TextAlign.Center,
            color = MaterialTheme.colorScheme.onSurface
        )
    }
}
