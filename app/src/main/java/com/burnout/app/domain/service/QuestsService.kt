package com.burnout.app.domain.service

import com.burnout.app.R
import com.burnout.app.data.local.entity.WorkoutSession
import com.burnout.app.ui.viewmodel.WorkoutUiState
import com.burnout.app.util.UiText
import com.burnout.app.util.UnitSystem
import com.burnout.app.util.WeightConverter
import java.util.*

data class Quest(
    val id: String,
    val title: UiText,
    val description: UiText,
    val requirement: UiText,
    val rewardAsset: String,
    val isCompleted: Boolean,
    val progress: Float
)

object QuestsService {

    fun checkWeeklyQuests(
        uiState: WorkoutUiState,
        sessions: List<WorkoutSession>,
        weeklyGoal: Int
    ): List<Quest> {
        val unitSystem = if (uiState.unitSystem == "imperial") UnitSystem.IMPERIAL else UnitSystem.METRIC
        val unitString = if (uiState.unitSystem == "metric") "kg" else "lbs"
        val now = Calendar.getInstance()
        val currentWeekSessions = sessions.filter { session ->
            val cal = Calendar.getInstance().apply {
                timeInMillis = session.dateCompleted
                firstDayOfWeek = Calendar.MONDAY
            }
            cal.get(Calendar.YEAR) == now.get(Calendar.YEAR) &&
                    cal.get(Calendar.WEEK_OF_YEAR) == now.get(Calendar.WEEK_OF_YEAR)
        }

        val daysWorkedOut = currentWeekSessions.map { s ->
            Calendar.getInstance().apply { timeInMillis = s.dateCompleted }.get(Calendar.DAY_OF_YEAR)
        }.distinct().size

        val weekVolume = currentWeekSessions.sumOf { session ->
            session.performedExercises.sumOf { exercise ->
                exercise.sets.sumOf { set ->
                    (set.weight ?: 0.0) * (set.reps ?: 0)
                }
            }
        }

        return listOf(
            Quest(
                id = "q1",
                title = UiText.StringResource(R.string.q1_title),
                description = UiText.StringResource(R.string.q1_description),
                requirement = UiText.StringResource(R.string.q1_requirement, weeklyGoal),
                rewardAsset = "crown_reward.png",
                isCompleted = daysWorkedOut >= weeklyGoal,
                progress = if (weeklyGoal > 0) (daysWorkedOut.toFloat() / weeklyGoal).coerceIn(0f, 1f) else 1f
            ),
            Quest(
                id = "q2",
                title = UiText.StringResource(R.string.q2_title),
                description = UiText.StringResource(R.string.q2_description),
                requirement = UiText.StringResource(R.string.q2_requirement, WeightConverter.displayWeight(5000.0, unitSystem), unitString),
                rewardAsset = "weight_reward.png",
                isCompleted = weekVolume >= 5000.0,
                progress = (weekVolume.toFloat() / 5000f).coerceIn(0f, 1f)
            ),
            Quest(
                id = "q3",
                title = UiText.StringResource(R.string.q3_title),
                description = UiText.StringResource(R.string.q3_description),
                requirement = UiText.StringResource(R.string.q3_requirement),
                rewardAsset = "sun_reward.png",
                isCompleted = currentWeekSessions.any { s ->
                    Calendar.getInstance().apply { timeInMillis = s.dateCompleted }.get(Calendar.HOUR_OF_DAY) < 10
                },
                progress = if (currentWeekSessions.any { s ->
                        Calendar.getInstance().apply { timeInMillis = s.dateCompleted }.get(Calendar.HOUR_OF_DAY) < 10
                    }) 1f else 0f
            )
        )
    }
}
