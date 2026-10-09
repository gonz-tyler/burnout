package com.burnout.app.ui.workout

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowBack
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import com.burnout.app.data.local.entity.*
import com.burnout.app.domain.model.ExerciseResult
import com.burnout.app.domain.model.WeightMode
import com.core.designsystem.components.AnimatedLinearProgressIndicator
import com.burnout.app.ui.routine.ExercisePickerDialog
import com.burnout.app.ui.routine.components.SetTypeSelectionContent
import com.burnout.app.ui.viewmodel.ActiveWorkoutViewModel
import com.burnout.app.ui.viewmodel.RestTimerViewModel
import com.burnout.app.ui.viewmodel.WorkoutViewModel
import com.burnout.app.ui.workout.components.RestTimerBar
import com.burnout.app.R
import kotlinx.coroutines.launch
import java.util.UUID

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ActiveWorkoutScreen(
    routine: Routine?, // null = blank/ad-hoc workout
    onFinished: (results: List<ExerciseResult>, routineId: String?, durationMinutes: Int) -> Unit,
    onNavigateBack: () -> Unit,
    workoutViewModel: WorkoutViewModel = hiltViewModel(),
    activeViewModel: ActiveWorkoutViewModel = hiltViewModel(),
    restTimerViewModel: RestTimerViewModel = viewModel()
) {
    val activeState by activeViewModel.uiState.collectAsState()
    val workoutState by workoutViewModel.uiState.collectAsState()

    val isMetric = workoutState.unitSystem.lowercase() == "metric"
    val startTimeMillis = remember { System.currentTimeMillis() }
    val isBlankWorkout = routine == null

    val sheetState = rememberModalBottomSheetState()
    val scope = rememberCoroutineScope()
    var showTypeSheetFor by remember { mutableStateOf<Pair<Int, Int>?>(null) } // exerciseIndex, setIndex

    LaunchedEffect(routine?.id) {
        activeViewModel.startWorkout(routine)
    }

    if (!activeState.isWorkoutStarted) {
        Scaffold(modifier = Modifier.fillMaxSize()) { padding ->
            Box(Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) {
                CircularProgressIndicator()
            }
        }
        return
    }

    var showCancelDialog by remember { mutableStateOf(false) }
    var showExercisePicker by remember { mutableStateOf(false) }
    var showIncompleteDialog by remember { mutableStateOf(false) }
    var showTacticalDialog by remember { mutableStateOf(false) }
    val snackbarHostState = remember { SnackbarHostState() }

    fun buildBattleResults(): List<ExerciseResult> {
        val results = mutableListOf<ExerciseResult>()
        activeState.liveExercises.forEachIndexed { i, routineExercise ->
            var workingWeight: Double? = null
            var hasCompletedSet = false
            var repsAchieved = 0

            routineExercise.plannedSets.forEachIndexed { setIndex, set ->
                if (activeViewModel.isSetCompleted(i, setIndex)) {
                    hasCompletedSet = true
                    val setWeight = set.targetWeight ?: 0.0
                    if (workingWeight == null || setWeight > workingWeight!!) {
                        workingWeight = setWeight
                        repsAchieved = set.targetReps?.toIntOrNull() ?: 0
                    }
                }
            }

            if (hasCompletedSet) {
                val maxWeight = workingWeight ?: 0.0
                val previousRecord = workoutViewModel.getPersonalRecord(routineExercise.exerciseName)
                val isPr = maxWeight > previousRecord
                val exerciseDetails = workoutState.exercises.find { it.id == routineExercise.exerciseId }
                val weightMode = exerciseDetails?.let { activeViewModel.getWeightModeForExercise(it) } ?: WeightMode.WEIGHTED

                results.add(
                    ExerciseResult(
                        exerciseId = routineExercise.exerciseId,
                        exerciseName = routineExercise.exerciseName,
                        weightUsed = maxWeight,
                        isPr = isPr,
                        nextWeight = maxWeight,
                        weightMode = weightMode,
                        repsAchieved = repsAchieved
                    )
                )
            }
        }
        return results
    }

    fun proceedToFinish(updateRoutine: Boolean) {
        if (updateRoutine && !isBlankWorkout) {
            activeState.routine?.let { original ->
                workoutViewModel.addRoutine(original.copy(exercises = activeState.liveExercises))
            }
        }

        val battleResults = buildBattleResults()
        val durationMinutes = ((System.currentTimeMillis() - startTimeMillis) / 60000).toInt().coerceAtLeast(1)
        val performedData = activeViewModel.getPerformedExercises()

        val session = WorkoutSession(
            id = UUID.randomUUID().toString(),
            routineId = routine?.id,
            dateCompleted = System.currentTimeMillis(),
            durationInMinutes = durationMinutes,
            performedExercises = performedData
        )
        workoutViewModel.addWorkoutSession(session)
        activeViewModel.finishWorkout(battleResults, durationMinutes)

        onFinished(battleResults, routine?.id, durationMinutes)
    }

    fun handleTacticalChangesAndFinish() {
        val performed = activeViewModel.getPerformedExercises()
        if (performed.isEmpty()) {
            onNavigateBack()
            return
        }
        if (!isBlankWorkout && activeViewModel.hasRoutineChanged()) {
            showTacticalDialog = true
        } else {
            proceedToFinish(updateRoutine = false)
        }
    }

    fun attemptFinish() {
        val hasIncomplete = activeState.liveExercises.any { ex ->
            ex.plannedSets.indices.any { setIdx ->
                !activeViewModel.isSetCompleted(activeState.liveExercises.indexOf(ex), setIdx)
            }
        }
        if (hasIncomplete) {
            showIncompleteDialog = true
        } else {
            handleTacticalChangesAndFinish()
        }
    }

    val timerState by restTimerViewModel.uiState.collectAsState()

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        snackbarHost = { SnackbarHost(snackbarHostState) },
        topBar = {
            Column {
                TopAppBar(
                    title = {
                        Text(
                            (activeState.routine?.name ?: stringResource(R.string.workout_name)).uppercase(),
                            fontWeight = FontWeight.Black,
                            letterSpacing = 1.sp
                        )
                    },
                    navigationIcon = {
                        IconButton(onClick = { showCancelDialog = true }) {
                            Icon(Icons.AutoMirrored.Rounded.ArrowBack, contentDescription = stringResource(R.string.cancel_workout))
                        }
                    },
                    actions = {
                        IconButton(onClick = { showExercisePicker = true }) {
                            Icon(Icons.Rounded.Add, contentDescription = stringResource(R.string.add_exercise))
                        }
                        Spacer(Modifier.width(8.dp))
                        FilledTonalButton(onClick = { attemptFinish() }) {
                            Text(stringResource(R.string.finish).uppercase(), fontWeight = FontWeight.Black, letterSpacing = 1.sp)
                        }
                        Spacer(Modifier.width(8.dp))
                    }
                )
                AnimatedLinearProgressIndicator(
                    progress = { activeState.progress },
                    modifier = Modifier.fillMaxWidth().height(6.dp),
                    color = MaterialTheme.colorScheme.primary,
                    trackColor = MaterialTheme.colorScheme.surfaceContainerHighest,
                )
            }
        },
        bottomBar = {
            AnimatedVisibility(
                visible = timerState.isRunning,
                enter = slideInVertically(initialOffsetY = { it }),
                exit = slideOutVertically(targetOffsetY = { it }),
                modifier = Modifier.navigationBarsPadding() // Adds inset padding above system gesture/nav bars
            ) {
                RestTimerBar(
                    timerState = timerState,
                    onAddSeconds = { restTimerViewModel.addSeconds(it) },
                    onSkip = { restTimerViewModel.skip() }
                )
            }
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(top = 16.dp, bottom = 100.dp) // Added bottom padding to clear timer
        ) {
            itemsIndexed(activeState.liveExercises, key = { _, ex -> ex.exerciseId }) { index, routineExercise ->
                val exerciseDetails = workoutState.exercises.find { it.id == routineExercise.exerciseId }
                if (exerciseDetails != null) {
                    ExerciseCard(
                        modifier = Modifier.animateItem().padding(bottom = 24.dp),
                        routineExercise = routineExercise,
                        exerciseDetails = exerciseDetails,
                        exerciseIndex = index,
                        isMetric = isMetric,
                        activeViewModel = activeViewModel,
                        workoutViewModel = workoutViewModel,
                        restTimerViewModel = restTimerViewModel,
                        setCompletionStatus = activeState.setCompletionStatus,
                        onShowTypePicker = { setIdx ->
                            showTypeSheetFor = index to setIdx
                        }
                    )
                }
            }
        }
    }

    if (showTypeSheetFor != null) {
        ModalBottomSheet(
            onDismissRequest = { showTypeSheetFor = null },
            sheetState = sheetState,
            containerColor = MaterialTheme.colorScheme.surfaceContainer
        ) {
            val (exIdx, setIdx) = showTypeSheetFor!!
            val currentSet = activeState.liveExercises[exIdx].plannedSets[setIdx]
            SetTypeSelectionContent(
                selectedType = currentSet.setType,
                onTypeSelected = { newType ->
                    activeViewModel.updateSetData(exIdx, setIdx, currentSet.copy(setType = newType))
                    scope.launch { sheetState.hide() }.invokeOnCompletion {
                        showTypeSheetFor = null
                    }
                }
            )
        }
    }

    if (showCancelDialog) {
        AlertDialog(
            onDismissRequest = { showCancelDialog = false },
            title = { Text(stringResource(R.string.cancel_workout), fontWeight = FontWeight.Bold) },
            text = { Text(stringResource(R.string.cancel_workout_confirmation)) },
            confirmButton = {
                TextButton(onClick = {
                    showCancelDialog = false
                    onNavigateBack()
                }) { Text(stringResource(R.string.end_workout), color = MaterialTheme.colorScheme.error, fontWeight = FontWeight.Bold) }
            },
            dismissButton = {
                TextButton(onClick = { showCancelDialog = false }) { Text(stringResource(R.string.resume)) }
            }
        )
    }

    if (showExercisePicker) {
        val currentIds = activeState.liveExercises.map { it.exerciseId }.toSet()
        ExercisePickerDialog(
            availableExercises = workoutState.exercises,
            initialSelectedIds = currentIds.toList(),
            onDismissRequest = { showExercisePicker = false },
            onExercisesSelected = { selected ->
                val selectedIds = selected.map { it.id }.toSet()
                activeState.liveExercises.indices.reversed().forEach { i ->
                    if (activeState.liveExercises[i].exerciseId !in selectedIds) {
                        activeViewModel.deleteExercise(i)
                    }
                }
                selected.forEach { ex ->
                    if (ex.id !in currentIds) {
                        activeViewModel.addExercise(
                            RoutineExercise(
                                exerciseId = ex.id,
                                exerciseName = ex.name,
                                plannedSets = listOf(PlannedSet(setType = SetType.NORMAL, targetReps = "", targetWeight = null)),
                                restTimeInSeconds = 90
                            )
                        )
                    }
                }
                showExercisePicker = false
            }
        )
    }

    if (showIncompleteDialog) {
        AlertDialog(
            onDismissRequest = { showIncompleteDialog = false },
            title = { Text(stringResource(R.string.unfinished_business), fontWeight = FontWeight.Black, letterSpacing = 1.sp) },
            text = { Text(stringResource(R.string.uncompleted_sets_warning)) },
            confirmButton = {
                TextButton(onClick = {
                    activeState.liveExercises.forEachIndexed { i, ex ->
                        ex.plannedSets.indices.forEach { j ->
                            if (!activeViewModel.isSetCompleted(i, j)) activeViewModel.toggleSetCompletion(i, j)
                        }
                    }
                    showIncompleteDialog = false
                    handleTacticalChangesAndFinish()
                }) { Text(stringResource(R.string.mark_all_complete), fontWeight = FontWeight.Bold) }
            },
            dismissButton = {
                Row {
                    TextButton(onClick = { showIncompleteDialog = false }) { Text(stringResource(R.string.cancel)) }
                    TextButton(onClick = {
                        showIncompleteDialog = false
                        handleTacticalChangesAndFinish()
                    }) { Text(stringResource(R.string.finish_anyway), color = MaterialTheme.colorScheme.error, fontWeight = FontWeight.Bold) }
                }
            }
        )
    }

    if (showTacticalDialog) {
        AlertDialog(
            onDismissRequest = { showTacticalDialog = false },
            title = { Text(stringResource(R.string.tactical_change), fontWeight = FontWeight.Black, letterSpacing = 1.sp) },
            text = { Text(stringResource(R.string.modified_workout_warning)) },
            confirmButton = {
                TextButton(onClick = {
                    showTacticalDialog = false
                    proceedToFinish(updateRoutine = true)
                }) { Text(stringResource(R.string.update_routine), fontWeight = FontWeight.Bold) }
            },
            dismissButton = {
                TextButton(onClick = {
                    showTacticalDialog = false
                    proceedToFinish(updateRoutine = false)
                }) { Text(stringResource(R.string.one_time_only)) }
            }
        )
    }
}
