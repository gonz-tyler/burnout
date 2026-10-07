package com.burnout.app.domain

import com.burnout.app.R
import com.burnout.app.data.local.entity.Exercise
import com.burnout.app.data.local.entity.PerformedExercise
import com.burnout.app.data.local.entity.PerformedSet
import com.burnout.app.data.local.entity.SetType
import com.burnout.app.data.local.entity.WorkoutSession
import com.burnout.app.domain.service.MuscleAnalysisService
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class MuscleAnalysisServiceTest {

    private val delta = 1e-9
    private val dayMillis = 86_400_000L

    // ---------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------

    private fun exercise(
        id: String = "ex1",
        muscles: Map<String, Double>,
    ) = Exercise(
        id = id,
        name = "Test Exercise",
        muscleGroup = "Test",
        instructions = "",
        equipment = "None",
        targetedMuscles = muscles
    )

    private fun performed(
        exerciseId: String = "ex1",
        normalSets: Int = 0,
        warmupSets: Int = 0,
    ) = PerformedExercise(
        exerciseId = exerciseId,
        sets = List(warmupSets) { PerformedSet(SetType.WARMUP, 10, 20.0) } +
                List(normalSets) { PerformedSet(SetType.NORMAL, 10, 100.0) }
    )

    private fun session(
        id: String = "s1",
        dateCompleted: Long = System.currentTimeMillis(),
        vararg exercises: PerformedExercise,
    ) = WorkoutSession(
        id = id,
        dateCompleted = dateCompleted,
        durationInMinutes = 30,
        performedExercises = exercises.toList()
    )

    private fun daysAgoMillis(days: Int): Long = System.currentTimeMillis() - days * dayMillis

    private val bench = exercise(muscles = mapOf("Pectoralis Major" to 1.0))

    // ---------------------------------------------------------------------
    // Weekly: basic calculation + normalisation
    // ---------------------------------------------------------------------

    @Test
    fun weekly_basicCalculation_normalisesAgainstWeeklyTarget() {
        // 5 sets / 10 target sets for Chest = 0.5
        val s = session(exercises = arrayOf(performed(normalSets = 5)))
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(bench))
        assertEquals(0.5, result["Chest"]!!, delta)
    }

    @Test
    fun weekly_valueIsCappedAtOne() {
        val s = session(exercises = arrayOf(performed(normalSets = 30)))
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(bench))
        assertEquals(1.0, result["Chest"]!!, delta)
    }

    @Test
    fun weekly_noSessions_returnsEmptyMap() {
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(emptyList(), listOf(bench))
        assertTrue(result.isEmpty())
    }

    @Test
    fun weekly_sessionWithNoPerformedExercises_returnsEmptyMap() {
        val s = session()
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(bench))
        assertTrue(result.isEmpty())
    }

    // ---------------------------------------------------------------------
    // Weekly: date window filter (both branches of `dateCompleted > cutoff`)
    // ---------------------------------------------------------------------

    @Test
    fun weekly_includesSessionInsideWindow() {
        val s = session(dateCompleted = daysAgoMillis(6), exercises = arrayOf(performed(normalSets = 5)))
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(bench))
        assertEquals(0.5, result["Chest"]!!, delta)
    }

    @Test
    fun weekly_excludesSessionOutsideWindow() {
        val s = session(dateCompleted = daysAgoMillis(8), exercises = arrayOf(performed(normalSets = 5)))
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(bench))
        assertTrue(result.isEmpty())
    }

    @Test
    fun weekly_mixedSessions_onlyCountsRecentOnes() {
        val recent = session(id = "recent", exercises = arrayOf(performed(normalSets = 5)))
        val old = session(
            id = "old",
            dateCompleted = daysAgoMillis(8),
            exercises = arrayOf(performed(normalSets = 5))
        )
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(recent, old), listOf(bench))
        assertEquals(0.5, result["Chest"]!!, delta)
    }

    // ---------------------------------------------------------------------
    // Monthly
    // ---------------------------------------------------------------------

    @Test
    fun monthly_normalisesAgainstFourWeekTarget() {
        // 20 sets / (10 * 4 weeks) = 0.5
        val s = session(exercises = arrayOf(performed(normalSets = 20)))
        val result = MuscleAnalysisService.getMonthlyMuscleIntensity(listOf(s), listOf(bench))
        assertEquals(0.5, result["Chest"]!!, delta)
    }

    @Test
    fun monthly_valueIsCappedAtOne() {
        val s = session(exercises = arrayOf(performed(normalSets = 100)))
        val result = MuscleAnalysisService.getMonthlyMuscleIntensity(listOf(s), listOf(bench))
        assertEquals(1.0, result["Chest"]!!, delta)
    }

    @Test
    fun monthly_includesSessionInsideWindow() {
        val s = session(dateCompleted = daysAgoMillis(29), exercises = arrayOf(performed(normalSets = 20)))
        val result = MuscleAnalysisService.getMonthlyMuscleIntensity(listOf(s), listOf(bench))
        assertEquals(0.5, result["Chest"]!!, delta)
    }

    @Test
    fun monthly_excludesSessionOutsideWindow() {
        val s = session(dateCompleted = daysAgoMillis(31), exercises = arrayOf(performed(normalSets = 20)))
        val result = MuscleAnalysisService.getMonthlyMuscleIntensity(listOf(s), listOf(bench))
        assertTrue(result.isEmpty())
    }

    @Test
    fun monthly_includesSessionThatWeeklyWouldExclude() {
        val s = session(dateCompleted = daysAgoMillis(15), exercises = arrayOf(performed(normalSets = 20)))
        assertTrue(MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(bench)).isEmpty())
        assertEquals(
            0.5,
            MuscleAnalysisService.getMonthlyMuscleIntensity(listOf(s), listOf(bench))["Chest"]!!,
            delta
        )
    }

    // ---------------------------------------------------------------------
    // All time (window = number of distinct calendar weeks, min 1)
    // ---------------------------------------------------------------------

    @Test
    fun allTime_noSessions_returnsEmptyMap() {
        // windowWeeks == 0 is coerced to 1; result is empty because there is no data.
        val result = MuscleAnalysisService.getAllTimeMuscleIntensity(emptyList(), listOf(bench))
        assertTrue(result.isEmpty())
    }

    @Test
    fun allTime_singleSession_usesOneWeekWindow() {
        val s = session(dateCompleted = 700 * dayMillis, exercises = arrayOf(performed(normalSets = 5)))
        val result = MuscleAnalysisService.getAllTimeMuscleIntensity(listOf(s), listOf(bench))
        assertEquals(0.5, result["Chest"]!!, delta)
    }

    @Test
    fun allTime_sessionsInSameWeek_shareOneWindow() {
        // Day 700 and 703 both fall in week 100 -> window = 1 week -> 10 / 10 = 1.0
        val a = session(id = "a", dateCompleted = 700 * dayMillis, exercises = arrayOf(performed(normalSets = 5)))
        val b = session(id = "b", dateCompleted = 703 * dayMillis, exercises = arrayOf(performed(normalSets = 5)))
        val result = MuscleAnalysisService.getAllTimeMuscleIntensity(listOf(a, b), listOf(bench))
        assertEquals(1.0, result["Chest"]!!, delta)
    }

    @Test
    fun allTime_sessionsInDifferentWeeks_scaleWindow() {
        // Day 700 (week 100) and 707 (week 101) -> window = 2 weeks -> 10 / 20 = 0.5
        val a = session(id = "a", dateCompleted = 700 * dayMillis, exercises = arrayOf(performed(normalSets = 5)))
        val b = session(id = "b", dateCompleted = 707 * dayMillis, exercises = arrayOf(performed(normalSets = 5)))
        val result = MuscleAnalysisService.getAllTimeMuscleIntensity(listOf(a, b), listOf(bench))
        assertEquals(0.5, result["Chest"]!!, delta)
    }

    @Test
    fun allTime_doesNotFilterOldSessions() {
        val s = session(dateCompleted = 0L, exercises = arrayOf(performed(normalSets = 5)))
        val result = MuscleAnalysisService.getAllTimeMuscleIntensity(listOf(s), listOf(bench))
        assertEquals(0.5, result["Chest"]!!, delta)
    }

    @Test
    fun allTime_valueIsCappedAtOne() {
        val s = session(dateCompleted = 700 * dayMillis, exercises = arrayOf(performed(normalSets = 50)))
        val result = MuscleAnalysisService.getAllTimeMuscleIntensity(listOf(s), listOf(bench))
        assertEquals(1.0, result["Chest"]!!, delta)
    }

    // ---------------------------------------------------------------------
    // calculateIntensity internals (exercised via the public API)
    // ---------------------------------------------------------------------

    @Test
    fun unknownExerciseId_isSkipped() {
        val s = session(
            exercises = arrayOf(
                performed(exerciseId = "does-not-exist", normalSets = 5),
                performed(exerciseId = "ex1", normalSets = 5),
            )
        )
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(bench))
        assertEquals(setOf("Chest"), result.keys)
        assertEquals(0.5, result["Chest"]!!, delta)
    }

    @Test
    fun unknownExerciseId_only_returnsEmptyMap() {
        val s = session(exercises = arrayOf(performed(exerciseId = "nope", normalSets = 5)))
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(bench))
        assertTrue(result.isEmpty())
    }

    @Test
    fun unmappedMuscleName_isIgnored() {
        val ex = exercise(muscles = mapOf("Made Up Muscle" to 1.0, "Pectoralis Major" to 1.0))
        val s = session(exercises = arrayOf(performed(normalSets = 5)))
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(ex))
        assertEquals(setOf("Chest"), result.keys)
    }

    @Test
    fun onlyUnmappedMuscles_returnsEmptyMap() {
        val ex = exercise(muscles = mapOf("Made Up Muscle" to 1.0))
        val s = session(exercises = arrayOf(performed(normalSets = 5)))
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(ex))
        assertTrue(result.isEmpty())
    }

    @Test
    fun warmupSets_areExcludedFromVolume() {
        // 3 warmup + 5 working -> only 5 count -> 0.5
        val s = session(exercises = arrayOf(performed(normalSets = 5, warmupSets = 3)))
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(bench))
        assertEquals(0.5, result["Chest"]!!, delta)
    }

    @Test
    fun onlyWarmupSets_yieldZeroIntensity() {
        val s = session(exercises = arrayOf(performed(normalSets = 0, warmupSets = 4)))
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(bench))
        assertEquals(0.0, result["Chest"]!!, delta)
    }

    @Test
    fun exerciseWithNoSets_yieldsZeroIntensity() {
        val s = session(exercises = arrayOf(performed(normalSets = 0, warmupSets = 0)))
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(bench))
        assertEquals(0.0, result["Chest"]!!, delta)
    }

    @Test
    fun muscleShare_isAppliedToSetCount() {
        // 10 sets: 60% chest (6 / 10 = 0.6), 40% triceps (4 / 8 = 0.5)
        val ex = exercise(muscles = mapOf("Pectoralis Major" to 0.6, "Triceps Brachii" to 0.4))
        val s = session(exercises = arrayOf(performed(normalSets = 10)))
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(ex))
        assertEquals(0.6, result["Chest"]!!, delta)
        assertEquals(0.5, result["Triceps"]!!, delta)
    }

    @Test
    fun multipleMusclesMappingToSameGroup_accumulate() {
        // Both map to "Chest": 2.5 + 2.5 = 5 sets -> 0.5
        val ex = exercise(muscles = mapOf("Pectoralis Major" to 0.5, "Pectoralis Major (Upper)" to 0.5))
        val s = session(exercises = arrayOf(performed(normalSets = 5)))
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(ex))
        assertEquals(0.5, result["Chest"]!!, delta)
    }

    @Test
    fun sameGroupAcrossExercisesAndSessions_accumulates() {
        val ex2 = exercise(id = "ex2", muscles = mapOf("Pectoralis Major (Upper)" to 1.0))
        val s1 = session(id = "s1", exercises = arrayOf(performed("ex1", normalSets = 3)))
        val s2 = session(id = "s2", exercises = arrayOf(performed("ex2", normalSets = 2)))
        val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s1, s2), listOf(bench, ex2))
        assertEquals(0.5, result["Chest"]!!, delta)
    }

    // ---------------------------------------------------------------------
    // Full mapping table: every muscle name -> SVG group -> weekly target
    // ---------------------------------------------------------------------

    @Test
    fun everyMuscleMapping_resolvesToExpectedGroupAndTarget() {
        // Triple(muscle name, SVG group, full-intensity sets per week)
        val expectations = listOf(
            Triple("Pectoralis Major", "Chest", 10.0),
            Triple("Pectoralis Major (Upper)", "Chest", 10.0),
            Triple("Latissimus Dorsi", "Lats", 10.0),
            Triple("Trapezius", "Trapezius", 8.0),
            Triple("Rhomboids", "Trapezius", 8.0),
            Triple("Erector Spinae", "Lower_Back", 6.0),
            Triple("Rotator Cuff", "Upper_Back", 4.0),
            Triple("Deltoid (Anterior)", "Delts", 10.0),
            Triple("Deltoid (Lateral)", "Delts", 10.0),
            Triple("Deltoid (General)", "Delts", 10.0),
            Triple("Deltoid (Posterior)", "Deltoids_Posterior", 6.0),
            Triple("Biceps Brachii", "Biceps", 8.0),
            Triple("Triceps Brachii", "Triceps", 8.0),
            Triple("Forearm Muscles", "Forearms", 4.0),
            Triple("Forearm Flexors", "Forearms", 4.0),
            Triple("Forearm Extensors", "Forearms_Back", 3.0),
            Triple("Quadriceps", "Quads", 10.0),
            Triple("Hamstrings", "Hamstrings", 8.0),
            Triple("Adductors", "Adductors", 4.0),
            Triple("Calves", "Calves", 8.0),
            Triple("Gastrocnemius", "Calves", 8.0),
            Triple("Soleus", "Calves", 8.0),
            Triple("Tibialis Anterior", "Tibialis", 3.0),
            Triple("Abductors", "Abductors", 4.0),
            Triple("Gluteus Maximus", "Glutes", 10.0),
            Triple("Gluteus Medius", "Glutes", 10.0),
            Triple("Rectus Abdominis", "Abs", 8.0),
            Triple("Obliques", "Obliques", 5.0),
            Triple("Hip Flexors", "Abs", 8.0),
        )

        for ((muscle, group, target) in expectations) {
            val ex = exercise(muscles = mapOf(muscle to 1.0))
            val s = session(exercises = arrayOf(performed(normalSets = 1)))
            val result = MuscleAnalysisService.getWeeklyMuscleIntensity(listOf(s), listOf(ex))

            assertEquals("Group set for '$muscle'", setOf(group), result.keys)
            assertEquals("Intensity for '$muscle'", 1.0 / target, result[group]!!, delta)
        }
    }

    // ---------------------------------------------------------------------
    // Imbalance warnings
    // ---------------------------------------------------------------------

    @Test
    fun warnings_emptyIntensity_returnsEmptyList() {
        assertTrue(MuscleAnalysisService.getMuscleImbalanceWarnings(emptyMap()).isEmpty())
    }

    @Test
    fun warnings_nonEmptyMapWithNoRelevantKeys_returnsEmptyList() {
        // Every lookup falls back to 0.0, and 0 > 0 is false everywhere.
        val warnings = MuscleAnalysisService.getMuscleImbalanceWarnings(mapOf("Glutes" to 0.5))
        assertTrue(warnings.isEmpty())
    }

    @Test
    fun warnings_balancedTraining_returnsEmptyList() {
        val intensity = mapOf(
            "Chest" to 0.5,
            "Lats" to 0.5,
            "Quads" to 0.5,
            "Hamstrings" to 0.5,
            "Biceps" to 0.5,
            "Triceps" to 0.5,
        )
        assertTrue(MuscleAnalysisService.getMuscleImbalanceWarnings(intensity).isEmpty())
    }

    @Test
    fun warnings_pushDominant() {
        val intensity = mapOf("Chest" to 0.9, "Lats" to 0.3)
        assertEquals(
            listOf(R.string.push_dominant),
            MuscleAnalysisService.getMuscleImbalanceWarnings(intensity)
        )
    }

    @Test
    fun warnings_pushDominant_onlyChestPresent() {
        // Back components are all missing -> back = 0
        val intensity = mapOf("Chest" to 0.4)
        assertEquals(
            listOf(R.string.push_dominant),
            MuscleAnalysisService.getMuscleImbalanceWarnings(intensity)
        )
    }

    @Test
    fun warnings_pullDominant() {
        val intensity = mapOf("Chest" to 0.2, "Lats" to 0.9)
        assertEquals(
            listOf(R.string.pull_dominant),
            MuscleAnalysisService.getMuscleImbalanceWarnings(intensity)
        )
    }

    @Test
    fun warnings_backIsSumOfLatsTrapeziusAndUpperBack() {
        // back = 0.2 + 0.2 + 0.2 = 0.6 > 0.3 * 1.5 = 0.45 -> pull dominant.
        // Each part alone (0.2) would NOT trigger it.
        val intensity = mapOf(
            "Chest" to 0.3,
            "Lats" to 0.2,
            "Trapezius" to 0.2,
            "Upper_Back" to 0.2,
        )
        assertEquals(
            listOf(R.string.pull_dominant),
            MuscleAnalysisService.getMuscleImbalanceWarnings(intensity)
        )
    }

    @Test
    fun warnings_pushPullExactlyAtThreshold_noWarning() {
        // 0.75 > 0.5 * 1.5 (= 0.75) is false; same in reverse.
        val push = mapOf("Chest" to 0.75, "Lats" to 0.5)
        val pull = mapOf("Chest" to 0.5, "Lats" to 0.75)
        assertFalse(MuscleAnalysisService.getMuscleImbalanceWarnings(push).contains(R.string.push_dominant))
        assertFalse(MuscleAnalysisService.getMuscleImbalanceWarnings(pull).contains(R.string.pull_dominant))
    }

    @Test
    fun warnings_quadDominant() {
        val intensity = mapOf("Quads" to 0.9, "Hamstrings" to 0.3)
        assertEquals(
            listOf(R.string.quad_dominant),
            MuscleAnalysisService.getMuscleImbalanceWarnings(intensity)
        )
    }

    @Test
    fun warnings_hamstringDominant() {
        val intensity = mapOf("Quads" to 0.3, "Hamstrings" to 0.9)
        assertEquals(
            listOf(R.string.hamstring_dominant),
            MuscleAnalysisService.getMuscleImbalanceWarnings(intensity)
        )
    }

    @Test
    fun warnings_quadHamstringExactlyAtThreshold_noWarning() {
        val quad = mapOf("Quads" to 0.75, "Hamstrings" to 0.5)
        val ham = mapOf("Quads" to 0.5, "Hamstrings" to 0.75)
        assertFalse(MuscleAnalysisService.getMuscleImbalanceWarnings(quad).contains(R.string.quad_dominant))
        assertFalse(MuscleAnalysisService.getMuscleImbalanceWarnings(ham).contains(R.string.hamstring_dominant))
    }

    @Test
    fun warnings_bicepDominant() {
        val intensity = mapOf("Biceps" to 0.6, "Triceps" to 0.4)
        assertEquals(
            listOf(R.string.bicep_dominant),
            MuscleAnalysisService.getMuscleImbalanceWarnings(intensity)
        )
    }

    @Test
    fun warnings_tricepDominant() {
        val intensity = mapOf("Biceps" to 0.4, "Triceps" to 0.6)
        assertEquals(
            listOf(R.string.tricep_dominant),
            MuscleAnalysisService.getMuscleImbalanceWarnings(intensity)
        )
    }

    @Test
    fun warnings_armsExactlyAtThreshold_noWarning() {
        // 1.2 > 1.0 * 1.2 is false; same in reverse.
        val bi = mapOf("Biceps" to 1.2, "Triceps" to 1.0)
        val tri = mapOf("Biceps" to 1.0, "Triceps" to 1.2)
        assertFalse(MuscleAnalysisService.getMuscleImbalanceWarnings(bi).contains(R.string.bicep_dominant))
        assertFalse(MuscleAnalysisService.getMuscleImbalanceWarnings(tri).contains(R.string.tricep_dominant))
    }

    @Test
    fun warnings_multipleWarnings_areReturnedInOrder() {
        val intensity = mapOf(
            "Chest" to 0.9,
            "Lats" to 0.3,
            "Quads" to 0.8,
            "Hamstrings" to 0.2,
            "Biceps" to 0.6,
            "Triceps" to 0.2,
        )
        assertEquals(
            listOf(R.string.push_dominant, R.string.quad_dominant, R.string.bicep_dominant),
            MuscleAnalysisService.getMuscleImbalanceWarnings(intensity)
        )
    }

    @Test
    fun warnings_oppositeSetOfWarnings_areReturnedInOrder() {
        val intensity = mapOf(
            "Chest" to 0.2,
            "Lats" to 0.9,
            "Quads" to 0.2,
            "Hamstrings" to 0.8,
            "Biceps" to 0.2,
            "Triceps" to 0.6,
        )
        assertEquals(
            listOf(R.string.pull_dominant, R.string.hamstring_dominant, R.string.tricep_dominant),
            MuscleAnalysisService.getMuscleImbalanceWarnings(intensity)
        )
    }
}