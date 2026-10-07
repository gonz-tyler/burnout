package com.burnout.app.domain

import com.burnout.app.domain.service.GoalChange
import com.burnout.app.domain.service.StreakService
import com.burnout.app.domain.service.StreakState
import org.junit.Assert.assertEquals
import org.junit.Test
import java.time.LocalDate

class StreakServiceTest {

    private val streakService = StreakService()

    @Test
    fun setGoalInitializesOrUpdatesGoal() {
        val initialState = StreakState()
        val today = LocalDate.of(2026, 10, 5) // Monday
        val updated = streakService.setGoal(initialState, 4, today)

        assertEquals(1, updated.goalHistory.size)
        assertEquals(4, updated.goalHistory[0].goal)

        val updated2 = streakService.setGoal(updated, 5, today)
        assertEquals(2, updated2.goalHistory.size)
        assertEquals(5, updated2.goalHistory.last().goal)
    }

    @Test
    fun evaluateCalculatesStreakWithMetGoals() {
        val today = LocalDate.of(2026, 10, 6) // Monday
        val state = StreakState(
            goalHistory = listOf(GoalChange(LocalDate.of(2025, 1, 1), 2))
        )
        // Week of Sep 28 - Oct 4, 2026: 2 workout days
        val workoutDays = setOf(
            LocalDate.of(2026, 9, 29), // Tuesday
            LocalDate.of(2026, 10, 1)  // Thursday
        )

        val result = streakService.evaluate(state, workoutDays, today)
        assertEquals(2, result.streak)
    }

    @Test
    fun evaluateBreaksStreakWhenGoalNotMet() {
        val today = LocalDate.of(2026, 10, 6) // Monday (current week)
        val state = StreakState(
            goalHistory = listOf(GoalChange(LocalDate.of(2025, 1, 1), 3))
        )
        // Past week (Sep 21 - Sep 27, 2026): only 2 workout days (goal is 3)
        val workoutDays = setOf(
            LocalDate.of(2026, 9, 22),
            LocalDate.of(2026, 9, 24)
        )

        val result = streakService.evaluate(state, workoutDays, today)
        assertEquals(0, result.streak)
    }
}
