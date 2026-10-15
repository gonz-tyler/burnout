package com.burnout.app.domain.service

import com.burnout.app.domain.model.Sex
import org.junit.Assert.assertEquals
import org.junit.Test

class StrengthRankingServiceTest {

    @Test
    fun evaluateMaleBenchPress_Hero() {
        // 75kg male lifting 75kg bench (1.0x BW) -> HERO
        val info = StrengthRankingService.evaluate(
            liftName = "Bench Press",
            prKg = 75.0,
            userBodyWeightKg = 75.0,
            sex = Sex.MALE,
        )
        assertEquals(StrengthRank.HERO, info.currentRank)
        assertEquals(StrengthRank.DEMIGOD, info.nextRank)
        assertEquals(1.25 * 75.0, info.nextRankTargetKg!!, 0.01)
        assertEquals(18.75, info.remainingKgForNextRank, 0.01)
    }

    @Test
    fun evaluateFemaleBenchPress_Olympian() {
        // 60kg female lifting 60kg bench (1.0x BW) -> OLYMPIAN
        val info = StrengthRankingService.evaluate(
            liftName = "Bench Press",
            prKg = 60.0,
            userBodyWeightKg = 60.0,
            sex = Sex.FEMALE,
        )
        assertEquals(StrengthRank.OLYMPIAN, info.currentRank)
        assertEquals(StrengthRank.TITAN, info.nextRank)
    }

    @Test
    fun evaluateSquat_EqualRatios() {
        // Male 75kg lifting 112.5kg (1.5x) -> DEMIGOD
        val maleInfo = StrengthRankingService.evaluate(
            liftName = "Squat",
            prKg = 112.5,
            userBodyWeightKg = 75.0,
            sex = Sex.MALE,
        )
        assertEquals(StrengthRank.DEMIGOD, maleInfo.currentRank)

        // Female 60kg lifting 75kg (1.25x) -> DEMIGOD
        val femaleInfo = StrengthRankingService.evaluate(
            liftName = "Squat",
            prKg = 75.0,
            userBodyWeightKg = 60.0,
            sex = Sex.FEMALE,
        )
        assertEquals(StrengthRank.DEMIGOD, femaleInfo.currentRank)
    }

    @Test
    fun calculateOverallRank() {
        val infos = listOf(
            StrengthRankingService.evaluate("Bench Press", 100.0, 75.0, Sex.MALE), // Demigod (1.33x)
            StrengthRankingService.evaluate("Squat", 112.5, 75.0, Sex.MALE),       // Demigod (1.50x)
            StrengthRankingService.evaluate("Deadlift", 135.0, 75.0, Sex.MALE),     // Demigod (1.80x)
            StrengthRankingService.evaluate("Overhead Press", 56.25, 75.0, Sex.MALE), // Demigod (0.75x)
            StrengthRankingService.evaluate("Barbell Row", 67.5, 75.0, Sex.MALE),   // Demigod (0.90x)
            StrengthRankingService.evaluate("Pull Up", 86.25, 75.0, Sex.MALE),       // Demigod (1.15x)
        )
        val overall = StrengthRankingService.calculateOverallRank(infos)
        assertEquals(StrengthRank.DEMIGOD, overall)
    }
}
