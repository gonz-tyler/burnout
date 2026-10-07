package com.burnout.app.domain.service

import com.burnout.app.data.local.entity.WorkoutSession
import java.time.DayOfWeek
import java.time.Instant
import java.time.ZonedDateTime
import java.time.temporal.TemporalAdjusters

/** Pure domain logic: no R, no UiText, no WorkoutUiState. */

enum class QuestId { WEEKLY_GOAL, WEEKLY_VOLUME, EARLY_BIRD }

data class QuestProgress(
    val id: QuestId,
    val isCompleted: Boolean,
    val progress: Float, // 0.0f to 1.0f
)

object QuestsService {

    /** In the stored weight unit (kg). The UI converts it for display. */
    const val WEEKLY_VOLUME_TARGET = 5000.0
    const val EARLY_BIRD_BEFORE_HOUR = 10

    fun evaluate(
        sessions: List<WorkoutSession>,
        weeklyGoal: Int,
        now: ZonedDateTime = ZonedDateTime.now(),
    ): List<QuestProgress> {
        val weekStart = now.toLocalDate().with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY))
        val nextWeekStart = weekStart.plusWeeks(1)

        val thisWeek = sessions
            .map { it to Instant.ofEpochMilli(it.dateCompleted).atZone(now.zone) }
            .filter { (_, time) ->
                val day = time.toLocalDate()
                !day.isBefore(weekStart) && day.isBefore(nextWeekStart)
            }

        val daysWorkedOut = thisWeek.map { (_, time) -> time.toLocalDate() }.distinct().size
        val weekVolume = thisWeek.sumOf { (session, _) -> session.volume() }
        val workedOutEarly = thisWeek.any { (_, time) -> time.hour < EARLY_BIRD_BEFORE_HOUR }

        return listOf(
            QuestProgress(
                id = QuestId.WEEKLY_GOAL,
                isCompleted = daysWorkedOut >= weeklyGoal,
                progress = if (weeklyGoal > 0) (daysWorkedOut.toFloat() / weeklyGoal).coerceIn(0f, 1f) else 1f,
            ),
            QuestProgress(
                id = QuestId.WEEKLY_VOLUME,
                isCompleted = weekVolume >= WEEKLY_VOLUME_TARGET,
                progress = (weekVolume / WEEKLY_VOLUME_TARGET).toFloat().coerceIn(0f, 1f),
            ),
            QuestProgress(
                id = QuestId.EARLY_BIRD,
                isCompleted = workedOutEarly,
                progress = if (workedOutEarly) 1f else 0f,
            ),
        )
    }
}

/** Shared by quests, labors and WorkoutUiState.totalVolume so the formula lives in one place. */
fun WorkoutSession.volume(): Double =
    performedExercises.sumOf { exercise ->
        exercise.sets.sumOf { set -> (set.weight ?: 0.0) * (set.reps ?: 0) }
    }