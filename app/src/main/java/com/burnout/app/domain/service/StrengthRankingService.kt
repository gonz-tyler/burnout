package com.burnout.app.domain.service

import com.burnout.app.domain.model.Sex

enum class StrengthRank {
    MORTAL,
    HERO,
    DEMIGOD,
    OLYMPIAN,
    TITAN;

    val next: StrengthRank?
        get() = when (this) {
            MORTAL -> HERO
            HERO -> DEMIGOD
            DEMIGOD -> OLYMPIAN
            OLYMPIAN -> TITAN
            TITAN -> null
        }
}

data class StrengthRankInfo(
    val liftName: String,
    val currentPrKg: Double,
    val bodyWeightKg: Double,
    val multiplier: Double,
    val currentRank: StrengthRank,
    val nextRank: StrengthRank?,
    val nextRankTargetKg: Double?,
    val progressToNextRank: Float,
    val remainingKgForNextRank: Double,
)

object StrengthRankingService {

    const val DEFAULT_MALE_BW_KG = 75.0
    const val DEFAULT_FEMALE_BW_KG = 62.0

    private data class RankThresholds(
        val hero: Double,
        val demigod: Double,
        val olympian: Double,
        val titan: Double,
    )

    private fun resolveBodyWeight(userBodyWeightKg: Double?, sex: Sex): Double =
        userBodyWeightKg?.takeIf { it > 0.0 }
            ?: if (sex == Sex.FEMALE) DEFAULT_FEMALE_BW_KG else DEFAULT_MALE_BW_KG

    /** Minimum PR (kg) for each rank at the given bodyweight. */
    fun thresholdsKg(liftName: String, bodyWeightKg: Double?, sex: Sex): Map<StrengthRank, Double> {
        val bw = resolveBodyWeight(bodyWeightKg, sex)
        val t = getThresholds(liftName, sex)
        return mapOf(
            StrengthRank.MORTAL to 0.0,
            StrengthRank.HERO to t.hero * bw,
            StrengthRank.DEMIGOD to t.demigod * bw,
            StrengthRank.OLYMPIAN to t.olympian * bw,
            StrengthRank.TITAN to t.titan * bw,
        )
    }

    fun evaluate(
        liftName: String,
        prKg: Double,
        userBodyWeightKg: Double?,
        sex: Sex,
    ): StrengthRankInfo {
        val bw = resolveBodyWeight(userBodyWeightKg, sex)

        val thresholds = getThresholds(liftName, sex)
        val currentPr = prKg.coerceAtLeast(0.0)
        val mult = currentPr / bw

        val currentRank = when {
            mult >= thresholds.titan -> StrengthRank.TITAN
            mult >= thresholds.olympian -> StrengthRank.OLYMPIAN
            mult >= thresholds.demigod -> StrengthRank.DEMIGOD
            mult >= thresholds.hero -> StrengthRank.HERO
            else -> StrengthRank.MORTAL
        }

        val nextRank = currentRank.next

        val (prevTargetMult, nextTargetMult) = when (currentRank) {
            StrengthRank.MORTAL -> 0.0 to thresholds.hero
            StrengthRank.HERO -> thresholds.hero to thresholds.demigod
            StrengthRank.DEMIGOD -> thresholds.demigod to thresholds.olympian
            StrengthRank.OLYMPIAN -> thresholds.olympian to thresholds.titan
            StrengthRank.TITAN -> thresholds.titan to thresholds.titan
        }

        val nextRankTargetKg = nextRank?.let { nextTargetMult * bw }
        val remainingKg = nextRankTargetKg?.let { (it - currentPr).coerceAtLeast(0.0) } ?: 0.0

        val progress = if (currentRank == StrengthRank.TITAN) {
            1.0f
        } else {
            val range = nextTargetMult - prevTargetMult
            if (range <= 0.0) 1.0f
            else ((mult - prevTargetMult) / range).coerceIn(0.0, 1.0).toFloat()
        }

        return StrengthRankInfo(
            liftName = liftName,
            currentPrKg = currentPr,
            bodyWeightKg = bw,
            multiplier = mult,
            currentRank = currentRank,
            nextRank = nextRank,
            nextRankTargetKg = nextRankTargetKg,
            progressToNextRank = progress,
            remainingKgForNextRank = remainingKg,
        )
    }

    private fun getThresholds(liftName: String, sex: Sex): RankThresholds {
        val normalized = liftName.trim().lowercase()
        val isFemale = sex == Sex.FEMALE

        return when {
            normalized.contains("bench press") || normalized.contains("bench") -> {
                if (isFemale) RankThresholds(0.50, 0.75, 1.00, 1.25)
                else RankThresholds(0.80, 1.25, 1.50, 1.75)
            }
            normalized.contains("squat") -> {
                if (isFemale) RankThresholds(0.80, 1.25, 1.60, 2.00)
                else RankThresholds(1.00, 1.50, 1.80, 2.20)
            }
            normalized.contains("deadlift") -> {
                if (isFemale) RankThresholds(0.90, 1.40, 1.80, 2.20)
                else RankThresholds(1.20, 1.75, 2.20, 2.70)
            }
            normalized.contains("overhead press") || normalized.contains("ohp") -> {
                if (isFemale) RankThresholds(0.35, 0.50, 0.70, 0.90)
                else RankThresholds(0.50, 0.75, 1.00, 1.25)
            }
            normalized.contains("row") -> {
                if (isFemale) RankThresholds(0.40, 0.65, 0.85, 1.05)
                else RankThresholds(0.60, 0.90, 1.20, 1.40)
            }
            normalized.contains("pull up") || normalized.contains("pull-up") || normalized.contains("chin up") -> {
                if (isFemale) RankThresholds(0.80, 1.00, 1.15, 1.35)
                else RankThresholds(1.00, 1.15, 1.35, 1.55)
            }
            else -> {
                if (isFemale) RankThresholds(0.50, 0.80, 1.10, 1.40)
                else RankThresholds(0.80, 1.20, 1.50, 1.80)
            }
        }
    }

    /** Overall Pantheon Rank across the 6 compound lifts. */
    fun calculateOverallRank(rankInfos: List<StrengthRankInfo>): StrengthRank {
        if (rankInfos.isEmpty()) return StrengthRank.MORTAL
        val avgOrdinal = rankInfos.map { it.currentRank.ordinal }.average()
        val roundedOrdinal = avgOrdinal.toInt().coerceIn(0, StrengthRank.entries.lastIndex)
        return StrengthRank.entries[roundedOrdinal]
    }
}
