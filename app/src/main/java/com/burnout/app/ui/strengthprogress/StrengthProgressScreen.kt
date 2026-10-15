package com.burnout.app.ui.strengthprogress

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowBack
import androidx.compose.material.icons.automirrored.rounded.TrendingUp
import androidx.compose.material.icons.rounded.Clear
import androidx.compose.material.icons.rounded.Search
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.burnout.app.R
import com.burnout.app.data.local.entity.Exercise
import com.burnout.app.data.local.entity.SetType
import com.burnout.app.data.local.entity.WorkoutSession
import com.burnout.app.util.UnitSystem
import com.burnout.app.util.WeightConverter
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

// ---------------------------------------------------------------------------
// Data layer: plain types + pure functions, so the screens don't depend on
// Room entities directly. Map logged sets into LoggedSet
// and call buildExerciseProgress per exercise.
// ---------------------------------------------------------------------------

/** One logged working set. Weight is always stored in kg. */
data class LoggedSet(val epochDay: Long, val weightKg: Double, val reps: Int)

/** The best set of one training day for one exercise. */
data class ProgressPoint(
    val epochDay: Long,
    val e1rmKg: Double,
    val topWeightKg: Double,
    val topReps: Int,
)

data class ExerciseProgress(val id: String, val name: String, val points: List<ProgressPoint>) {
    val latest: ProgressPoint? get() = points.lastOrNull()
    val bestE1rmKg: Double? get() = points.maxOfOrNull { it.e1rmKg }
}

/** Epley estimate. Most reliable for sets of roughly 1-10 reps. */
fun estimateOneRepMax(weightKg: Double, reps: Int): Double =
    if (reps <= 1) weightKg else weightKg * (1 + reps / 30.0)

/** Collapses sets into one point per day: the set with the highest estimated 1RM. */
fun buildExerciseProgress(id: String, name: String, sets: List<LoggedSet>): ExerciseProgress {
    val points = sets
        .filter { it.weightKg > 0 && it.reps > 0 }
        .groupBy { it.epochDay }
        .map { (day, daySets) ->
            val top = daySets.maxBy { estimateOneRepMax(it.weightKg, it.reps) }
            ProgressPoint(
                epochDay = day,
                e1rmKg = estimateOneRepMax(top.weightKg, top.reps),
                topWeightKg = top.weightKg,
                topReps = top.reps,
            )
        }
        .sortedBy { it.epochDay }
    return ExerciseProgress(id, name, points)
}

/**
 * Builds one ExerciseProgress per exercise that has at least one usable set.
 * Skips warm-ups and sets without both weight and reps (cardio, timed holds).
 * Assumes PerformedSet.weight is stored in kg, as the rest of the app does.
 */
fun buildAllExerciseProgress(
    sessions: List<WorkoutSession>,
    exercises: List<Exercise>,
): List<ExerciseProgress> {
    val zone = ZoneId.systemDefault()
    val setsByExercise = HashMap<String, MutableList<LoggedSet>>()

    for (session in sessions) {
        val day = Instant.ofEpochMilli(session.dateCompleted).atZone(zone).toLocalDate().toEpochDay()
        for (performed in session.performedExercises) {
            for (set in performed.sets) {
                if (set.setType == SetType.WARMUP) continue
                val weight = set.weight ?: continue
                val reps = set.reps ?: continue
                setsByExercise.getOrPut(performed.exerciseId) { mutableListOf() }
                    .add(LoggedSet(day, weight, reps))
            }
        }
    }

    return exercises.mapNotNull { exercise ->
        val sets = setsByExercise[exercise.id] ?: return@mapNotNull null
        buildExerciseProgress(exercise.id, exercise.name, sets).takeIf { it.points.isNotEmpty() }
    }
}

enum class ProgressRange(val days: Long?) { M1(30), M3(90), M6(180), ALL(null) }

private fun List<ProgressPoint>.inRange(range: ProgressRange): List<ProgressPoint> {
    val days = range.days ?: return this
    val cutoff = LocalDate.now().toEpochDay() - days
    return filter { it.epochDay >= cutoff }
}

/** Change in estimated 1RM (kg) from first to last point, or null with fewer than 2 points. */
private fun List<ProgressPoint>.deltaKg(): Double? =
    if (size < 2) null else last().e1rmKg - first().e1rmKg

