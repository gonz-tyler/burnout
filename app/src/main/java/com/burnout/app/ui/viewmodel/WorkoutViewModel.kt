package com.burnout.app.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.burnout.app.data.datastore.SettingsDataStore
import com.burnout.app.data.local.entity.*
import com.burnout.app.data.repository.WorkoutRepository
import com.burnout.app.domain.model.ExerciseResult
import com.burnout.app.domain.service.StreakService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.util.Calendar
import javax.inject.Inject

data class WorkoutUiState(
    val routines: List<Routine> = emptyList(),
    val exercises: List<Exercise> = emptyList(),
    val workoutSessions: List<WorkoutSession> = emptyList(),
    val measurements: List<BodyMeasurement> = emptyList(),
    val unitSystem: String = "metric",
    val gender: String = "unspecified",
    val weeklyGoal: Int = 3,
    val currentStreak: Int = 0,
    val completedLaborCount: Int = 0
) {
    val latestMeasurement: BodyMeasurement? get() = measurements.lastOrNull()

    val totalVolume: Double
        get() = workoutSessions.sumOf { session ->
            session.performedExercises.sumOf { exercise ->
                exercise.sets.sumOf { set ->
                    (set.weight ?: 0.0) * (set.reps ?: 0)
                }
            }
        }

    val hasWorkedOutToday: Boolean
        get() {
            val today = Calendar.getInstance()
            return workoutSessions.any { session ->
                val cal = Calendar.getInstance().apply { timeInMillis = session.dateCompleted }
                cal.get(Calendar.YEAR) == today.get(Calendar.YEAR) &&
                        cal.get(Calendar.DAY_OF_YEAR) == today.get(Calendar.DAY_OF_YEAR)
            }
        }
}

