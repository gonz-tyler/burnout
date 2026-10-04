package com.burnout.app.data

import androidx.annotation.StringRes
import com.burnout.app.R
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Bolt
import androidx.compose.material.icons.rounded.FitnessCenter
import androidx.compose.material.icons.rounded.LocalFireDepartment
import androidx.compose.material.icons.rounded.Public
import androidx.compose.material.icons.rounded.SportsMartialArts
import androidx.compose.material.icons.rounded.WaterDrop
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource

/**
 * Direct port of pantheon_gods.dart — one entry per lift, backing the
 * horizontally-scrolling "Pantheon" section of the dashboard.
 */

data class PantheonGod(
    @StringRes val godRes: Int,
    @StringRes val goddessRes: Int,
    @StringRes val bothRes: Int,
    val lift: String,
    val variations: List<String>,
    val color: Color,
    val icon: ImageVector
)
val pantheonGods: List<PantheonGod> = listOf(
    PantheonGod(
        godRes = R.string.deity_zeus,
        goddessRes = R.string.deity_hera,
        bothRes = R.string.deity_zeus,
        lift = "Bench Press",
        variations = listOf("Incline Bench", "Dumbbell Press", "Dips"),
        color = Color(0xFF00ACC1), // cyan 600
        icon = Icons.Rounded.Bolt
    ),
    PantheonGod(
        godRes = R.string.deity_hercules,
        goddessRes = R.string.deity_athena,
        bothRes = R.string.deity_athena,
        lift = "Squat",
        variations = listOf("Front Squat", "Leg Press", "Goblet Squat"),
        color = Color(0xFFC62828), // red 800
        icon = Icons.Rounded.FitnessCenter
    ),
    PantheonGod(
        godRes = R.string.deity_hades,
        goddessRes = R.string.deity_persephone,
        bothRes = R.string.deity_hades,
        lift = "Deadlift",
        variations = listOf("Romanian Deadlift", "Sumo Deadlift", "Trap Bar"),
        color = Color(0xFF4A148C), // purple 900
        icon = Icons.Rounded.LocalFireDepartment
    ),
    PantheonGod(
        godRes = R.string.deity_atlas,
        goddessRes = R.string.deity_rhea,
        bothRes = R.string.deity_rhea,
        lift = "Overhead Press",
        variations = listOf("Seated Press", "Arnold Press", "Lateral Raise"),
        color = Color(0xFFFFA000), // amber 700
        icon = Icons.Rounded.Public
    ),
    PantheonGod(
        godRes = R.string.deity_poseidon,
        goddessRes = R.string.deity_amphitrite,
        bothRes = R.string.deity_poseidon,
        lift = "Barbell Row",
        variations = listOf("Pull Up", "Cable Row", "Lat Pulldown"),
        color = Color(0xFF0D47A1), // blue 900
        icon = Icons.Rounded.WaterDrop
    ),
    PantheonGod(
        godRes = R.string.deity_ares,
        goddessRes = R.string.deity_artemis,
        bothRes = R.string.deity_artemis,
        lift = "Incline Bench",
        variations = listOf("Reverse Grip Bench", "Hammer Strength"),
        color = Color(0xFFBF360C), // deepOrange 900
        icon = Icons.Rounded.SportsMartialArts
    )
)

