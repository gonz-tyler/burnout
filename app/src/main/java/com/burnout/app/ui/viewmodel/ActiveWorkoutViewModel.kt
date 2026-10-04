package com.burnout.app.ui.viewmodel

import androidx.lifecycle.ViewModel
import com.burnout.app.data.local.entity.*
import com.burnout.app.domain.model.ExerciseResult
import com.burnout.app.domain.model.WeightMode
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

// WeightMode comes from com.burnout.app.domain.model — the local
// `enum class WeightMode` that used to live in this file duplicated that
// one and is removed. ExerciseResult.kt already references the
// domain.model version, so this keeps both sides on the same type.

data class ActiveWorkoutUiState(
    val routine: Routine? = null,
    val isWorkoutStarted: Boolean = false,
    val liveExercises: List<RoutineExercise> = emptyList(),
    val setCompletionStatus: Map<String, Boolean> = emptyMap(),
    val exerciseWeightModes: Map<String, WeightMode> = emptyMap(),
    // Results for the battle report
    val battleResults: List<ExerciseResult> = emptyList(),
    val battleDurationMinutes: Int = 0
) {
    val progress: Float
        get() {
            val totalSets = liveExercises.sumOf { it.plannedSets.size }
            if (totalSets == 0) return 0f
            val completed = setCompletionStatus.values.count { it }
            return completed.toFloat() / totalSets
        }
}

class ActiveWorkoutViewModel : ViewModel() {

    private val _uiState = MutableStateFlow(ActiveWorkoutUiState())
    val uiState: StateFlow<ActiveWorkoutUiState> = _uiState.asStateFlow()

    /** Pass null for a blank/ad-hoc workout with no starting routine. */
    fun startWorkout(routine: Routine?) {
        val initialModes = mutableMapOf<String, WeightMode>()
        val exercises = routine?.exercises.orEmpty()

        exercises.forEach { exercise ->
            val hasNegativeWeight = exercise.plannedSets.any { (it.targetWeight ?: 0.0) < 0.0 }
            if (hasNegativeWeight) {
                initialModes[exercise.exerciseId] = WeightMode.ASSISTED
            }
        }

        _uiState.value = ActiveWorkoutUiState(
            routine = routine,
            isWorkoutStarted = true,
            liveExercises = exercises.map { it.copy(plannedSets = it.plannedSets.map { s -> s.copy() }) },
            setCompletionStatus = emptyMap(),
            exerciseWeightModes = initialModes
        )
    }

    private fun getSetKey(exerciseId: String, setIndex: Int): String = "e${exerciseId}s$setIndex"

    fun getWeightModeForExercise(exercise: Exercise): WeightMode {
        val currentModes = uiState.value.exerciseWeightModes
        return currentModes[exercise.id] ?: when {
            exercise.supportsWeight -> WeightMode.WEIGHTED
            exercise.supportsBodyweight -> WeightMode.BODYWEIGHT
            exercise.supportsAssistance -> WeightMode.ASSISTED
            else -> WeightMode.WEIGHTED
        }
    }

    fun cycleWeightModeForExercise(exerciseIndex: Int, exerciseDetails: Exercise) {
        val currentState = uiState.value
        val modes = mutableListOf<WeightMode>().apply {
            if (exerciseDetails.supportsWeight) add(WeightMode.WEIGHTED)
            if (exerciseDetails.supportsBodyweight) add(WeightMode.BODYWEIGHT)
            if (exerciseDetails.supportsAssistance) add(WeightMode.ASSISTED)
        }

        if (modes.size < 2) return

        val currentMode = getWeightModeForExercise(exerciseDetails)
        val nextMode = modes[(modes.indexOf(currentMode) + 1) % modes.size]

        val updatedExercises = currentState.liveExercises.toMutableList()
        val routineExercise = updatedExercises[exerciseIndex]

        val updatedSets = routineExercise.plannedSets.map { currentSet ->
            val currentAbs = Math.abs(currentSet.targetWeight ?: 0.0)
            val newWeight = when (nextMode) {
                WeightMode.WEIGHTED -> currentAbs
                WeightMode.BODYWEIGHT -> 0.0
                WeightMode.ASSISTED -> -currentAbs
            }
            currentSet.copy(targetWeight = newWeight)
        }

        updatedExercises[exerciseIndex] = routineExercise.copy(plannedSets = updatedSets)

        _uiState.update { state ->
            state.copy(
                liveExercises = updatedExercises,
                exerciseWeightModes = state.exerciseWeightModes + (exerciseDetails.id to nextMode)
            )
        }
    }

    fun isSetCompleted(exerciseIndex: Int, setIndex: Int): Boolean {
        val exercise = uiState.value.liveExercises.getOrNull(exerciseIndex) ?: return false
        val key = getSetKey(exercise.exerciseId, setIndex)
        return uiState.value.setCompletionStatus[key] ?: false
    }

    fun toggleSetCompletion(exerciseIndex: Int, setIndex: Int) {
        val currentState = uiState.value
        val exerciseId = currentState.liveExercises[exerciseIndex].exerciseId
        val key = getSetKey(exerciseId, setIndex)
        val currentStatus = currentState.setCompletionStatus[key] ?: false

        _uiState.update { state ->
            val newMap = state.setCompletionStatus.toMutableMap()
            newMap[key] = !currentStatus
            state.copy(setCompletionStatus = newMap)
        }
    }

