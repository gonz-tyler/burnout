package com.burnout.app.ui.viewmodel

import com.burnout.app.data.datastore.SettingsDataStore
import com.burnout.app.data.local.entity.*
import com.burnout.app.data.repository.WorkoutRepository
import com.burnout.app.domain.model.ExerciseResult
import com.burnout.app.domain.model.WeightMode
import com.burnout.app.domain.service.StreakState
import com.burnout.app.domain.service.StreakService
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import java.time.LocalDate
import java.time.ZoneId

/**
 * Plain JVM test (no Robolectric). Repository, DataStore and StreakService are MockK mocks.
 * Needs: testImplementation("io.mockk:mockk:<latest 1.13.x/1.14.x>") and kotlinx-coroutines-test.
 *
 * Search for "ADJUST" for the spots that depend on classes I have not seen.
 */
@OptIn(ExperimentalCoroutinesApi::class)
class WorkoutViewModelTest {

    private val delta = 1e-9

    private val repo = mockk<WorkoutRepository>(relaxed = true)
    private val settings = mockk<SettingsDataStore>(relaxed = true)
    private val streakService = mockk<StreakService>()

    private val storedState = mockk<StreakState>(relaxed = true)
    private val seededState = mockk<StreakState>(relaxed = true)
    private val resultState = mockk<StreakState>(relaxed = true)