private val longDate: DateTimeFormatter = DateTimeFormatter.ofPattern("d MMM yyyy", Locale.getDefault())
private val shortDate: DateTimeFormatter = DateTimeFormatter.ofPattern("d MMM", Locale.getDefault())
private fun Long.asLongDate(): String = LocalDate.ofEpochDay(this).format(longDate)
private fun Long.asShortDate(): String = LocalDate.ofEpochDay(this).format(shortDate)

// ---------------------------------------------------------------------------
// Screen 1: List of every exercise that has history
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StrengthProgressScreen(
    exercises: List<ExerciseProgress>,
    unitSystem: String,
    onBack: () -> Unit,
    onExerciseClick: (ExerciseProgress) -> Unit,
    bottomPadding: Dp = 0.dp,
) {
    val sys = if (unitSystem == "imperial") UnitSystem.IMPERIAL else UnitSystem.METRIC
    val unit = if (sys == UnitSystem.METRIC) "kg" else "lbs"

    var searchQuery by rememberSaveable { mutableStateOf("") }

    val sorted = remember(exercises, searchQuery) {
        exercises
            .filter { it.points.isNotEmpty() }
            .filter { it.name.contains(searchQuery, ignoreCase = true) }
            .sortedByDescending { it.latest?.epochDay ?: 0L }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = stringResource(R.string.strength_progress),
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Rounded.ArrowBack,
                            contentDescription = stringResource(R.string.back_description),
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                ),
            )
        },
        modifier = Modifier.fillMaxSize(),
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentPadding = PaddingValues(
                start = 16.dp,
                end = 16.dp,
                top = 8.dp,
                bottom = 16.dp + bottomPadding,
            ),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            if (exercises.size > 3) {
                item {
                    OutlinedTextField(
                        value = searchQuery,
                        onValueChange = { searchQuery = it },
                        placeholder = { Text(stringResource(R.string.search_exercises_hint)) },
                        leadingIcon = { Icon(Icons.Rounded.Search, contentDescription = null) },
                        trailingIcon = if (searchQuery.isNotEmpty()) {
                            {
                                IconButton(onClick = { searchQuery = "" }) {
                                    Icon(Icons.Rounded.Clear, contentDescription = null)
                                }
                            }
                        } else null,
                        singleLine = true,
                        shape = RoundedCornerShape(16.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 4.dp),
                    )
                }
            }

            if (sorted.isEmpty()) {
                item { EmptyState(isFilterEmpty = searchQuery.isNotEmpty()) }
            } else {
                items(sorted, key = { it.id }) { exercise ->
                    ExerciseRow(
                        exercise = exercise,
                        unitSystem = sys,
                        unit = unit,
                        onClick = { onExerciseClick(exercise) },
                    )
                }
            }
        }
    }
}

@Composable
private fun ExerciseRow(
    exercise: ExerciseProgress,
    unitSystem: UnitSystem,
    unit: String,
    onClick: () -> Unit,
) {
    val latest = exercise.latest ?: return
    val delta = exercise.points.deltaKg()
    val sparkValues = remember(exercise) { exercise.points.takeLast(12).map { it.e1rmKg } }

    Card(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainerLow,
        ),
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 16.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = exercise.name,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
                Spacer(Modifier.height(4.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = "${stringResource(R.string.est_1rm)}: ",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Text(
                        text = "%.1f $unit".format(WeightConverter.displayWeight(latest.e1rmKg, unitSystem)),
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.onSurface,
                    )
                }
            }
            Spacer(Modifier.width(12.dp))
            Column(horizontalAlignment = Alignment.End) {
                Sparkline(
                    values = sparkValues,
                    color = MaterialTheme.colorScheme.primary,
                    modifier = Modifier
                        .width(80.dp)
                        .height(32.dp),
                )
                if (delta != null) {
                    Spacer(Modifier.height(6.dp))
                    DeltaBadge(deltaKg = delta, unitSystem = unitSystem, unit = unit)
                }
            }
        }
    }
}

