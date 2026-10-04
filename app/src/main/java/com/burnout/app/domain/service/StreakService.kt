package com.burnout.app.domain.service

import java.time.DayOfWeek
import java.time.LocalDate
import java.time.temporal.TemporalAdjusters
import javax.inject.Inject

data class GoalChange(val effectiveFrom: LocalDate, val goal: Int) // effectiveFrom is always a Monday

data class StreakState(
    val startDate: LocalDate? = null,
    val brokenThrough: LocalDate? = null,   // last day of the most recent failed week
    val goalHistory: List<GoalChange> = emptyList()
)

data class StreakResult(val streak: Int, val state: StreakState)

class StreakService @Inject constructor() {

    private fun weekStart(d: LocalDate) = d.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY))

    private fun goalFor(week: LocalDate, history: List<GoalChange>): Int =
        history.lastOrNull { it.effectiveFrom <= week }?.goal ?: history.firstOrNull()?.goal ?: 3

    /** Goal changes apply from next Monday; the very first goal applies immediately. */
    fun setGoal(state: StreakState, newGoal: Int, today: LocalDate): StreakState {
        if (state.goalHistory.isEmpty())
            return state.copy(goalHistory = listOf(GoalChange(LocalDate.of(2000, 1, 3), newGoal)))
        val next = weekStart(today).plusWeeks(1)
        return state.copy(
            goalHistory = state.goalHistory.filter { it.effectiveFrom < next } + GoalChange(next, newGoal)
        )
    }

    fun evaluate(state: StreakState, workoutDays: Set<LocalDate>, today: LocalDate): StreakResult {
        val thisWeek = weekStart(today)
        var brokenThrough = state.brokenThrough

        fun firstDayAfterBreak() = workoutDays
            .filter { brokenThrough == null || it > brokenThrough!! }
            .minOrNull()

        var runStart = state.startDate ?: firstDayAfterBreak()
        var week = runStart?.let(::weekStart)

        while (runStart != null && week != null && week < thisWeek) {
            val end = week.plusDays(6)
            val count = workoutDays.count { it >= runStart && it >= week && it <= end }
            val partialStartWeek = runStart > week
            val met = partialStartWeek && count > 0 || count >= goalFor(week, state.goalHistory)

            if (met) {
                week = week.plusWeeks(1)
            } else {
                brokenThrough = end
                runStart = firstDayAfterBreak()
                week = runStart?.let(::weekStart)
            }
        }

        val streak = runStart?.let { s -> workoutDays.count { it >= s } } ?: 0
        return StreakResult(streak, state.copy(startDate = runStart, brokenThrough = brokenThrough))
    }
}