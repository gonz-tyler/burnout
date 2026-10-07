package com.burnout.app.domain

import com.burnout.app.data.local.entity.PerformedExercise
import com.burnout.app.data.local.entity.PerformedSet
import com.burnout.app.data.local.entity.SetType
import com.burnout.app.data.local.entity.WorkoutSession
import com.burnout.app.domain.service.QuestId
import com.burnout.app.domain.service.QuestProgress
import com.burnout.app.domain.service.QuestsService
import com.burnout.app.domain.service.volume
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.ZoneId
import java.time.ZoneOffset
import java.time.ZonedDateTime

/**
 * Plain JUnit, no Robolectric. Time is injected, so every test is deterministic.
 *
 * Reference calendar: Wednesday 7 Oct 2026, so the "current week" is
 * Monday 5 Oct 00:00 -> Sunday 11 Oct 23:59 in the clock's zone.
 */
class QuestsServiceTest {

    private val fDelta = 1e-6f
    private val utc: ZoneId = ZoneOffset.UTC
    private val madrid: ZoneId = ZoneId.of("Europe/Madrid") // UTC+2 in October 2026

    // ---------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------

    private fun at(y: Int, m: Int, d: Int, h: Int = 12, min: Int = 0, zone: ZoneId = utc) =
        ZonedDateTime.of(y, m, d, h, min, 0, 0, zone)

    private val now = at(2026, 10, 7)

    private fun session(time: ZonedDateTime, volumeKg: Double = 0.0) = WorkoutSession(
        id = "s-${time.toInstant().toEpochMilli()}-$volumeKg",
        dateCompleted = time.toInstant().toEpochMilli(),
        durationInMinutes = 30,
        performedExercises = if (volumeKg > 0.0) {
            listOf(PerformedExercise("ex1", listOf(PerformedSet(SetType.NORMAL, 1, volumeKg))))
        } else emptyList()
    )

    private fun sessionWith(time: ZonedDateTime, vararg exercises: List<PerformedSet>) = WorkoutSession(
        id = "s-${time.toInstant().toEpochMilli()}",
        dateCompleted = time.toInstant().toEpochMilli(),
        durationInMinutes = 30,
        performedExercises = exercises.mapIndexed { i, sets -> PerformedExercise("ex$i", sets) }
    )

    private fun evaluate(
        sessions: List<WorkoutSession>,
        goal: Int = 3,
        clock: ZonedDateTime = now,
    ) = QuestsService.evaluate(sessions, goal, clock)

    private fun List<QuestProgress>.quest(id: QuestId) = first { it.id == id }

    private fun goalQuest(sessions: List<WorkoutSession>, goal: Int = 3, clock: ZonedDateTime = now) =
        evaluate(sessions, goal, clock).quest(QuestId.WEEKLY_GOAL)

    private fun volumeQuest(sessions: List<WorkoutSession>, clock: ZonedDateTime = now) =
        evaluate(sessions, 3, clock).quest(QuestId.WEEKLY_VOLUME)

    private fun earlyQuest(sessions: List<WorkoutSession>, clock: ZonedDateTime = now) =
        evaluate(sessions, 3, clock).quest(QuestId.EARLY_BIRD)

    // ---------------------------------------------------------------------
    // Structure and constants
    // ---------------------------------------------------------------------

    @Test
    fun returnsThreeQuestsInOrder() {
        assertEquals(
            listOf(QuestId.WEEKLY_GOAL, QuestId.WEEKLY_VOLUME, QuestId.EARLY_BIRD),
            evaluate(emptyList()).map { it.id }
        )
    }

    @Test
    fun constants_haveExpectedValues() {
        assertEquals(5000.0, QuestsService.WEEKLY_VOLUME_TARGET, 1e-9)
        assertEquals(10, QuestsService.EARLY_BIRD_BEFORE_HOUR)
    }

    @Test
    fun noSessions_nothingCompletedAndZeroProgress() {
        val result = evaluate(emptyList())
        assertTrue(result.none { it.isCompleted })
        assertTrue(result.all { it.progress == 0f })
    }

