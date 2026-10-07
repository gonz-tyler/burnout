package com.burnout.app.domain.service

import androidx.compose.ui.res.stringResource
import com.burnout.app.R
import com.burnout.app.data.local.entity.Exercise
import com.burnout.app.data.local.entity.SetType
import com.burnout.app.data.local.entity.WorkoutSession
import java.util.Calendar
import java.util.concurrent.TimeUnit

/**
 * Direct port of muscle_analysis_service.dart. Computes 0.0-1.0 normalized
 * training-volume intensity per muscle group, over WEEK / MONTH / ALL TIME
 * windows, plus push/pull imbalance warnings for the dashboard.
 */
object MuscleAnalysisService {

    // Maps specific muscle names from exercise data to general SVG path IDs.
    private val muscleMapping: Map<String, String> = mapOf(
        // Chest
        "Pectoralis Major" to "Chest",
        "Pectoralis Major (Upper)" to "Chest",
        // Back
        "Latissimus Dorsi" to "Lats",
        "Trapezius" to "Trapezius",
        "Rhomboids" to "Trapezius",
        "Erector Spinae" to "Lower_Back",
        "Rotator Cuff" to "Upper_Back",
        // Shoulders
        "Deltoid (Anterior)" to "Delts",
        "Deltoid (Lateral)" to "Delts",
        "Deltoid (General)" to "Delts",
        "Deltoid (Posterior)" to "Deltoids_Posterior",
        // Arms
        "Biceps Brachii" to "Biceps",
        "Triceps Brachii" to "Triceps",
        "Forearm Muscles" to "Forearms",
        "Forearm Flexors" to "Forearms",
        "Forearm Extensors" to "Forearms_Back",
        // Legs
        "Quadriceps" to "Quads",
        "Hamstrings" to "Hamstrings",
        "Adductors" to "Adductors",
        "Calves" to "Calves",
        "Gastrocnemius" to "Calves",
        "Soleus" to "Calves",
        "Tibialis Anterior" to "Tibialis",
        "Abductors" to "Abductors",
        // Glutes
        "Gluteus Maximus" to "Glutes",
        "Gluteus Medius" to "Glutes",
        // Core
        "Rectus Abdominis" to "Abs",
        "Obliques" to "Obliques",
        "Hip Flexors" to "Abs",
    )
    /** Weighted sets (sets × muscle share) per week that count as "fully worked" for each diagram group. */
    private val fullIntensitySets = mapOf(
        // Chest
        "Chest" to 10.0,
        // Back
        "Lats" to 10.0,
        "Trapezius" to 8.0,          // traps + rhomboids
        "Lower_Back" to 6.0,
        "Upper_Back" to 4.0,         // rotator cuff
        // Shoulders
        "Delts" to 10.0,             // anterior + lateral + general merge here
        "Deltoids_Posterior" to 6.0,
        // Arms
        "Biceps" to 8.0,
        "Triceps" to 8.0,
        "Forearms" to 4.0,
        "Forearms_Back" to 3.0,
        // Legs
        "Quads" to 10.0,
        "Hamstrings" to 8.0,
        "Adductors" to 4.0,
        "Calves" to 8.0,
        "Tibialis" to 3.0,
        "Abductors" to 4.0,
        // Glutes
        "Glutes" to 10.0,
        // Core
        "Abs" to 8.0,                // rectus abdominis + hip flexors
        "Obliques" to 5.0,
    )
    private fun calculateIntensity(
        sessions: List<WorkoutSession>,
        allExercises: List<Exercise>,
        windowWeeks: Int
    ): Map<String, Double> {
        val setsByMuscle = mutableMapOf<String, Double>()
        val exerciseMap = allExercises.associateBy { it.id }

        for (session in sessions) {
            for (pExercise in session.performedExercises) {
                val exercise = exerciseMap[pExercise.exerciseId] ?: continue
                val setCount = pExercise.sets.count { it.setType != SetType.WARMUP }.toDouble()

                exercise.targetedMuscles.forEach { (muscleName, percentage) ->
                    val svgMuscleGroup = muscleMapping[muscleName] ?: return@forEach
                    setsByMuscle[svgMuscleGroup] =
                        (setsByMuscle[svgMuscleGroup] ?: 0.0) + setCount * percentage
                }
            }
        }

        return setsByMuscle.mapValues { (group, sets) ->
            val target = fullIntensitySets.getValue(group) * windowWeeks
            (sets / target).coerceIn(0.0, 1.0)
        }
    }