@HiltViewModel
class WorkoutViewModel @Inject constructor(
    private val workoutRepository: WorkoutRepository,
    private val settingsDataStore: SettingsDataStore,
    private val streakService: StreakService
) : ViewModel() {

    private val _uiState = MutableStateFlow(WorkoutUiState())
    val uiState: StateFlow<WorkoutUiState> = _uiState.asStateFlow()

    private val streakFlow: Flow<Int> = combine(
        workoutRepository.observeWorkoutSessions(),
        settingsDataStore.weeklyGoal,
        settingsDataStore.streakState
    ) { sessions, goal, stored ->
        val today = LocalDate.now()
        val seeded = if (stored.goalHistory.isEmpty()) streakService.setGoal(stored, goal, today) else stored
        val days = sessions
            .map { Instant.ofEpochMilli(it.dateCompleted).atZone(ZoneId.systemDefault()).toLocalDate() }
            .toSet()
        stored to streakService.evaluate(seeded, days, today)
    }.onEach { (stored, result) ->
        if (result.state != stored) {
            settingsDataStore.updateStreakState { cur -> if (cur == stored) result.state else cur }
        }
    }.map { (_, result) -> result.streak }

    init {
        loadData()
    }

    private fun loadData() {
        viewModelScope.launch {
            combine(
                workoutRepository.observeRoutines(),
                workoutRepository.observeExercises(),
                workoutRepository.observeWorkoutSessions(),
                combine(
                    settingsDataStore.unitSystem,
                    settingsDataStore.weeklyGoal,
                    settingsDataStore.gender
                ) { u, g, gen -> Triple(u, g, gen) },
                streakFlow
            ) { routines, exercises, sessions, (unitSystem, weeklyGoal, gender), streak ->
                val sortedRoutines = routines.sortedBy { it.sortOrder ?: 999999 }
                val measurements = workoutRepository.getBodyMeasurements().sortedBy { it.date }

                val benchPr = getPrFor(exercises, sessions, "Bench Press")
                val squatPr = getPrFor(exercises, sessions, "Squat")
                val deadliftPr = getPrFor(exercises, sessions, "Deadlift")
                val ohpPr = getPrFor(exercises, sessions, "Overhead Press")

                val laborCount = com.burnout.app.domain.service.LaborsService.countCompletedLabors(
                    latestBodyWeightKg = measurements.lastOrNull()?.weightKg,
                    benchPr = benchPr,
                    squatPr = squatPr,
                    deadliftPr = deadliftPr,
                    ohpPr = ohpPr,
                    totalVolume = sessions.sumOf { s ->
                        s.performedExercises.sumOf { e ->
                            e.sets.sumOf { (it.weight ?: 0.0) * (it.reps ?: 0) }
                        }
                    },
                    workoutCount = sessions.size,
                    currentStreak = streak
                )

                WorkoutUiState(
                    routines = sortedRoutines,
                    exercises = exercises,
                    workoutSessions = sessions,
                    measurements = measurements,
                    unitSystem = unitSystem,
                    gender = gender,
                    weeklyGoal = weeklyGoal,
                    currentStreak = streak,
                    completedLaborCount = laborCount
                )
            }.collect { updatedState ->
                _uiState.value = updatedState
            }
        }
    }

    fun setWeeklyGoal(days: Int) {
        viewModelScope.launch {
            settingsDataStore.setWeeklyGoal(days)
            settingsDataStore.updateStreakState { streakService.setGoal(it, days, LocalDate.now()) }
        }
    }

    fun addMeasurement(measurement: BodyMeasurement) {
        viewModelScope.launch {
            workoutRepository.addMeasurement(measurement)
            val updated = (uiState.value.measurements + measurement).sortedBy { it.date }
            _uiState.update { it.copy(measurements = updated) }
        }
    }

    fun reorderRoutines(oldIndex: Int, newIndex: Int) {
        viewModelScope.launch {
            val list = uiState.value.routines.toMutableList()
            val adjustedIndex = if (oldIndex < newIndex) newIndex - 1 else newIndex
            val item = list.removeAt(oldIndex)
            list.add(adjustedIndex, item)

            list.forEachIndexed { i, routine ->
                val updated = routine.copy(sortOrder = i)
                workoutRepository.updateRoutine(updated)
            }
        }
    }

    fun updateRoutineWeights(routineId: String, results: List<ExerciseResult>) {
        viewModelScope.launch {
            val routine = uiState.value.routines.find { it.id == routineId } ?: return@launch

            val updatedExercises = routine.exercises.map { routineEx ->
                val matchingResult = results.find { it.exerciseId == routineEx.exerciseId }
                if (matchingResult != null) {
                    val updatedSets = routineEx.plannedSets.map { set ->
                        if (set.setType == SetType.NORMAL) {
                            set.copy(
                                targetWeight = matchingResult.nextWeight,
                                targetReps = matchingResult.nextTargetReps?.toString() ?: set.targetReps
                            )
                        } else set
                    }
                    routineEx.copy(plannedSets = updatedSets)
                } else routineEx
            }

            workoutRepository.updateRoutine(routine.copy(exercises = updatedExercises))
        }
    }

    private fun estimateOneRepMax(weight: Double, reps: Int): Double {
        if (reps <= 1) return weight
        return weight * (1.0 + (reps / 30.0))
    }

    fun getPersonalRecord(exerciseNameQuery: String): Double {
        return getPrFor(uiState.value.exercises, uiState.value.workoutSessions, exerciseNameQuery)
    }

    private fun getPrFor(exercises: List<Exercise>, sessions: List<WorkoutSession>, exerciseNameQuery: String): Double {
        val targetIds = exercises
            .filter { it.name.contains(exerciseNameQuery, ignoreCase = true) }
            .map { it.id }
            .toSet()

        if (targetIds.isEmpty()) return 0.0

        var max1RM = 0.0
        sessions.forEach { session ->
            session.performedExercises.forEach { performed ->
                if (performed.exerciseId in targetIds) {
                    performed.sets.forEach { set ->
                        val weight = set.weight ?: 0.0
                        val reps = set.reps ?: 1
                        if (weight > 0.0) {
                            val est = estimateOneRepMax(weight, reps)
                            if (est > max1RM) max1RM = est
                        }
                    }
                }
            }
        }
        return max1RM
    }

    fun getPreviousSet(exerciseId: String, setIndex: Int): PerformedSet? {
        val sessions = uiState.value.workoutSessions
        for (i in sessions.indices.reversed()) {
            val performed = sessions[i].performedExercises.find { it.exerciseId == exerciseId }
            if (performed != null) {
                return performed.sets.getOrNull(setIndex)
            }
        }
        return null
    }

//    fun getIdealProportions(wristSizeCm: Double, gender: String = "unspecified"): Map<String, Double> {
//        return if (gender == "female") {
//            val baseFrame = wristSizeCm * 5.8
//            mapOf(
//                "Shoulders" to baseFrame * 1.17,
//                "Glutes" to baseFrame * 1.00,
//                "Waist" to baseFrame * 0.70,
//                "Thigh" to baseFrame * 0.52,
//                "Neck" to baseFrame * 0.38,
//                "Calf" to baseFrame * 0.32,
//                "Bicep" to baseFrame * 0.26,
//                "Forearm" to baseFrame * 0.23
//            )
//        } else {
//            val chestBase = wristSizeCm * 6.5
//            mapOf(
//                "Chest" to chestBase,
//                "Shoulders" to chestBase * 1.1326,
//                "Hips" to chestBase * 0.85,
//                "Waist" to chestBase * 0.70,
//                "Thigh" to chestBase * 0.53,
//                "Neck" to chestBase * 0.37,
//                "Bicep" to chestBase * 0.36,
//                "Calf" to chestBase * 0.34,
//                "Forearm" to chestBase * 0.29
//            )
//        }
//    }
    fun getIdealProportions(wristCm: Double, gender: String): Map<String, Double> {
        val normalizedGender = gender.lowercase()
        val isFemale = normalizedGender == "female" || normalizedGender == "female_soft"

        return if (isFemale) {
            calculateFemaleIdeals(wristCm)
        } else {
            calculateMaleIdeals(wristCm)
        }
    }

    private fun calculateFemaleIdeals(wristCm: Double): Map<String, Double> {
        // Female Proportions (Anchored to wrist size for athletic symmetry)
        val shoulders = wristCm * 6.0
        val glutes = wristCm * 5.8
        val waist = wristCm * 3.8
        val bicep = wristCm * 1.9
        val forearm = wristCm * 1.5
        val thigh = wristCm * 3.3
        val calf = wristCm * 2.1

        return mapOf(
            "Shoulders" to shoulders,
            "Glutes" to glutes,
            "Waist" to waist,
            "Bicep" to bicep,
            "Forearm" to forearm,
            "Thigh" to thigh,
            "Calf" to calf
        )
    }

    private fun calculateMaleIdeals(wristCm: Double): Map<String, Double> {
        // Male Grecian Formula (Golden Ratio Proportions)
        val chest = wristCm * 6.5
        val neck = chest * 0.37
        val shoulders = chest * 1.18
        val waist = chest * 0.70
        val hips = chest * 0.85
        val bicep = chest * 0.36
        val forearm = chest * 0.29
        val thigh = chest * 0.53
        val calf = chest * 0.34

        return mapOf(
            "Chest" to chest,
            "Neck" to neck,
            "Shoulders" to shoulders,
            "Waist" to waist,
            "Hips" to hips,
            "Bicep" to bicep,
            "Forearm" to forearm,
            "Thigh" to thigh,
            "Calf" to calf
        )
    }

    fun addRoutine(routine: Routine) {
        viewModelScope.launch {
            val newRoutine = routine.copy(sortOrder = uiState.value.routines.size)
            workoutRepository.updateRoutine(newRoutine)
        }
    }

    fun deleteRoutine(routineId: String) {
        viewModelScope.launch { workoutRepository.deleteRoutine(routineId) }
    }

    fun duplicateRoutine(routineId: String) {
        viewModelScope.launch { workoutRepository.duplicateRoutine(routineId) }
    }

    fun addWorkoutSession(session: WorkoutSession) {
        viewModelScope.launch { workoutRepository.addWorkoutSession(session) }
    }
}