    @Test
    fun defaultClock_isUsedWhenNotProvided() {
        // Only checks the default-argument path; real time makes exact values non-deterministic.
        val result = QuestsService.evaluate(emptyList(), 3)
        assertEquals(3, result.size)
        assertTrue(result.none { it.isCompleted })
    }

    // ---------------------------------------------------------------------
    // Week window (Monday 00:00 inclusive -> next Monday 00:00 exclusive)
    // ---------------------------------------------------------------------

    @Test
    fun week_mondayMidnightIsIncluded() {
        assertTrue(goalQuest(listOf(session(at(2026, 10, 5, 0, 0))), goal = 1).isCompleted)
    }

    @Test
    fun week_sundayLastMinuteIsIncluded() {
        assertTrue(goalQuest(listOf(session(at(2026, 10, 11, 23, 59))), goal = 1).isCompleted)
    }

    @Test
    fun week_previousSundayLastMinuteIsExcluded() {
        assertFalse(goalQuest(listOf(session(at(2026, 10, 4, 23, 59))), goal = 1).isCompleted)
    }

    @Test
    fun week_nextMondayMidnightIsExcluded() {
        assertFalse(goalQuest(listOf(session(at(2026, 10, 12, 0, 0))), goal = 1).isCompleted)
    }

    @Test
    fun week_whenTodayIsMonday_weekStartsToday() {
        val monday = at(2026, 10, 5, 0, 0)
        assertTrue(goalQuest(listOf(session(monday)), goal = 1, clock = monday).isCompleted)
        assertFalse(goalQuest(listOf(session(at(2026, 10, 4, 23, 59))), goal = 1, clock = monday).isCompleted)
    }

    @Test
    fun week_whenTodayIsSunday_weekStartedOnMonday() {
        val sunday = at(2026, 10, 11, 23, 59)
        assertTrue(goalQuest(listOf(session(at(2026, 10, 5, 8, 0))), goal = 1, clock = sunday).isCompleted)
        assertFalse(goalQuest(listOf(session(at(2026, 10, 4, 8, 0))), goal = 1, clock = sunday).isCompleted)
    }

    @Test
    fun week_acrossNewYear_countsBothSidesOfTheBoundary() {
        // Friday 1 Jan 2027: the week is Mon 28 Dec 2026 -> Sun 3 Jan 2027.
        val newYear = at(2027, 1, 1)
        val sessions = listOf(
            session(at(2026, 12, 29)),
            session(at(2027, 1, 2)),
            session(at(2026, 12, 27)), // previous Sunday: excluded
        )
        val quest = goalQuest(sessions, goal = 2, clock = newYear)
        assertTrue(quest.isCompleted)
        assertEquals(1f, quest.progress, fDelta)
        // Without the two in-week days, the excluded one alone is not enough.
        assertFalse(goalQuest(listOf(session(at(2026, 12, 27))), goal = 1, clock = newYear).isCompleted)
    }

    @Test
    fun week_usesTheClockTimeZone() {
        // 22:30 UTC on Sunday 4 Oct is 00:30 on Monday 5 Oct in Madrid.
        val s = session(at(2026, 10, 4, 22, 30, zone = utc))
        assertFalse(goalQuest(listOf(s), goal = 1, clock = at(2026, 10, 7, zone = utc)).isCompleted)
        assertTrue(goalQuest(listOf(s), goal = 1, clock = at(2026, 10, 7, zone = madrid)).isCompleted)
    }

    // ---------------------------------------------------------------------
    // Quest 1: weekly goal (distinct days)
    // ---------------------------------------------------------------------

    @Test
    fun goal_partialProgress() {
        val quest = goalQuest(listOf(session(at(2026, 10, 5))), goal = 3)
        assertFalse(quest.isCompleted)
        assertEquals(1f / 3f, quest.progress, fDelta)
    }