    private fun daysAgo(days: Int): Long {
        val cal = Calendar.getInstance()
        cal.add(Calendar.DAY_OF_YEAR, -days)
        return cal.timeInMillis
    }

    fun getWeeklyMuscleIntensity(
        sessions: List<WorkoutSession>,
        allExercises: List<Exercise>,
    ): Map<String, Double> {
        val cutoff = daysAgo(7)
        val recent = sessions.filter { it.dateCompleted > cutoff }
        val windowWeeks = 1
        return calculateIntensity(recent, allExercises, windowWeeks)
    }

    fun getMonthlyMuscleIntensity(
        sessions: List<WorkoutSession>,
        allExercises: List<Exercise>,
    ): Map<String, Double> {
        val cutoff = daysAgo(30)
        val recent = sessions.filter { it.dateCompleted > cutoff }
        val windowWeeks = 4
        return calculateIntensity(recent, allExercises, windowWeeks)
    }

    fun getAllTimeMuscleIntensity(
        sessions: List<WorkoutSession>,
        allExercises: List<Exercise>,
    ): Map<String, Double> {
        val windowWeeks = sessions
            .map { TimeUnit.MILLISECONDS.toDays(it.dateCompleted) / 7 }
            .distinct()
            .size
            .coerceAtLeast(1)
        return calculateIntensity(sessions, allExercises, windowWeeks)
    }

//    fun getComparativeMuscleBalance(
//        sessions: List<WorkoutSession>,
//        allExercises: List<Exercise>,
//    ): Map<String, Double> {
//        val intensity = calculateIntensity(sessions, allExercises)
//        if (intensity.isEmpty()) return emptyMap()
//
//        val pushMuscles = listOf("Chest", "Deltoids", "Triceps")
//        val pullMuscles = listOf("Lats", "Trapezius", "Biceps", "Deltoids_Posterior")
//        val legPush = listOf("Quads")
//        val legPull = listOf("Hamstrings", "Glutes")
//
//        val pushScore = pushMuscles.sumOf { intensity[it] ?: 0.0 }
//        val pullScore = pullMuscles.sumOf { intensity[it] ?: 0.0 }
//        val legPushScore = legPush.sumOf { intensity[it] ?: 0.0 }
//        val legPullScore = legPull.sumOf { intensity[it] ?: 0.0 }
//
//        val balanceMap = mutableMapOf<String, Double>()
//        pushMuscles.forEach { balanceMap[it] = pushScore }
//        pullMuscles.forEach { balanceMap[it] = pullScore }
//        legPush.forEach { balanceMap[it] = legPushScore }
//        legPull.forEach { balanceMap[it] = legPullScore }
//
//        val maxScore = balanceMap.values.maxOrNull() ?: 0.0
//        if (maxScore == 0.0) return emptyMap()
//        return balanceMap.mapValues { it.value / maxScore }
//    }

    fun getMuscleImbalanceWarnings(intensity: Map<String, Double>): List<Int> {
        val warnings = mutableListOf<Int>()
        if (intensity.isEmpty()) return warnings

        val chest = intensity["Chest"] ?: 0.0
        val back = (intensity["Lats"] ?: 0.0) + (intensity["Trapezius"] ?: 0.0) + (intensity["Upper_Back"] ?: 0.0)
        val biceps = intensity["Biceps"] ?: 0.0
        val triceps = intensity["Triceps"] ?: 0.0
        val quads = intensity["Quads"] ?: 0.0
        val hamstrings = intensity["Hamstrings"] ?: 0.0

        if (chest > back * 1.5) {
            warnings.add(R.string.push_dominant)
        }
        if (back > chest * 1.5) {
            warnings.add(R.string.pull_dominant)
        }
        if (quads > hamstrings * 1.5) {
            warnings.add(R.string.quad_dominant)
        }
        if (hamstrings > quads * 1.5) {
            warnings.add(R.string.hamstring_dominant)
        }
        if (biceps > triceps * 1.2) {
            warnings.add(R.string.bicep_dominant)
        }
        if (triceps > biceps * 1.2) {
            warnings.add(R.string.tricep_dominant)
        }

        return warnings
    }
}
