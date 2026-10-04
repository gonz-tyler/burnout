package com.burnout.app.domain.service

import com.burnout.app.data.local.entity.WorkoutSession
import java.util.*

data class Quest(
    val id: String,
    val title: String,
    val description: String,
    val requirement: String,
    val rewardAsset: String,
    val isCompleted: Boolean,
    val progress: Float
)

object QuestsService {

    fun checkWeeklyQuests(
        sessions: List<WorkoutSession>,
        weeklyGoal: Int
    ): List<Quest> {
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
                title = "Consistency King",
                description = "Hit your weekly workout goal.",
                requirement = "Complete $weeklyGoal workout days",
                rewardAsset = "crown_reward.png",
                isCompleted = daysWorkedOut >= weeklyGoal,
                progress = if (weeklyGoal > 0) (daysWorkedOut.toFloat() / weeklyGoal).coerceIn(0f, 1f) else 1f
            ),
            Quest(
                id = "q2",
                title = "Volume Warrior",
                description = "Lift a significant amount of weight this week.",
                requirement = "Lift 5,000 kg total this week",
                rewardAsset = "weight_reward.png",
                isCompleted = weekVolume >= 5000.0,
                progress = (weekVolume.toFloat() / 5000f).coerceIn(0f, 1f)
            ),
            Quest(
                id = "q3",
                title = "Early Bird",
                description = "Get a workout in before 10 AM.",
                requirement = "1 workout before 10:00",
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