    @Test
    fun goal_reachedExactly_isCompleted() {
        val sessions = listOf(session(at(2026, 10, 5)), session(at(2026, 10, 6)), session(at(2026, 10, 7)))
        val quest = goalQuest(sessions, goal = 3)
        assertTrue(quest.isCompleted)
        assertEquals(1f, quest.progress, fDelta)
    }

    @Test
    fun goal_exceeded_progressIsCappedAtOne() {
        val sessions = listOf(
            session(at(2026, 10, 5)), session(at(2026, 10, 6)),
            session(at(2026, 10, 7)), session(at(2026, 10, 8)),
        )
        val quest = goalQuest(sessions, goal = 2)
        assertTrue(quest.isCompleted)
        assertEquals(1f, quest.progress, fDelta)
    }

    @Test
    fun goal_multipleSessionsSameDay_countAsOneDay() {
        val sessions = listOf(session(at(2026, 10, 6, 8)), session(at(2026, 10, 6, 18)))
        val quest = goalQuest(sessions, goal = 2)
        assertFalse(quest.isCompleted)
        assertEquals(0.5f, quest.progress, fDelta)
    }

    @Test
    fun goal_zero_isCompletedWithFullProgress() {
        val quest = goalQuest(emptyList(), goal = 0)
        assertTrue(quest.isCompleted)
        assertEquals(1f, quest.progress, fDelta)
    }

    @Test
    fun goal_sessionsOutsideTheWeek_areIgnored() {
        val sessions = listOf(session(at(2026, 9, 30)), session(at(2026, 10, 14)))
        val quest = goalQuest(sessions, goal = 1)
        assertFalse(quest.isCompleted)
        assertEquals(0f, quest.progress, fDelta)
    }

    // ---------------------------------------------------------------------
    // Quest 2: weekly volume
    // ---------------------------------------------------------------------

    @Test
    fun volume_partialProgress() {
        val quest = volumeQuest(listOf(session(at(2026, 10, 6), volumeKg = 2500.0)))
        assertFalse(quest.isCompleted)
        assertEquals(0.5f, quest.progress, fDelta)
    }

    @Test
    fun volume_exactlyAtTarget_isCompleted() {
        val quest = volumeQuest(listOf(session(at(2026, 10, 6), volumeKg = 5000.0)))
        assertTrue(quest.isCompleted)
        assertEquals(1f, quest.progress, fDelta)
    }

    @Test
    fun volume_justBelowTarget_isNotCompleted() {
        val quest = volumeQuest(listOf(session(at(2026, 10, 6), volumeKg = 4999.0)))
        assertFalse(quest.isCompleted)
        assertTrue(quest.progress < 1f)
    }

    @Test
    fun volume_aboveTarget_progressIsCappedAtOne() {
        val quest = volumeQuest(listOf(session(at(2026, 10, 6), volumeKg = 20_000.0)))
        assertTrue(quest.isCompleted)
        assertEquals(1f, quest.progress, fDelta)
    }

    @Test
    fun volume_sumsAcrossSessionsInTheWeek() {
        val sessions = listOf(
            session(at(2026, 10, 5), volumeKg = 3000.0),
            session(at(2026, 10, 6), volumeKg = 2000.0),
        )
        assertTrue(volumeQuest(sessions).isCompleted)
    }

    @Test
    fun volume_ignoresSessionsOutsideTheWeek() {
        val quest = volumeQuest(listOf(session(at(2026, 10, 4, 23, 59), volumeKg = 6000.0)))
        assertFalse(quest.isCompleted)
        assertEquals(0f, quest.progress, fDelta)
    }

    @Test
    fun volume_isWeightTimesRepsAcrossAllSetsAndExercises() {
        // 2 x (10 reps x 100 kg) + (5 reps x 50 kg) = 2250 -> 0.45
        val s = sessionWith(
            at(2026, 10, 6),
            listOf(PerformedSet(SetType.NORMAL, 10, 100.0), PerformedSet(SetType.NORMAL, 10, 100.0)),
            listOf(PerformedSet(SetType.NORMAL, 5, 50.0)),
        )
        assertEquals(0.45f, volumeQuest(listOf(s)).progress, fDelta)
    }

