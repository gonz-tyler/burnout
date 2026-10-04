package com.burnout.app.ui.workout

import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import com.burnout.app.data.local.entity.Exercise
import com.burnout.app.data.local.entity.RoutineExercise
import com.burnout.app.ui.routine.components.RoutineExerciseCard
import com.burnout.app.ui.viewmodel.ActiveWorkoutViewModel
import com.burnout.app.ui.viewmodel.RestTimerViewModel
import com.burnout.app.ui.viewmodel.WorkoutViewModel

@Composable
fun ExerciseCard(
    modifier: Modifier = Modifier,
    routineExercise: RoutineExercise,
    exerciseDetails: Exercise,
    exerciseIndex: Int,
    isMetric: Boolean,
    activeViewModel: ActiveWorkoutViewModel,
    workoutViewModel: WorkoutViewModel,
    restTimerViewModel: RestTimerViewModel,
    setCompletionStatus: Map<String, Boolean>,
    onShowTypePicker: (Int) -> Unit
) {
    RoutineExerciseCard(
        modifier = modifier,
        exercise = routineExercise,
        exerciseDetails = exerciseDetails,
        unitSystem = if (isMetric) "metric" else "imperial",
        showPrev = true,
        onUpdateExercise = { updated ->
            activeViewModel.updateLiveExercise(exerciseIndex, updated)
        },
        onDeleteExercise = {
            activeViewModel.deleteExercise(exerciseIndex)
        },
        onAddSet = {
            activeViewModel.addSet(exerciseIndex)
        },
        onUpdateSet = { setIndex, updatedSet ->
            activeViewModel.updateSetData(exerciseIndex, setIndex, updatedSet)
        },
        onDeleteSet = { setIndex ->
            activeViewModel.removeSet(exerciseIndex, setIndex)
        },
        onShowTypePicker = onShowTypePicker,
        setCompletionStatus = setCompletionStatus,
        onToggleCompletion = { setIndex ->
            val wasAlreadyCompleted = activeViewModel.isSetCompleted(exerciseIndex, setIndex)
            activeViewModel.toggleSetCompletion(exerciseIndex, setIndex)
            if (!wasAlreadyCompleted) {
                restTimerViewModel.start(routineExercise.restTimeInSeconds)
            }
        },
        getPreviousSet = { setIndex ->
            workoutViewModel.getPreviousSet(routineExercise.exerciseId, setIndex)
        }
    )
}
