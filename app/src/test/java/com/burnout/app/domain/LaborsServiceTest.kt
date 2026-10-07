package com.burnout.app.domain

import com.burnout.app.domain.service.LaborId
import com.burnout.app.domain.service.LaborStats
import com.burnout.app.domain.service.LaborsService
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class LaborsServiceTest {

    @Test
    fun testEvaluateLaborsCompletion() {
        val stats = LaborStats(
            bodyWeightKg = 80.0,
            benchPr = 100.0, // target: 80 * 1.25 = 100.0 (completed)
            squatPr = 100.0, // target: 80 * 1.5 = 120.0 (incomplete)
            deadliftPr = 160.0, // target: 80 * 2.0 = 160.0 (completed)
            ohpPr = 60.0, // target: 80 * 0.75 = 60.0 (completed)
            rowPr = 100.0,
            legPressPr = 240.0,
            dipPr = 40.0,
            totalVolume = 100_000.0,
            workoutCount = 50,
            currentStreak = 30
        )

        val progress = LaborsService.evaluate(stats)
        assertEquals(LaborsService.TOTAL_LABOR_COUNT, progress.size)

        val lion = progress.first { it.id == LaborId.NEMEAN_LION }
        assertTrue(lion.isCompleted)

        val hind = progress.first { it.id == LaborId.CERYNEIAN_HIND }
        assertFalse(hind.isCompleted)

        val completedCount = LaborsService.countCompleted(stats)
        assertTrue(completedCount > 0)
    }
}