    // ---------------------------------------------------------------------
    // Quest 3: early bird (before 10:00 local)
    // ---------------------------------------------------------------------

    @Test
    fun early_at0959_isCompleted() {
        val quest = earlyQuest(listOf(session(at(2026, 10, 7, 9, 59))))
        assertTrue(quest.isCompleted)
        assertEquals(1f, quest.progress, fDelta)
    }

    @Test
    fun early_at1000_isNotCompleted() {
        val quest = earlyQuest(listOf(session(at(2026, 10, 7, 10, 0))))
        assertFalse(quest.isCompleted)
        assertEquals(0f, quest.progress, fDelta)
    }

    @Test
    fun early_atMidnight_isCompleted() {
        assertTrue(earlyQuest(listOf(session(at(2026, 10, 7, 0, 0)))).isCompleted)
    }

    @Test
    fun early_anyOneEarlySessionIsEnough() {
        val sessions = listOf(
            session(at(2026, 10, 5, 18)),
            session(at(2026, 10, 6, 7)),
            session(at(2026, 10, 7, 20)),
        )
        assertTrue(earlyQuest(sessions).isCompleted)
    }

    @Test
    fun early_sessionOutsideTheWeek_doesNotCount() {
        assertFalse(earlyQuest(listOf(session(at(2026, 10, 4, 6)))).isCompleted)
    }

    @Test
    fun early_hourIsEvaluatedInTheClockTimeZone() {
        // 08:30 UTC is 10:30 in Madrid.
        val s = session(at(2026, 10, 7, 8, 30, zone = utc))
        assertTrue(earlyQuest(listOf(s), clock = at(2026, 10, 7, zone = utc)).isCompleted)
        assertFalse(earlyQuest(listOf(s), clock = at(2026, 10, 7, zone = madrid)).isCompleted)
    }

    // ---------------------------------------------------------------------
    // Quests are independent
    // ---------------------------------------------------------------------

    @Test
    fun quests_areEvaluatedIndependently() {
        // One heavy early session: volume and early bird done, weekly goal (3 days) not.
        val result = evaluate(listOf(session(at(2026, 10, 6, 7), volumeKg = 6000.0)), goal = 3)
        assertFalse(result.quest(QuestId.WEEKLY_GOAL).isCompleted)
        assertTrue(result.quest(QuestId.WEEKLY_VOLUME).isCompleted)
        assertTrue(result.quest(QuestId.EARLY_BIRD).isCompleted)
    }

    // ---------------------------------------------------------------------
    // WorkoutSession.volume()
    // ---------------------------------------------------------------------

    @Test
    fun sessionVolume_noExercises_isZero() {
        assertEquals(0.0, session(now).volume(), 1e-9)
    }

    @Test
    fun sessionVolume_exerciseWithNoSets_isZero() {
        assertEquals(0.0, sessionWith(now, emptyList()).volume(), 1e-9)
    }

    @Test
    fun sessionVolume_sumsWeightTimesReps() {
        val s = sessionWith(
            now,
            listOf(PerformedSet(SetType.NORMAL, 10, 100.0), PerformedSet(SetType.NORMAL, 8, 60.0)),
            listOf(PerformedSet(SetType.NORMAL, 5, 50.0)),
        )
        assertEquals(1000.0 + 480.0 + 250.0, s.volume(), 1e-9)
    }

    /**
     * Only valid if PerformedSet.weight and PerformedSet.reps are nullable
     * (the "?: 0.0" and "?: 0" in your code suggest they are).
     * If they are not nullable, delete this test and the matching branches are unreachable.
     */
    @Test
    fun sessionVolume_nullWeightOrReps_countAsZero() {
        val s = sessionWith(
            now,
            listOf(
                PerformedSet(SetType.NORMAL, null, 100.0),  // no reps
                PerformedSet(SetType.NORMAL, 10, null),     // no weight (bodyweight)
                PerformedSet(SetType.NORMAL, 5, 20.0),      // 100
            ),
        )
        assertEquals(100.0, s.volume(), 1e-9)
    }
}