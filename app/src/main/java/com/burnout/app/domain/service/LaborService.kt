package com.burnout.app.domain.service

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.res.stringResource
import com.burnout.app.R
import com.burnout.app.ui.viewmodel.WorkoutUiState
import com.burnout.app.ui.viewmodel.WorkoutViewModel
import com.burnout.app.util.UnitSystem

data class Labor(
    val id: String,
    val title: String,
    val description: String,
    val requirement: String,
    val medalAsset: String,
    val bgAsset: String,
    val isCompleted: Boolean,
    val progress: Float // 0.0f to 1.0f
)

data class LaborCompletion(
    val id: String,
    val isCompleted: Boolean,
    val progress: Float
)

object LaborsService {
    const val TOTAL_LABOR_COUNT = 12

    // =========================================================================
    // Simplified API (reads from WorkoutUiState)
    // =========================================================================

    /**
     * Gets the full list of labors using an existing [WorkoutUiState] and PR lookup lambda.
     *
     * Callers holding a [WorkoutViewModel] should pass `viewModel.uiState.collectAsState().value`
     * and `viewModel::getPersonalRecord`.
     */
    @Composable
    fun checkLabors(
        uiState: WorkoutUiState,
        getPersonalRecord: (String) -> Double
    ): List<Labor> {
        val unitSystem = if (uiState.unitSystem == "imperial") UnitSystem.IMPERIAL else UnitSystem.METRIC
        return checkLabors(
            unitSystem = unitSystem,
            latestBodyWeightKg = uiState.latestMeasurement?.weightKg,
            benchPr = getPersonalRecord("Bench Press"),
            squatPr = getPersonalRecord("Squat"),
            deadliftPr = getPersonalRecord("Deadlift"),
            ohpPr = getPersonalRecord("Overhead Press"),
            totalVolume = uiState.totalVolume,
            workoutCount = uiState.workoutSessions.size,
            currentStreak = uiState.currentStreak
        )
    }

    /**
     * Calculates the count of completed labors from [WorkoutUiState] and PR lookup lambda.
     *
     * Callers holding a [WorkoutViewModel] should pass `viewModel.uiState.value`
     * and `viewModel::getPersonalRecord`.
     */
    fun countCompletedLabors(
        uiState: WorkoutUiState,
        getPersonalRecord: (String) -> Double
    ): Int {
        return countCompletedLabors(
            latestBodyWeightKg = uiState.latestMeasurement?.weightKg,
            benchPr = getPersonalRecord("Bench Press"),
            squatPr = getPersonalRecord("Squat"),
            deadliftPr = getPersonalRecord("Deadlift"),
            ohpPr = getPersonalRecord("Overhead Press"),
            totalVolume = uiState.totalVolume,
            workoutCount = uiState.workoutSessions.size,
            currentStreak = uiState.currentStreak
        )
    }

    // =========================================================================
    // Raw Parameter API
    // =========================================================================

    fun getLaborCompletionData(
        latestBodyWeightKg: Double?,
        benchPr: Double,
        squatPr: Double,
        deadliftPr: Double,
        ohpPr: Double,
        totalVolume: Double,
        workoutCount: Int,
        currentStreak: Int
    ): List<LaborCompletion> {
        val bodyWeight = latestBodyWeightKg ?: 75.0

        return listOf(
            calculateCompletion("1", benchPr, bodyWeight * 1.25),
            calculateCompletion("2", totalVolume, 100000.0),
            calculateCompletion("3", squatPr, bodyWeight * 1.5),
            calculateCompletion("4", deadliftPr, bodyWeight * 2.0),
            calculateCompletion("5", workoutCount.toDouble(), 50.0),
            calculateCompletion("6", ohpPr, bodyWeight * 0.75),
            calculateCompletion("7", 0.0, bodyWeight * 1.25),
            calculateCompletion("8", 0.0, bodyWeight * 3.0),
            calculateCompletion("9", 0.0, bodyWeight * 0.5),
            calculateCompletion("10", totalVolume, 1000000.0),
            calculateCompletion("11", currentStreak.toDouble(), 30.0),
            calculateCompletion("12", benchPr + squatPr + deadliftPr, 450.0)
        )
    }

    fun countCompletedLabors(
        latestBodyWeightKg: Double?,
        benchPr: Double,
        squatPr: Double,
        deadliftPr: Double,
        ohpPr: Double,
        totalVolume: Double,
        workoutCount: Int,
        currentStreak: Int
    ): Int {
        return getLaborCompletionData(
            latestBodyWeightKg, benchPr, squatPr, deadliftPr, ohpPr, totalVolume, workoutCount, currentStreak
        ).count { it.isCompleted }
    }

