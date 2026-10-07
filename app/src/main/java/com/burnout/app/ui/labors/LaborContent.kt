package com.burnout.app.ui.labors

import androidx.annotation.StringRes
import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource
import com.burnout.app.R
import com.burnout.app.domain.service.LaborId
import com.burnout.app.domain.service.LaborProgress
import com.burnout.app.domain.service.LaborStats
import com.burnout.app.ui.viewmodel.WorkoutUiState
import com.burnout.app.util.UnitSystem

// ---------------------------------------------------------------------------
// Presentation data: which strings and images belong to which labor.
// Plain Kotlin (R ids are just Ints), so it is testable without Compose.
// ---------------------------------------------------------------------------

data class LaborContent(
    @StringRes val title: Int,
    @StringRes val description: Int,
    @StringRes val requirement: Int,
    val assetKey: String,
) {
    val medalAsset: String get() = "assets/data/images/medals/${assetKey}_medal.png"
    val bgAsset: String get() = "assets/data/images/backgrounds/${assetKey}_bg.png"
}

private fun UnitSystem.pick(@StringRes metric: Int, @StringRes imperial: Int): Int =
    if (this == UnitSystem.METRIC) metric else imperial

fun LaborId.content(unit: UnitSystem): LaborContent = when (this) {
    LaborId.NEMEAN_LION -> LaborContent(
        R.string.labor_nemean_lion_title, R.string.labor_nemean_lion_desc,
        R.string.labor_nemean_lion_req, "lion"
    )
    LaborId.LERNEAN_HYDRA -> LaborContent(
        R.string.labor_lernean_hydra_title, R.string.labor_lernean_hydra_desc,
        unit.pick(R.string.labor_hydra_req_metric, R.string.labor_hydra_req_imperial), "hydra"
    )
    LaborId.CERYNEIAN_HIND -> LaborContent(
        R.string.labor_ceryneian_hind_title, R.string.labor_ceryneian_hind_desc,
        R.string.labor_ceryneian_hind_req, "hind"
    )
    LaborId.ERYMANTHIAN_BOAR -> LaborContent(
        R.string.labor_erymanthian_boar_title, R.string.labor_erymanthian_boar_desc,
        R.string.labor_erymanthian_boar_req, "boar"
    )
    LaborId.AUGEAN_STABLES -> LaborContent(
        R.string.labor_augean_stables_title, R.string.labor_augean_stables_desc,
        R.string.labor_augean_stables_req, "stables"
    )
    LaborId.STYMPHALIAN_BIRDS -> LaborContent(
        R.string.labor_stymphalian_birds_title, R.string.labor_stymphalian_birds_desc,
        R.string.labor_stymphalian_birds_req, "birds"
    )
    LaborId.CRETAN_BULL -> LaborContent(
        R.string.labor_cretan_bull_title, R.string.labor_cretan_bull_desc,
        R.string.labor_cretan_bull_req, "bull"
    )
    LaborId.MARES_OF_DIOMEDES -> LaborContent(
        R.string.labor_mares_diomedes_title, R.string.labor_mares_diomedes_desc,
        R.string.labor_mares_diomedes_req, "mares"
    )
    LaborId.BELT_OF_HIPPOLYTA -> LaborContent(
        R.string.labor_belt_hippolyta_title, R.string.labor_belt_hippolyta_desc,
        R.string.labor_belt_hippolyta_req, "belt"
    )
    LaborId.CATTLE_OF_GERYON -> LaborContent(
        R.string.labor_cattle_geryon_title, R.string.labor_cattle_geryon_desc,
        unit.pick(R.string.labor_cattle_req_metric, R.string.labor_cattle_req_imperial), "cattle"
    )
    LaborId.APPLES_OF_HESPERIDES -> LaborContent(
        R.string.labor_apples_hesperides_title, R.string.labor_apples_hesperides_desc,
        R.string.labor_apples_hesperides_req, "apples"
    )
    LaborId.CERBERUS -> LaborContent(
        R.string.labor_cerberus_title, R.string.labor_cerberus_desc,
        unit.pick(R.string.labor_cerberus_req_metric, R.string.labor_cerberus_req_imperial), "cerberus"
    )
}

// ---------------------------------------------------------------------------
// UI model + the one tiny composable that resolves strings
// ---------------------------------------------------------------------------

data class Labor(
    val id: LaborId,
    val title: String,
    val description: String,
    val requirement: String,
    val medalAsset: String,
    val bgAsset: String,
    val isCompleted: Boolean,
    val progress: Float,
)

@Composable
fun rememberLabors(progress: List<LaborProgress>, unit: UnitSystem): List<Labor> =
    progress.map { p ->
        val c = p.id.content(unit)
        Labor(
            id = p.id,
            title = stringResource(c.title),
            description = stringResource(c.description),
            requirement = stringResource(c.requirement),
            medalAsset = c.medalAsset,
            bgAsset = c.bgAsset,
            isCompleted = p.isCompleted,
            progress = p.progress,
        )
    }

// ---------------------------------------------------------------------------
// Adapters from app state to domain input
// ---------------------------------------------------------------------------

fun String.toUnitSystem(): UnitSystem =
    if (this == "imperial") UnitSystem.IMPERIAL else UnitSystem.METRIC

fun WorkoutUiState.toLaborStats(getPersonalRecord: (String) -> Double) = LaborStats(
    bodyWeightKg = latestMeasurement?.weightKg,
    benchPr = getPersonalRecord("Bench Press"),
    squatPr = getPersonalRecord("Squat"),
    deadliftPr = getPersonalRecord("Deadlift"),
    ohpPr = getPersonalRecord("Overhead Press"),
    rowPr = getPersonalRecord("Barbell Row"),
    legPressPr = getPersonalRecord("Leg Press"),
    dipPr = getPersonalRecord("Dip"), // adjust to match your dip exercise name
    totalVolume = totalVolume,
    workoutCount = workoutSessions.size,
    currentStreak = currentStreak,
)