@Composable
private fun DeltaBadge(deltaKg: Double, unitSystem: UnitSystem, unit: String) {
    val shown = WeightConverter.displayWeight(kotlin.math.abs(deltaKg), unitSystem)
    val isPositive = deltaKg >= 0
    val sign = if (isPositive) "+" else "-"
    val containerColor = if (isPositive) {
        MaterialTheme.colorScheme.primaryContainer
    } else {
        MaterialTheme.colorScheme.surfaceContainerHigh
    }
    val contentColor = if (isPositive) {
        MaterialTheme.colorScheme.onPrimaryContainer
    } else {
        MaterialTheme.colorScheme.onSurfaceVariant
    }

    Surface(
        color = containerColor,
        contentColor = contentColor,
        shape = RoundedCornerShape(12.dp),
    ) {
        Text(
            text = "$sign%.1f $unit".format(shown),
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
        )
    }
}

@Composable
private fun EmptyState(isFilterEmpty: Boolean = false) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 24.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainerLow,
        ),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Icon(
                imageVector = Icons.AutoMirrored.Rounded.TrendingUp,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(48.dp),
            )
            Spacer(Modifier.height(16.dp))
            Text(
                text = if (isFilterEmpty) {
                    stringResource(R.string.no_sessions_in_range)
                } else {
                    stringResource(R.string.progress_empty_title)
                },
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
            )
            Spacer(Modifier.height(6.dp))
            if (!isFilterEmpty) {
                Text(
                    text = stringResource(R.string.progress_empty_body),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center,
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Screen 2: One exercise, with range selector, chart and recent sessions
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExerciseProgressScreen(
    progress: ExerciseProgress,
    unitSystem: String,
    onBack: () -> Unit,
    bottomPadding: Dp = 0.dp,
) {
    val sys = if (unitSystem == "imperial") UnitSystem.IMPERIAL else UnitSystem.METRIC
    val unit = if (sys == UnitSystem.METRIC) "kg" else "lbs"
    var range by rememberSaveable { mutableStateOf(ProgressRange.M3) }
    val visible = remember(progress, range) { progress.points.inRange(range) }
    val delta = visible.deltaKg()
    val shownPoint = visible.lastOrNull() ?: progress.latest

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = progress.name,
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Rounded.ArrowBack,
                            contentDescription = stringResource(R.string.back_description),
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                ),
            )
        },
        modifier = Modifier.fillMaxSize(),
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentPadding = PaddingValues(
                start = 16.dp,
                end = 16.dp,
                top = 8.dp,
                bottom = 16.dp + bottomPadding,
            ),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            // Hero Stat Card
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(24.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surfaceContainer,
                    ),
                ) {
                    Column(
                        modifier = Modifier.padding(20.dp),
                    ) {
                        Text(
                            text = stringResource(R.string.est_1rm).uppercase(),
                            fontSize = 11.sp,
                            letterSpacing = 1.5.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                        Spacer(Modifier.height(4.dp))
                        Row(
                            verticalAlignment = Alignment.Bottom,
                            modifier = Modifier.fillMaxWidth(),
                        ) {
                            Text(
                                text = shownPoint?.let {
                                    "%.1f".format(WeightConverter.displayWeight(it.e1rmKg, sys))
                                } ?: "--",
                                fontSize = 44.sp,
                                lineHeight = 44.sp,
                                fontWeight = FontWeight.Black,
                            )
                            Spacer(Modifier.width(6.dp))
                            Text(
                                text = unit,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                modifier = Modifier.padding(bottom = 6.dp),
                            )
                            Spacer(Modifier.weight(1f))
                            if (delta != null) {
                                DeltaBadge(deltaKg = delta, unitSystem = sys, unit = unit)
                            }
                        }
                        progress.bestE1rmKg?.let { best ->
                            Spacer(Modifier.height(10.dp))
                            Surface(
                                color = MaterialTheme.colorScheme.surfaceContainerHigh,
                                shape = RoundedCornerShape(10.dp),
                            ) {
                                Text(
                                    text = "${stringResource(R.string.progress_best)}: " +
                                            "%.1f $unit".format(WeightConverter.displayWeight(best, sys)),
                                    style = MaterialTheme.typography.labelMedium,
                                    fontWeight = FontWeight.SemiBold,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp),
                                )
                            }
                        }
                    }
                }
            }

            // Time Range Chips
            item {
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    items(ProgressRange.entries.toTypedArray()) { option ->
                        FilterChip(
                            selected = option == range,
                            onClick = { range = option },
                            label = {
                                Text(
                                    stringResource(
                                        when (option) {
                                            ProgressRange.M1 -> R.string.range_1m
                                            ProgressRange.M3 -> R.string.range_3m
                                            ProgressRange.M6 -> R.string.range_6m
                                            ProgressRange.ALL -> R.string.range_all
                                        }
                                    ),
                                    fontWeight = if (option == range) FontWeight.Bold else FontWeight.Medium,
                                )
                            },
                            shape = RoundedCornerShape(12.dp),
                        )
                    }
                }
            }

            // Chart Card
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(24.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surfaceContainer,
                    ),
                ) {
                    Column(modifier = Modifier.padding(20.dp)) {
                        if (visible.isEmpty()) {
                            Text(
                                text = stringResource(R.string.no_sessions_in_range),
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                style = MaterialTheme.typography.bodyMedium,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 40.dp),
                                textAlign = TextAlign.Center,
                            )
                        } else {
                            ProgressChart(
                                points = visible,
                                unitSystem = sys,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(210.dp),
                            )
                            Spacer(Modifier.height(12.dp))
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(start = 40.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                            ) {
                                Text(
                                    text = visible.first().epochDay.asShortDate(),
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Medium,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )
                                if (visible.size > 1) {
                                    Text(
                                        text = visible.last().epochDay.asShortDate(),
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Medium,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    )
                                }
                            }
                        }
                    }
                }
            }

            // Recent Sessions
            if (visible.isNotEmpty()) {
                item {
                    Text(
                        text = stringResource(R.string.recent_sessions),
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(top = 4.dp),
                    )
                }
                items(visible.asReversed().take(10), key = { it.epochDay }) { point ->
                    SessionRow(point = point, unitSystem = sys, unit = unit)
                }
            }
        }
    }
}