    @Before
    fun setUp() {
        // Eager dispatcher: viewModelScope.launch runs immediately, so state is ready after construction.
        Dispatchers.setMain(UnconfinedTestDispatcher())
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    // ---------------------------------------------------------------------
    // Builders
    // ---------------------------------------------------------------------

    private fun vm(
        routines: List<Routine> = emptyList(),
        exercises: List<Exercise> = emptyList(),
        sessions: List<WorkoutSession> = emptyList(),
        measurements: List<BodyMeasurement> = emptyList(),
        unitSystem: String = "metric",
        weeklyGoal: Int = 3,
        gender: String = "unspecified",
        streakDays: Int = 0,
        historyEmpty: Boolean = false,
        stateChanged: Boolean = false,
    ): WorkoutViewModel {
        every { repo.observeRoutines() } returns flowOf(routines)
        every { repo.observeExercises() } returns flowOf(exercises)
        every { repo.observeWorkoutSessions() } returns flowOf(sessions)
        coEvery { repo.getBodyMeasurements() } returns measurements

        every { settings.unitSystem } returns flowOf(unitSystem)
        every { settings.weeklyGoal } returns flowOf(weeklyGoal)
        every { settings.gender } returns flowOf(gender)
        every { settings.streakState } returns flowOf(storedState)

        every { storedState.goalHistory.isEmpty() } returns historyEmpty
        every { streakService.setGoal(any(), any(), any()) } returns seededState
        val after = if (stateChanged) resultState else storedState
        every { streakService.evaluate(any(), any(), any()) } returns mockk {
            every { state } returns after
            every { streak } returns streakDays
        }

        return WorkoutViewModel(repo, settings, streakService)
    }

    private fun exercise(id: String, name: String) = Exercise(
        id = id,
        name = name,
        muscleGroup = "Test",
        instructions = "",
        equipment = "None",
        targetedMuscles = emptyMap()
    )

    private fun set(reps: Int?, weight: Double?) = PerformedSet(SetType.NORMAL, reps, weight)

    private fun performed(exerciseId: String, vararg sets: PerformedSet) =
        PerformedExercise(exerciseId, sets.toList())

    private fun session(
        id: String = "s",
        dateCompleted: Long = System.currentTimeMillis(),
        vararg exercises: PerformedExercise,
    ) = WorkoutSession(
        id = id,
        dateCompleted = dateCompleted,
        durationInMinutes = 30,
        performedExercises = exercises.toList()
    )

    private fun measurement(date: Long, weightKg: Double? = null) =
        BodyMeasurement(id = "m$date", date = date, weightKg = weightKg)

    private fun plannedSet(type: SetType, weight: Double? = null, reps: String? = null) =
        PlannedSet(setType = type, targetWeight = weight, targetReps = reps)

    private fun routineExercise(exerciseId: String, vararg sets: PlannedSet) =
        RoutineExercise(exerciseId = exerciseId, exerciseName = "Bench", plannedSets = sets.toList(), restTimeInSeconds = 90)

    private fun routine(
        id: String,
        sortOrder: Int? = null,
        exercises: List<RoutineExercise> = emptyList(),
    ) = Routine(id = id, name = "Routine $id", exercises = exercises, sortOrder = sortOrder)

    private fun result(exerciseId: String, nextWeight: Double, nextTargetReps: Int?) =
        ExerciseResult(
            exerciseId = exerciseId,
            nextWeight = nextWeight,
            nextTargetReps = nextTargetReps,
            exerciseName = "Bench",
            weightUsed = 50.0,
            isPr = false,
            difficultyRating = 4,
            weightMode = WeightMode.WEIGHTED,
            repsAchieved = 10
        )

    // =====================================================================
    // WorkoutUiState (derived properties)
    // =====================================================================

    @Test
    fun uiState_defaults() {
        val s = WorkoutUiState()
        assertTrue(s.routines.isEmpty())
        assertTrue(s.exercises.isEmpty())
        assertTrue(s.workoutSessions.isEmpty())
        assertTrue(s.measurements.isEmpty())
        assertEquals("metric", s.unitSystem)
        assertEquals("unspecified", s.gender)
        assertEquals(3, s.weeklyGoal)
        assertEquals(0, s.currentStreak)
        assertEquals(0, s.completedLaborCount)
    }

    @Test
    fun uiState_latestMeasurement_isNullWhenEmpty() {
        assertNull(WorkoutUiState().latestMeasurement)
    }

    @Test
    fun uiState_latestMeasurement_isTheLastInTheList() {
        val s = WorkoutUiState(measurements = listOf(measurement(1L), measurement(2L)))
        assertEquals(2L, s.latestMeasurement?.date)
    }

    @Test
    fun uiState_totalVolume_isWeightTimesRepsAcrossEverything() {
        val s = WorkoutUiState(
            workoutSessions = listOf(
                session("a", exercises = arrayOf(performed("x", set(10, 100.0), set(5, 50.0)))),
                session("b", exercises = arrayOf(performed("y", set(8, 20.0)))),
            )
        )
        assertEquals(1000.0 + 250.0 + 160.0, s.totalVolume, delta)
    }

    @Test
    fun uiState_totalVolume_isZeroWithNoSessions() {
        assertEquals(0.0, WorkoutUiState().totalVolume, delta)
    }

    @Test
    fun uiState_totalVolume_treatsNullWeightOrRepsAsZero() {
        val s = WorkoutUiState(
            workoutSessions = listOf(
                session(exercises = arrayOf(performed("x", set(null, 100.0), set(10, null), set(5, 20.0))))
            )
        )
        assertEquals(100.0, s.totalVolume, delta)
    }

    @Test
    fun uiState_hasWorkedOutToday_trueForASessionNow() {
        val s = WorkoutUiState(workoutSessions = listOf(session()))
        assertTrue(s.hasWorkedOutToday)
    }

    @Test
    fun uiState_hasWorkedOutToday_falseForOlderSessions() {
        val twoDaysAgo = System.currentTimeMillis() - 2 * 86_400_000L
        val s = WorkoutUiState(workoutSessions = listOf(session(dateCompleted = twoDaysAgo)))
        assertFalse(s.hasWorkedOutToday)
    }

    @Test
    fun uiState_hasWorkedOutToday_falseWithNoSessions() {
        assertFalse(WorkoutUiState().hasWorkedOutToday)
    }

    // =====================================================================
    // State assembly (loadData)
    // =====================================================================

    @Test
    fun load_mapsSettingsAndStreakIntoState() {
        val state = vm(unitSystem = "imperial", weeklyGoal = 5, gender = "female", streakDays = 7).uiState.value
        assertEquals("imperial", state.unitSystem)
        assertEquals(5, state.weeklyGoal)
        assertEquals("female", state.gender)
        assertEquals(7, state.currentStreak)
    }

    @Test
    fun load_passesExercisesAndSessionsThrough() {
        val exercises = listOf(exercise("e1", "Squat"))
        val sessions = listOf(session("s1"))
        val state = vm(exercises = exercises, sessions = sessions).uiState.value
        assertEquals(exercises, state.exercises)
        assertEquals(sessions, state.workoutSessions)
    }

    @Test
    fun load_sortsRoutinesBySortOrder_withNullLast() {
        val state = vm(
            routines = listOf(routine("a", 2), routine("b", null), routine("c", 0))
        ).uiState.value
        assertEquals(listOf("c", "a", "b"), state.routines.map { it.id })
    }

    @Test
    fun load_sortsMeasurementsByDate() {
        val state = vm(measurements = listOf(measurement(30L), measurement(10L), measurement(20L))).uiState.value
        assertEquals(listOf(10L, 20L, 30L), state.measurements.map { it.date })
    }

    // ---- completedLaborCount -------------------------------------------

    private val bench = exercise("bench", "Bench Press")
    private fun benchSessionAt100kg() =
        session(exercises = arrayOf(performed("bench", set(1, 100.0))))

    @Test
    fun laborCount_usesLatestMeasurementBodyWeight() {
        // 80 kg -> bench target 100 -> a 100 kg lift completes the Nemean Lion.
        val done = vm(
            exercises = listOf(bench),
            sessions = listOf(benchSessionAt100kg()),
            measurements = listOf(measurement(1L, 80.0)),
        ).uiState.value
        assertEquals(1, done.completedLaborCount)

        // 100 kg -> bench target 125 -> same lift is not enough.
        val notDone = vm(
            exercises = listOf(bench),
            sessions = listOf(benchSessionAt100kg()),
            measurements = listOf(measurement(1L, 100.0)),
        ).uiState.value
        assertEquals(0, notDone.completedLaborCount)
    }

    @Test
    fun laborCount_withoutMeasurements_usesDefaultBodyWeight() {
        // default 75 kg -> bench target 93.75
        val state = vm(exercises = listOf(bench), sessions = listOf(benchSessionAt100kg())).uiState.value
        assertEquals(1, state.completedLaborCount)
    }

    @Test
    fun laborCount_isZeroWithNoData() {
        assertEquals(0, vm().uiState.value.completedLaborCount)
    }

    // =====================================================================
    // Streak flow
    // =====================================================================

    @Test
    fun streak_emptyGoalHistory_seedsTheGoalBeforeEvaluating() {
        vm(weeklyGoal = 4, historyEmpty = true)
        verify { streakService.setGoal(storedState, 4, any()) }
        verify { streakService.evaluate(seededState, any(), any()) }
    }

    @Test
    fun streak_existingGoalHistory_evaluatesStoredStateDirectly() {
        vm(historyEmpty = false)
        verify(exactly = 0) { streakService.setGoal(any(), any(), any()) }
        verify { streakService.evaluate(storedState, any(), any()) }
    }

    @Test
    fun streak_passesDistinctLocalDatesOfSessions() {
        val zone = ZoneId.systemDefault()
        fun millis(d: LocalDate, hour: Int) = d.atTime(hour, 0).atZone(zone).toInstant().toEpochMilli()
        val d1 = LocalDate.of(2026, 10, 5)
        val d2 = LocalDate.of(2026, 10, 6)

        vm(
            sessions = listOf(
                session("a", millis(d1, 8)),
                session("b", millis(d1, 20)), // same day: collapses
                session("c", millis(d2, 12)),
            )
        )

        verify { streakService.evaluate(any(), match<Set<LocalDate>> { it == setOf(d1, d2) }, any()) }
    }

    @Test
    fun streak_changedState_isPersisted_onlyIfStoredStateIsStillCurrent() = runStreakPersistCheck()

    private fun runStreakPersistCheck() {
        vm(stateChanged = true)

        val transform = slot<(StreakState) -> StreakState>() // ADJUST if updateStreakState takes a different lambda type
        coVerify { settings.updateStreakState(capture(transform)) }

        // Nobody changed it in the meantime: take the new state.
        assertSame(resultState, transform.captured(storedState))
        // Someone else changed it first: keep theirs.
        val other = mockk<StreakState>(relaxed = true)
        assertSame(other, transform.captured(other))
    }

    @Test
    fun streak_unchangedState_isNotPersisted() {
        vm(stateChanged = false)
        coVerify(exactly = 0) { settings.updateStreakState(any()) }
    }

    // =====================================================================
    // setWeeklyGoal
    // =====================================================================

    @Test
    fun setWeeklyGoal_savesGoalAndUpdatesStreakState() {
        val vm = vm()
        vm.setWeeklyGoal(5)

        coVerify { settings.setWeeklyGoal(5) }

        val transform = slot<(StreakState) -> StreakState>() // ADJUST as above
        coVerify { settings.updateStreakState(capture(transform)) }
        assertSame(seededState, transform.captured(storedState))
        verify { streakService.setGoal(storedState, 5, any()) }
    }

    // =====================================================================
    // addMeasurement
    // =====================================================================

    @Test
    fun addMeasurement_savesAndInsertsInDateOrder() {
        val vm = vm(measurements = listOf(measurement(20L), measurement(40L)))
        val added = measurement(30L, 82.0)

        vm.addMeasurement(added)

        coVerify { repo.addMeasurement(added) }
        assertEquals(listOf(20L, 30L, 40L), vm.uiState.value.measurements.map { it.date })
        assertEquals(40L, vm.uiState.value.latestMeasurement?.date)
    }

    // =====================================================================
    // Routines
    // =====================================================================

    private fun threeRoutines() = listOf(routine("A", 0), routine("B", 1), routine("C", 2))

    @Test
    fun reorder_movingDown_usesAdjustedIndexAndRewritesSortOrder() {
        val vm = vm(routines = threeRoutines())
        vm.reorderRoutines(oldIndex = 0, newIndex = 2) // A to just before C -> B, A, C

        coVerify { repo.updateRoutine(match { it.id == "B" && it.sortOrder == 0 }) }
        coVerify { repo.updateRoutine(match { it.id == "A" && it.sortOrder == 1 }) }
        coVerify { repo.updateRoutine(match { it.id == "C" && it.sortOrder == 2 }) }
    }

    @Test
    fun reorder_movingUp_insertsAtNewIndex() {
        val vm = vm(routines = threeRoutines())
        vm.reorderRoutines(oldIndex = 2, newIndex = 0) // C to front -> C, A, B

        coVerify { repo.updateRoutine(match { it.id == "C" && it.sortOrder == 0 }) }
        coVerify { repo.updateRoutine(match { it.id == "A" && it.sortOrder == 1 }) }
        coVerify { repo.updateRoutine(match { it.id == "B" && it.sortOrder == 2 }) }
    }

    @Test
    fun addRoutine_appendsAtTheEnd() {
        val vm = vm(routines = threeRoutines())
        vm.addRoutine(routine("D"))
        coVerify { repo.updateRoutine(match { it.id == "D" && it.sortOrder == 3 }) }
    }

    @Test
    fun deleteRoutine_delegatesToRepository() {
        vm().deleteRoutine("r1")
        coVerify { repo.deleteRoutine("r1") }
    }

    @Test
    fun duplicateRoutine_delegatesToRepository() {
        vm().duplicateRoutine("r1")
        coVerify { repo.duplicateRoutine("r1") }
    }

    @Test
    fun addWorkoutSession_delegatesToRepository() {
        val s = session("new")
        vm().addWorkoutSession(s)
        coVerify { repo.addWorkoutSession(s) }
    }

    // ---- updateRoutineWeights ------------------------------------------

    @Test
    fun updateRoutineWeights_unknownRoutine_doesNothing() {
        val vm = vm(routines = listOf(routine("r1")))
        vm.updateRoutineWeights("missing", listOf(result("e1", 60.0, 8)))
        coVerify(exactly = 0) { repo.updateRoutine(any()) }
    }

    @Test
    fun updateRoutineWeights_updatesOnlyNormalSetsOfMatchingExercises() {
        val r = routine(
            "r1",
            exercises = listOf(
                routineExercise(
                    "e1",
                    plannedSet(SetType.WARMUP, weight = 20.0, reps = "10"),
                    plannedSet(SetType.NORMAL, weight = 50.0, reps = "8"),
                ),
                routineExercise("e2", plannedSet(SetType.NORMAL, weight = 30.0, reps = "12")), // no result for e2
            )
        )
        val vm = vm(routines = listOf(r))

        vm.updateRoutineWeights("r1", listOf(result("e1", nextWeight = 55.0, nextTargetReps = 6)))

        val saved = slot<Routine>()
        coVerify { repo.updateRoutine(capture(saved)) }
        val e1 = saved.captured.exercises.first { it.exerciseId == "e1" }
        val e2 = saved.captured.exercises.first { it.exerciseId == "e2" }

        // warmup untouched
        assertEquals(20.0, e1.plannedSets[0].targetWeight!!, delta)
        assertEquals("10", e1.plannedSets[0].targetReps)
        // normal updated
        assertEquals(55.0, e1.plannedSets[1].targetWeight!!, delta)
        assertEquals("6", e1.plannedSets[1].targetReps)
        // exercise without a result untouched
        assertEquals(30.0, e2.plannedSets[0].targetWeight!!, delta)
        assertEquals("12", e2.plannedSets[0].targetReps)
    }

    @Test
    fun updateRoutineWeights_nullNextTargetReps_keepsExistingReps() {
        val r = routine("r1", exercises = listOf(routineExercise("e1", plannedSet(SetType.NORMAL, 50.0, "8"))))
        val vm = vm(routines = listOf(r))

        vm.updateRoutineWeights("r1", listOf(result("e1", nextWeight = 52.5, nextTargetReps = null)))

        val saved = slot<Routine>()
        coVerify { repo.updateRoutine(capture(saved)) }
        val set = saved.captured.exercises[0].plannedSets[0]
        assertEquals(52.5, set.targetWeight!!, delta)
        assertEquals("8", set.targetReps)
    }

    // =====================================================================
    // Personal records (getPersonalRecord / getPrFor)
    // =====================================================================

    private fun pr(
        query: String,
        exercises: List<Exercise>,
        vararg sessions: WorkoutSession,
    ) = vm(exercises = exercises, sessions = sessions.toList()).getPersonalRecord(query)

    @Test
    fun pr_noMatchingExercise_isZero() {
        val s = session(exercises = arrayOf(performed("e1", set(5, 100.0))))
        assertEquals(0.0, pr("Squat", listOf(exercise("e1", "Bench Press")), s), delta)
    }

    @Test
    fun pr_noSessions_isZero() {
        assertEquals(0.0, pr("Bench Press", listOf(exercise("e1", "Bench Press"))), delta)
    }

    @Test
    fun pr_matchesCaseInsensitively() {
        val s = session(exercises = arrayOf(performed("e1", set(1, 100.0))))
        assertEquals(100.0, pr("bench press", listOf(exercise("e1", "BENCH PRESS")), s), delta)
    }

    @Test
    fun pr_matchesBySubstring_soVariantsCount() {
        // Documents current behaviour: "Bench Press" also matches "Incline Bench Press".
        val s = session(exercises = arrayOf(performed("inc", set(1, 90.0))))
        assertEquals(90.0, pr("Bench Press", listOf(exercise("inc", "Incline Bench Press")), s), delta)
    }

    @Test
    fun pr_singleRepOrLess_usesTheWeightItself() {
        val s = session(exercises = arrayOf(performed("e1", set(1, 100.0))))
        assertEquals(100.0, pr("Squat", listOf(exercise("e1", "Squat")), s), delta)
        val zeroReps = session(exercises = arrayOf(performed("e1", set(0, 80.0))))
        assertEquals(80.0, pr("Squat", listOf(exercise("e1", "Squat")), zeroReps), delta)
    }

    @Test
    fun pr_multipleReps_usesEpleyEstimate() {
        val s = session(exercises = arrayOf(performed("e1", set(5, 100.0))))
        assertEquals(100.0 * (1.0 + 5 / 30.0), pr("Squat", listOf(exercise("e1", "Squat")), s), delta)
    }

    @Test
    fun pr_takesTheBestEstimateAcrossSetsAndSessions() {
        val a = session("a", exercises = arrayOf(performed("e1", set(5, 100.0), set(1, 105.0))))
        val b = session("b", exercises = arrayOf(performed("e1", set(3, 110.0), set(10, 40.0))))
        // estimates: 116.67, 105, 121.0, 53.33 -> best is 110 * 1.1 = 121
        assertEquals(121.0, pr("Squat", listOf(exercise("e1", "Squat")), a, b), delta)
    }

    @Test
    fun pr_ignoresSetsWithZeroWeight() {
        val s = session(exercises = arrayOf(performed("e1", set(10, 0.0))))
        assertEquals(0.0, pr("Pull", listOf(exercise("e1", "Pull Up")), s), delta)
    }

    /** ADJUST: only compiles if reps / weight are nullable. */
    @Test
    fun pr_nullWeightIsSkipped_nullRepsCountAsOne() {
        val s = session(exercises = arrayOf(performed("e1", set(5, null), set(null, 90.0))))
        assertEquals(90.0, pr("Squat", listOf(exercise("e1", "Squat")), s), delta)
    }

    @Test
    fun pr_ignoresPerformedExercisesThatDoNotMatch() {
        val s = session(
            exercises = arrayOf(
                performed("other", set(1, 300.0)),
                performed("e1", set(1, 100.0)),
            )
        )
        val exercises = listOf(exercise("e1", "Squat"), exercise("other", "Leg Press"))
        assertEquals(100.0, pr("Squat", exercises, s), delta)
    }

    @Test
    fun pr_combinesAllExercisesMatchingTheQuery() {
        val s = session(
            exercises = arrayOf(
                performed("flat", set(1, 100.0)),
                performed("incline", set(1, 110.0)),
            )
        )
        val exercises = listOf(exercise("flat", "Bench Press"), exercise("incline", "Incline Bench Press"))
        assertEquals(110.0, pr("Bench Press", exercises, s), delta)
    }

    // =====================================================================
    // getPreviousSet
    // =====================================================================

    @Test
    fun previousSet_noSessions_isNull() {
        assertNull(vm().getPreviousSet("e1", 0))
    }

    @Test
    fun previousSet_exerciseNeverPerformed_isNull() {
        val v = vm(sessions = listOf(session(exercises = arrayOf(performed("other", set(5, 50.0))))))
        assertNull(v.getPreviousSet("e1", 0))
    }

    @Test
    fun previousSet_returnsTheSetAtTheIndexFromTheLatestSession() {
        val older = session("old", exercises = arrayOf(performed("e1", set(5, 50.0), set(5, 50.0))))
        val newer = session("new", exercises = arrayOf(performed("e1", set(8, 60.0), set(6, 65.0))))
        val v = vm(sessions = listOf(older, newer))

        val set = v.getPreviousSet("e1", 1)
        assertNotNull(set)
        assertEquals(65.0, set!!.weight!!, delta)
    }

    @Test
    fun previousSet_skipsLatestSessionsThatLackTheExercise() {
        val older = session("old", exercises = arrayOf(performed("e1", set(5, 50.0))))
        val newer = session("new", exercises = arrayOf(performed("other", set(5, 99.0))))
        val v = vm(sessions = listOf(older, newer))

        assertEquals(50.0, v.getPreviousSet("e1", 0)!!.weight!!, delta)
    }

    @Test
    fun previousSet_indexBeyondTheSets_isNull() {
        // Current behaviour: it does not fall back to an older session.
        val older = session("old", exercises = arrayOf(performed("e1", set(5, 50.0), set(5, 50.0), set(5, 50.0))))
        val newer = session("new", exercises = arrayOf(performed("e1", set(5, 60.0))))
        val v = vm(sessions = listOf(older, newer))

        assertNull(v.getPreviousSet("e1", 2))
    }

    // =====================================================================
    // Ideal proportions
    // =====================================================================

    private val wrist = 10.0

    @Test
    fun ideals_female_usesWristMultipliers() {
        val r = vm().getIdealProportions(wrist, "female")
        assertEquals(setOf("Shoulders", "Glutes", "Waist", "Bicep", "Forearm", "Thigh", "Calf"), r.keys)
        assertEquals(60.0, r.getValue("Shoulders"), delta)
        assertEquals(58.0, r.getValue("Glutes"), delta)
        assertEquals(38.0, r.getValue("Waist"), delta)
        assertEquals(19.0, r.getValue("Bicep"), delta)
        assertEquals(15.0, r.getValue("Forearm"), delta)
        assertEquals(33.0, r.getValue("Thigh"), delta)
        assertEquals(21.0, r.getValue("Calf"), delta)
    }

    @Test
    fun ideals_femaleSoftAndUppercase_areTreatedAsFemale() {
        val female = vm().getIdealProportions(wrist, "female")
        assertEquals(female, vm().getIdealProportions(wrist, "female_soft"))
        assertEquals(female, vm().getIdealProportions(wrist, "FEMALE"))
    }

    @Test
    fun ideals_male_usesChestAnchoredFormula() {
        val r = vm().getIdealProportions(wrist, "male")
        assertEquals(setOf("Chest", "Neck", "Shoulders", "Waist", "Hips", "Bicep", "Forearm", "Thigh", "Calf"), r.keys)
        val chest = 65.0
        assertEquals(chest, r.getValue("Chest"), delta)
        assertEquals(chest * 0.37, r.getValue("Neck"), delta)
        assertEquals(chest * 1.18, r.getValue("Shoulders"), delta)
        assertEquals(chest * 0.70, r.getValue("Waist"), delta)
        assertEquals(chest * 0.85, r.getValue("Hips"), delta)
        assertEquals(chest * 0.36, r.getValue("Bicep"), delta)
        assertEquals(chest * 0.29, r.getValue("Forearm"), delta)
        assertEquals(chest * 0.53, r.getValue("Thigh"), delta)
        assertEquals(chest * 0.34, r.getValue("Calf"), delta)
    }

    @Test
    fun ideals_unspecifiedOrUnknownGender_usesTheMaleFormula() {
        val male = vm().getIdealProportions(wrist, "male")
        assertEquals(male, vm().getIdealProportions(wrist, "unspecified"))
        assertEquals(male, vm().getIdealProportions(wrist, ""))
    }

    @Test
    fun ideals_scaleLinearlyWithWristSize() {
        val small = vm().getIdealProportions(10.0, "male").getValue("Chest")
        val big = vm().getIdealProportions(20.0, "male").getValue("Chest")
        assertEquals(small * 2, big, delta)
    }
}