    @Composable
    fun checkLabors(
        unitSystem: UnitSystem,
        latestBodyWeightKg: Double?,
        benchPr: Double,
        squatPr: Double,
        deadliftPr: Double,
        ohpPr: Double,
        totalVolume: Double,
        workoutCount: Int,
        currentStreak: Int
    ): List<Labor> {
        val isMetric = unitSystem == UnitSystem.METRIC
        val completionData = getLaborCompletionData(
            latestBodyWeightKg, benchPr, squatPr, deadliftPr, ohpPr, totalVolume, workoutCount, currentStreak
        ).associateBy { it.id }

        val hydraReqText = if (isMetric) {
            stringResource(R.string.labor_hydra_req_metric)
        } else {
            stringResource(R.string.labor_hydra_req_imperial)
        }

        val cattleReqText = if (isMetric) {
            stringResource(R.string.labor_cattle_req_metric)
        } else {
            stringResource(R.string.labor_cattle_req_imperial)
        }

        val cerberusReqText = if (isMetric) {
            stringResource(R.string.labor_cerberus_req_metric)
        } else {
            stringResource(R.string.labor_cerberus_req_imperial)
        }

        return listOf(
            buildLabor("1", stringResource(R.string.labor_nemean_lion_title), stringResource(R.string.labor_nemean_lion_desc), stringResource(R.string.labor_nemean_lion_req), "lion_medal.png", "lion_bg.png", completionData["1"]!!),
            buildLabor("2", stringResource(R.string.labor_lernean_hydra_title), stringResource(R.string.labor_lernean_hydra_desc), hydraReqText, "hydra_medal.png", "hydra_bg.png", completionData["2"]!!),
            buildLabor("3", stringResource(R.string.labor_ceryneian_hind_title), stringResource(R.string.labor_ceryneian_hind_desc), stringResource(R.string.labor_ceryneian_hind_req), "hind_medal.png", "hind_bg.png", completionData["3"]!!),
            buildLabor("4", stringResource(R.string.labor_erymanthian_boar_title), stringResource(R.string.labor_erymanthian_boar_desc), stringResource(R.string.labor_erymanthian_boar_req), "boar_medal.png", "boar_bg.png", completionData["4"]!!),
            buildLabor("5", stringResource(R.string.labor_augean_stables_title), stringResource(R.string.labor_augean_stables_desc), stringResource(R.string.labor_augean_stables_req), "stables_medal.png", "stables_bg.png", completionData["5"]!!),
            buildLabor("6", stringResource(R.string.labor_stymphalian_birds_title), stringResource(R.string.labor_stymphalian_birds_desc), stringResource(R.string.labor_stymphalian_birds_req), "birds_medal.png", "birds_bg.png", completionData["6"]!!),
            buildLabor("7", stringResource(R.string.labor_cretan_bull_title), stringResource(R.string.labor_cretan_bull_desc), stringResource(R.string.labor_cretan_bull_req), "bull_medal.png", "bull_bg.png", completionData["7"]!!),
            buildLabor("8", stringResource(R.string.labor_mares_diomedes_title), stringResource(R.string.labor_mares_diomedes_desc), stringResource(R.string.labor_mares_diomedes_req), "mares_medal.png", "mares_bg.png", completionData["8"]!!),
            buildLabor("9", stringResource(R.string.labor_belt_hippolyta_title), stringResource(R.string.labor_belt_hippolyta_desc), stringResource(R.string.labor_belt_hippolyta_req), "belt_medal.png", "belt_bg.png", completionData["9"]!!),
            buildLabor("10", stringResource(R.string.labor_cattle_geryon_title), stringResource(R.string.labor_cattle_geryon_desc), cattleReqText, "cattle_medal.png", "cattle_bg.png", completionData["10"]!!),
            buildLabor("11", stringResource(R.string.labor_apples_hesperides_title), stringResource(R.string.labor_apples_hesperides_desc), stringResource(R.string.labor_apples_hesperides_req), "apples_medal.png", "apples_bg.png", completionData["11"]!!),
            buildLabor("12", stringResource(R.string.labor_cerberus_title), stringResource(R.string.labor_cerberus_desc), cerberusReqText, "cerberus_medal.png", "cerberus_bg.png", completionData["12"]!!)
        )
    }

    private fun calculateCompletion(id: String, current: Double, target: Double): LaborCompletion {
        return LaborCompletion(
            id = id,
            isCompleted = current >= target,
            progress = (current / target).coerceIn(0.0, 1.0).toFloat()
        )
    }

    private fun buildLabor(
        id: String,
        title: String,
        desc: String,
        reqText: String,
        medalAsset: String,
        bgAsset: String,
        completion: LaborCompletion
    ): Labor {
        return Labor(
            id = id,
            title = title,
            description = desc,
            requirement = reqText,
            medalAsset = "assets/data/images/medals/$medalAsset",
            bgAsset = "assets/data/images/backgrounds/$bgAsset",
            isCompleted = completion.isCompleted,
            progress = completion.progress
        )
    }
}