@Composable
private fun SessionRow(point: ProgressPoint, unitSystem: UnitSystem, unit: String) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainerLow,
        ),
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = point.epochDay.asLongDate(),
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.SemiBold,
                )
                Spacer(Modifier.height(2.dp))
                Text(
                    text = "${stringResource(R.string.est_1rm)}: " +
                            "%.1f $unit".format(WeightConverter.displayWeight(point.e1rmKg, unitSystem)),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            Surface(
                color = MaterialTheme.colorScheme.primaryContainer,
                contentColor = MaterialTheme.colorScheme.onPrimaryContainer,
                shape = RoundedCornerShape(10.dp),
            ) {
                Text(
                    text = "%.1f $unit × %d".format(
                        WeightConverter.displayWeight(point.topWeightKg, unitSystem),
                        point.topReps,
                    ),
                    fontWeight = FontWeight.Bold,
                    fontSize = 13.sp,
                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Shared visual pieces
// ---------------------------------------------------------------------------

@Composable
private fun Sparkline(values: List<Double>, color: Color, modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        if (values.isEmpty()) return@Canvas
        val pad = 4.dp.toPx()
        val w = size.width - pad * 2
        val h = size.height - pad * 2
        if (values.size == 1) {
            drawCircle(color, radius = 3.dp.toPx(), center = Offset(size.width - pad, size.height / 2))
            return@Canvas
        }
        val min = values.min()
        val range = (values.max() - min).takeIf { it > 0 } ?: 1.0
        val stepX = w / (values.size - 1)

        val pts = values.mapIndexed { i, v ->
            val x = pad + i * stepX
            val y = pad + h - ((v - min) / range * h).toFloat()
            Offset(x, y)
        }

        val path = Path()
        path.moveTo(pts.first().x, pts.first().y)
        for (i in 0 until pts.size - 1) {
            val p1 = pts[i]
            val p2 = pts[i + 1]
            val control1 = Offset(p1.x + (p2.x - p1.x) / 2f, p1.y)
            val control2 = Offset(p1.x + (p2.x - p1.x) / 2f, p2.y)
            path.cubicTo(control1.x, control1.y, control2.x, control2.y, p2.x, p2.y)
        }

        drawPath(
            path = path,
            color = color,
            style = Stroke(width = 2.5.dp.toPx(), cap = StrokeCap.Round, join = StrokeJoin.Round),
        )
    }
}

/** Smooth line chart of estimated 1RM over time using cubic bezier curves. */
@Composable
private fun ProgressChart(
    points: List<ProgressPoint>,
    unitSystem: UnitSystem,
    modifier: Modifier = Modifier,
) {
    val lineColor = MaterialTheme.colorScheme.primary
    val gridColor = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f)
    val values = remember(points, unitSystem) {
        points.map { WeightConverter.displayWeight(it.e1rmKg, unitSystem) }
    }

    val rawMin = values.min()
    val rawMax = values.max()
    val span = (rawMax - rawMin).takeIf { it > 0 } ?: (rawMax * 0.1).coerceAtLeast(1.0)
    val yMin = rawMin - span * 0.15
    val yMax = rawMax + span * 0.15

    Row(modifier = modifier) {
        Column(
            modifier = Modifier
                .width(36.dp)
                .fillMaxHeight(),
            verticalArrangement = Arrangement.SpaceBetween,
        ) {
            listOf(yMax, (yMax + yMin) / 2, yMin).forEach {
                Text(
                    text = "%.0f".format(it),
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Medium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }

        Canvas(modifier = Modifier.weight(1f).fillMaxHeight()) {
            val padHorizontal = 8.dp.toPx()
            val w = size.width - padHorizontal * 2
            val h = size.height

            val dash = PathEffect.dashPathEffect(floatArrayOf(12f, 12f))
            listOf(0f, h / 2, h).forEach { y ->
                drawLine(
                    color = gridColor,
                    start = Offset(0f, y),
                    end = Offset(size.width, y),
                    strokeWidth = 1.dp.toPx(),
                    pathEffect = dash,
                )
            }

            val firstDay = points.first().epochDay
            val dayRange = (points.last().epochDay - firstDay).coerceAtLeast(1L)
            fun xOf(day: Long): Float =
                if (points.size == 1) size.width / 2 else padHorizontal + w * ((day - firstDay).toFloat() / dayRange)
            fun yOf(v: Double): Float = h - (((v - yMin) / (yMax - yMin)).toFloat() * h)

            val chartPoints = points.mapIndexed { i, p ->
                Offset(xOf(p.epochDay), yOf(values[i]))
            }

            if (chartPoints.size > 1) {
                val linePath = Path()
                val areaPath = Path()

                linePath.moveTo(chartPoints.first().x, chartPoints.first().y)
                areaPath.moveTo(chartPoints.first().x, h)
                areaPath.lineTo(chartPoints.first().x, chartPoints.first().y)

                for (i in 0 until chartPoints.size - 1) {
                    val p1 = chartPoints[i]
                    val p2 = chartPoints[i + 1]
                    val control1 = Offset(p1.x + (p2.x - p1.x) / 2f, p1.y)
                    val control2 = Offset(p1.x + (p2.x - p1.x) / 2f, p2.y)

                    linePath.cubicTo(control1.x, control1.y, control2.x, control2.y, p2.x, p2.y)
                    areaPath.cubicTo(control1.x, control1.y, control2.x, control2.y, p2.x, p2.y)
                }

                areaPath.lineTo(chartPoints.last().x, h)
                areaPath.close()

                drawPath(
                    path = areaPath,
                    brush = Brush.verticalGradient(
                        colors = listOf(lineColor.copy(alpha = 0.28f), Color.Transparent),
                    ),
                )
                drawPath(
                    path = linePath,
                    color = lineColor,
                    style = Stroke(width = 3.dp.toPx(), cap = StrokeCap.Round, join = StrokeJoin.Round),
                )
            }

            // Draw data point dots with a outer halo ring on the latest session
            chartPoints.forEachIndexed { i, pt ->
                val isLast = i == chartPoints.lastIndex
                if (isLast) {
                    drawCircle(lineColor.copy(alpha = 0.2f), radius = 10.dp.toPx(), center = pt)
                }
                drawCircle(lineColor, radius = if (isLast) 5.dp.toPx() else 3.5.dp.toPx(), center = pt)
            }
        }
    }
}
