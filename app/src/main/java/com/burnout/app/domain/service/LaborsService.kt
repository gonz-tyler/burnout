package com.burnout.app.domain.service

/**
 * Pure domain logic: no Compose, no R, no Android. Everything here is
 * testable with plain JUnit.
 */

enum class LaborId {
    NEMEAN_LION,
    LERNEAN_HYDRA,
    CERYNEIAN_HIND,
    ERYMANTHIAN_BOAR,
    AUGEAN_STABLES,
    STYMPHALIAN_BIRDS,
    CRETAN_BULL,
    MARES_OF_DIOMEDES,
    BELT_OF_HIPPOLYTA,
    CATTLE_OF_GERYON,
    APPLES_OF_HESPERIDES,
    CERBERUS,
}

/** Everything the labor rules need, in one object instead of eight parameters. */
data class LaborStats(
    val bodyWeightKg: Double?,
    val benchPr: Double,
    val squatPr: Double,
    val deadliftPr: Double,
    val ohpPr: Double,
    val rowPr: Double,
    val legPressPr: Double,
    val dipPr: Double,
    val totalVolume: Double,
    val workoutCount: Int,
    val currentStreak: Int,
)

data class LaborProgress(
    val id: LaborId,
    val isCompleted: Boolean,
    val progress: Float, // 0.0f to 1.0f
)

object LaborsService {

    const val DEFAULT_BODY_WEIGHT_KG = 75.0
    val TOTAL_LABOR_COUNT: Int get() = LaborId.entries.size

    /** One labor = one rule: what the user has now, and what they need. */
    private class Rule(
        val id: LaborId,
        val current: (LaborStats) -> Double,
        val target: (bodyWeightKg: Double) -> Double,
    )

    private val rules = listOf(
        Rule(LaborId.NEMEAN_LION, { it.benchPr }, { bw -> bw * 1.25 }),
        Rule(LaborId.LERNEAN_HYDRA, { it.totalVolume }, { 100_000.0 }),
        Rule(LaborId.CERYNEIAN_HIND, { it.squatPr }, { bw -> bw * 1.5 }),
        Rule(LaborId.ERYMANTHIAN_BOAR, { it.deadliftPr }, { bw -> bw * 2.0 }),
        Rule(LaborId.AUGEAN_STABLES, { it.workoutCount.toDouble() }, { 50.0 }),
        Rule(LaborId.STYMPHALIAN_BIRDS, { it.ohpPr }, { bw -> bw * 0.75 }),
        Rule(LaborId.CRETAN_BULL, { it.rowPr }, { bw -> bw * 1.25 }),
        Rule(LaborId.MARES_OF_DIOMEDES, { it.legPressPr }, { bw -> bw * 3.0 }),
        Rule(LaborId.BELT_OF_HIPPOLYTA, { it.dipPr }, { bw -> bw * 0.5 }),
        Rule(LaborId.CATTLE_OF_GERYON, { it.totalVolume }, { 1_000_000.0 }),
        Rule(LaborId.APPLES_OF_HESPERIDES, { it.currentStreak.toDouble() }, { 30.0 }),
        Rule(LaborId.CERBERUS, { it.benchPr + it.squatPr + it.deadliftPr }, { 450.0 }),
    )

    fun evaluate(stats: LaborStats): List<LaborProgress> {
        // A missing or non-positive weight would make targets 0 and complete labors for free.
        val bodyWeight = stats.bodyWeightKg?.takeIf { it > 0.0 } ?: DEFAULT_BODY_WEIGHT_KG

        return rules.map { rule ->
            val current = rule.current(stats)
            val target = rule.target(bodyWeight)
            LaborProgress(
                id = rule.id,
                isCompleted = current >= target,
                progress = (current / target).coerceIn(0.0, 1.0).toFloat(),
            )
        }
    }

    fun countCompleted(stats: LaborStats): Int = evaluate(stats).count { it.isCompleted }
}