    fun updateLiveExercise(index: Int, updatedExercise: RoutineExercise) {
        _uiState.update { state ->
            val list = state.liveExercises.toMutableList()
            if (index in list.indices) {
                list[index] = updatedExercise
            }
            state.copy(liveExercises = list)
        }
    }

    fun updateSetData(exerciseIndex: Int, setIndex: Int, updatedSet: PlannedSet) {
        _uiState.update { state ->
            val exercises = state.liveExercises.toMutableList()
            val sets = exercises[exerciseIndex].plannedSets.toMutableList()
            sets[setIndex] = updatedSet
            exercises[exerciseIndex] = exercises[exerciseIndex].copy(plannedSets = sets)
            state.copy(liveExercises = exercises)
        }
    }

    /** Appends a new set, copying targets from the last set. */
    fun addSet(exerciseIndex: Int) {
        _uiState.update { state ->
            val exercises = state.liveExercises.toMutableList()
            val exercise = exercises[exerciseIndex]
            val lastSet = exercise.plannedSets.lastOrNull()
            val newSet = PlannedSet(
                setType = SetType.NORMAL,
                targetWeight = lastSet?.targetWeight,
                targetReps = lastSet?.targetReps,
                targetDurationInSeconds = lastSet?.targetDurationInSeconds,
                targetDistanceInMeters = lastSet?.targetDistanceInMeters
            )
            exercises[exerciseIndex] = exercise.copy(plannedSets = exercise.plannedSets + newSet)
            state.copy(liveExercises = exercises)
        }
    }

    /**
     * Removes a set and re-keys completion status for that exercise so later
     * sets' completed/incomplete state doesn't shift onto the wrong index.
     */
    fun removeSet(exerciseIndex: Int, setIndex: Int) {
        _uiState.update { state ->
            val exercises = state.liveExercises.toMutableList()
            val exercise = exercises[exerciseIndex]
            val exerciseId = exercise.exerciseId
            val oldSets = exercise.plannedSets
            val newSets = oldSets.toMutableList().apply { removeAt(setIndex) }
            exercises[exerciseIndex] = exercise.copy(plannedSets = newSets)

            val rebuiltStatus = state.setCompletionStatus.toMutableMap()
            val keysForThisExercise = state.setCompletionStatus.keys.filter { it.startsWith("e${exerciseId}s") }
            keysForThisExercise.forEach { rebuiltStatus.remove(it) }
            oldSets.forEachIndexed { oldIndex, _ ->
                if (oldIndex == setIndex) return@forEachIndexed
                val wasCompleted = state.setCompletionStatus[getSetKey(exerciseId, oldIndex)] ?: return@forEachIndexed
                val newIndex = if (oldIndex > setIndex) oldIndex - 1 else oldIndex
                rebuiltStatus[getSetKey(exerciseId, newIndex)] = wasCompleted
            }

            state.copy(liveExercises = exercises, setCompletionStatus = rebuiltStatus)
        }
    }

    fun addExercise(newExercise: RoutineExercise) {
        _uiState.update { state ->
            val newModes = state.exerciseWeightModes.toMutableMap()
            if (newExercise.plannedSets.any { (it.targetWeight ?: 0.0) < 0.0 }) {
                newModes[newExercise.exerciseId] = WeightMode.ASSISTED
            }
            state.copy(
                liveExercises = state.liveExercises + newExercise,
                exerciseWeightModes = newModes
            )
        }
    }

    fun deleteExercise(index: Int) {
        _uiState.update { state ->
            state.copy(liveExercises = state.liveExercises.filterIndexed { i, _ -> i != index })
        }
    }

    fun hasRoutineChanged(): Boolean {
        val state = uiState.value
        val original = state.routine ?: return false
        if (state.liveExercises.size != original.exercises.size) return true
        return state.liveExercises.indices.any { i ->
            state.liveExercises[i].exerciseId != original.exercises[i].exerciseId
        }
    }

    fun getPerformedExercises(): List<PerformedExercise> {
        val state = uiState.value
        val performed = mutableListOf<PerformedExercise>()

        state.liveExercises.forEachIndexed { exIndex, routineEx ->
            val performedSets = mutableListOf<PerformedSet>()
            routineEx.plannedSets.forEachIndexed { setIndex, plannedSet ->
                val key = getSetKey(routineEx.exerciseId, setIndex)
                if (state.setCompletionStatus[key] == true) {
                    performedSets.add(
                        PerformedSet(
                            setType = plannedSet.setType,
                            reps = plannedSet.targetReps?.toIntOrNull(),
                            weight = plannedSet.targetWeight
                        )
                    )
                }
            }
            if (performedSets.isNotEmpty()) {
                performed.add(PerformedExercise(exerciseId = routineEx.exerciseId, sets = performedSets))
            }
        }
        return performed
    }

    /** Resets state after the session has been saved and the flow moves on. */
    fun finishWorkout(results: List<ExerciseResult>, durationMinutes: Int) {
        _uiState.update { 
            it.copy(
                isWorkoutStarted = false,
                battleResults = results,
                battleDurationMinutes = durationMinutes
            )
        }
    }

    fun clearSession() {
        _uiState.update { ActiveWorkoutUiState() }
    }
}