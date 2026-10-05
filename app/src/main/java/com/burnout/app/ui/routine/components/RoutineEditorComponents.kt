package com.burnout.app.ui.routine.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.burnout.app.R
import com.burnout.app.data.local.entity.Exercise
import com.burnout.app.data.local.entity.PlannedSet
import com.burnout.app.data.local.entity.RoutineExercise
import com.burnout.app.data.local.entity.SetType
import com.burnout.app.data.local.entity.abbreviationRes
import com.burnout.app.util.UnitSystem
import com.burnout.app.util.WeightConverter
import kotlin.math.abs

private enum class LocalWeightMode { WEIGHTED, BODYWEIGHT, ASSISTED }

@Composable
fun SetTypeSelectionContent(
    selectedType: SetType,
    onTypeSelected: (SetType) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 32.dp)
    ) {
        Text(
            text = stringResource(R.string.set_type),
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            textAlign = TextAlign.Center,
            color = Color.White,
            fontWeight = FontWeight.Bold,
            fontSize = 18.sp
        )
        TypeOptionItem(SetType.NORMAL, stringResource(R.string.set_type_normal), Color.Gray, selectedType == SetType.NORMAL, onTypeSelected)
        TypeOptionItem(SetType.WARMUP, stringResource(R.string.set_type_warmup), Color(0xFFFFA500), selectedType == SetType.WARMUP, onTypeSelected)
        TypeOptionItem(SetType.DROPSET, stringResource(R.string.set_type_dropset), Color(0xFFA020F0), selectedType == SetType.DROPSET, onTypeSelected)
        TypeOptionItem(SetType.FAILURE, stringResource(R.string.set_type_failure), Color.Red, selectedType == SetType.FAILURE, onTypeSelected)
    }
}

@Composable
private fun TypeOptionItem(
    type: SetType,
    label: String,
    color: Color,
    isSelected: Boolean,
    onTypeSelected: (SetType) -> Unit
) {
    ListItem(
        modifier = Modifier.clickable { onTypeSelected(type) },
        colors = ListItemDefaults.colors(containerColor = Color.Transparent),
        headlineContent = { Text(label, color = MaterialTheme.colorScheme.onSurface) },
        leadingContent = {
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .background(if (type == SetType.NORMAL) MaterialTheme.colorScheme.onSurfaceVariant else color, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Text(stringResource(type.abbreviationRes), color = MaterialTheme.colorScheme.onSurface, fontWeight = FontWeight.Bold, fontSize = 12.sp)
            }
        },
        trailingContent = {
            if (isSelected) {
                Icon(Icons.Default.Check, contentDescription = null, tint = Color(0xFF0091FF))
            }
        }
    )
}

@Composable
fun RoutineExerciseCard(
    exercise: RoutineExercise,
    exerciseDetails: Exercise?,
    unitSystem: String,
    showPrev: Boolean,
    onUpdateExercise: (RoutineExercise) -> Unit,
    onDeleteExercise: () -> Unit,
    onAddSet: () -> Unit,
    onUpdateSet: (Int, PlannedSet) -> Unit,
    onDeleteSet: (Int) -> Unit,
    onShowTypePicker: (Int) -> Unit,
    modifier: Modifier = Modifier,
    onDrag: ((Float) -> Unit)? = null,
    setCompletionStatus: Map<String, Boolean>? = null,
    onToggleCompletion: ((Int) -> Unit)? = null,
    getPreviousSet: ((Int) -> com.burnout.app.data.local.entity.PerformedSet?)? = null
) {
    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = exercise.exerciseName,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface,
                modifier = Modifier.weight(1f)
            )
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = "${stringResource(R.string.rest_label)}: ${stringResource(R.string.rest_value, exercise.restTimeInSeconds)}",
                    color = MaterialTheme.colorScheme.secondary,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.clickable { /* Rest picker? */ }
                )
                Spacer(Modifier.width(16.dp))
                IconButton(onClick = onDeleteExercise, modifier = Modifier.size(24.dp)) {
                    Icon(Icons.Default.Delete, contentDescription = null, tint = MaterialTheme.colorScheme.onSurface)
                }
                Spacer(Modifier.width(12.dp))

                // Draggable handle
                Icon(
                    imageVector = Icons.Default.Menu,
                    contentDescription = stringResource(R.string.reorder),
                    tint = MaterialTheme.colorScheme.onSurface,
                    modifier = Modifier
                        .size(24.dp)
                        .pointerInput(Unit) {
                            detectDragGestures(
                                onDrag = { change, dragAmount ->
                                    change.consume()
                                    onDrag?.invoke(dragAmount.y)
                                }
                            )
                        }
                )
            }
        }

        Spacer(Modifier.height(12.dp))
        HorizontalDivider(
            modifier = Modifier.padding(horizontal = 16.dp),
            color = MaterialTheme.colorScheme.outlineVariant
        )
        Spacer(Modifier.height(12.dp))

        // Weight Mode Detection
        val firstSet = exercise.plannedSets.firstOrNull()
        val weightValue = firstSet?.targetWeight ?: 0.0

        var activeMode by remember(exercise.exerciseId) {
            mutableStateOf(
                when {
                    weightValue < 0.0 -> LocalWeightMode.ASSISTED
                    weightValue == 0.0 && exerciseDetails?.supportsBodyweight == true -> LocalWeightMode.BODYWEIGHT
                    else -> LocalWeightMode.WEIGHTED
                }
            )
        }

        // Headers aligned with row columns
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = stringResource(R.string.set_header),
                modifier = Modifier.width(36.dp),
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold
            )
            if (showPrev) {
                Text(
                    stringResource(R.string.prev_header),
                    modifier = Modifier.weight(1f),
                    textAlign = TextAlign.Center,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold
                )
            } else {
                Spacer(Modifier.weight(1f))
            }

            // Weight Mode Toggle Header
            val unitBase = if (unitSystem == "imperial") stringResource(R.string.weight_lbs) else stringResource(R.string.weight_kg)
            val unitLabel = when (activeMode) {
                LocalWeightMode.BODYWEIGHT -> stringResource(R.string.weight_bw)
                LocalWeightMode.ASSISTED -> "-$unitBase"
                LocalWeightMode.WEIGHTED -> unitBase
            }

            val unitColor = when (activeMode) {
                LocalWeightMode.BODYWEIGHT -> Color(0xFF4CAF50) // Green
                LocalWeightMode.ASSISTED -> Color(0xFFFF9800) // Orange
                LocalWeightMode.WEIGHTED -> Color(0xFF2196F3) // Blue
            }

            val supportedModes = listOfNotNull(
                if (exerciseDetails?.supportsWeight == true) LocalWeightMode.WEIGHTED else null,
                if (exerciseDetails?.supportsBodyweight == true) LocalWeightMode.BODYWEIGHT else null,
                if (exerciseDetails?.supportsAssistance == true) LocalWeightMode.ASSISTED else null
            )
            val canToggle = supportedModes.size > 1

            Text(
                text = unitLabel,
                modifier = Modifier
                    .weight(1f)
                    .clickable(enabled = canToggle) {
                        val nextMode = when (activeMode) {
                            LocalWeightMode.WEIGHTED -> if (exerciseDetails?.supportsBodyweight == true) LocalWeightMode.BODYWEIGHT else LocalWeightMode.ASSISTED
                            LocalWeightMode.BODYWEIGHT -> if (exerciseDetails?.supportsAssistance == true) LocalWeightMode.ASSISTED else LocalWeightMode.WEIGHTED
                            LocalWeightMode.ASSISTED -> if (exerciseDetails?.supportsWeight == true) LocalWeightMode.WEIGHTED else LocalWeightMode.BODYWEIGHT
                        }
                        activeMode = nextMode

                        val newSets = exercise.plannedSets.map { s ->
                            val currentAbs = if (s.targetWeight != null) abs(s.targetWeight) else null
                            val nextWeight = when (nextMode) {
                                LocalWeightMode.WEIGHTED -> currentAbs
                                LocalWeightMode.BODYWEIGHT -> 0.0
                                LocalWeightMode.ASSISTED -> if (currentAbs != null) -currentAbs else null
                            }
                            s.copy(targetWeight = nextWeight)
                        }
                        onUpdateExercise(exercise.copy(plannedSets = newSets))
                    },
                textAlign = TextAlign.Center,
                color = if (canToggle) unitColor else MaterialTheme.colorScheme.onSurfaceVariant,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold
            )
            Text(
                stringResource(R.string.reps_header),
                modifier = Modifier.weight(1f),
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.width(40.dp))
        }

        Spacer(Modifier.height(8.dp))

        var normalSetCounter = 0
        exercise.plannedSets.forEachIndexed { setIndex, currentSet ->
            val label = when (currentSet.setType) {
                SetType.WARMUP -> stringResource(R.string.set_type_warmup_abbr)
                SetType.DROPSET -> {
                    normalSetCounter++
                    stringResource(R.string.set_type_dropset_abbr)
                }
                SetType.FAILURE -> {
                    normalSetCounter++
                    stringResource(R.string.set_type_failure_abbr)
                }
                SetType.NORMAL -> {
                    normalSetCounter++
                    normalSetCounter.toString()
                }
            }

            val isCompleted = setCompletionStatus?.let {
                it["e${exercise.exerciseId}s$setIndex"] ?: false
            } ?: false

            val prevSet = getPreviousSet?.invoke(setIndex)
            val prevText = if (prevSet != null) {
                val sys = if (unitSystem == "imperial") UnitSystem.IMPERIAL else UnitSystem.METRIC
                val w = WeightConverter.displayWeight(prevSet.weight, sys)
                "${w.toString().removeSuffix(".0")} × ${prevSet.reps ?: 0}"
            } else "-"

            HevySetRow(
                label = label,
                plannedSet = currentSet,
                unitSystem = unitSystem,
                isBodyweightMode = activeMode == LocalWeightMode.BODYWEIGHT,
                isAssistedMode = activeMode == LocalWeightMode.ASSISTED,
                showPrev = showPrev,
                previousSetText = prevText,
                isCompleted = isCompleted,
                onTypeClick = { onShowTypePicker(setIndex) },
                onUpdateSet = { updated -> onUpdateSet(setIndex, updated) },
                onCompleted = onToggleCompletion?.let { { it(setIndex) } },
                onDelete = if (setCompletionStatus == null) { { onDeleteSet(setIndex) } } else null
            )

            Spacer(Modifier.height(6.dp))
        }

        Spacer(Modifier.height(12.dp))
        TextButton(
            onClick = onAddSet,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            contentPadding = PaddingValues(0.dp)
        ) {
            Icon(Icons.Default.Add, contentDescription = null, tint = MaterialTheme.colorScheme.onSurfaceVariant, modifier = Modifier.size(16.dp))
            Spacer(Modifier.width(4.dp))
            Text(stringResource(R.string.add_set), color = MaterialTheme.colorScheme.onSurfaceVariant, fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
fun HevySetRow(
    label: String,
    plannedSet: PlannedSet,
    unitSystem: String,
    isBodyweightMode: Boolean,
    isAssistedMode: Boolean,
    showPrev: Boolean,
    onTypeClick: () -> Unit,
    onUpdateSet: (PlannedSet) -> Unit,
    previousSetText: String = "-",
    isCompleted: Boolean = false,
    onCompleted: (() -> Unit)? = null,
    onDelete: (() -> Unit)? = null
) {
    val activeColor = when (plannedSet.setType) {
        SetType.WARMUP -> Color(0xFFFFA500)
        SetType.DROPSET -> Color(0xFFA020F0)
        SetType.FAILURE -> Color.Red
        else -> Color(0xFF0091FF)
    }

    val rowBg = if (isCompleted) Color(0xFF4CAF50).copy(alpha = 0.15f) else Color(0xFF131820)

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp) // Edge spacing around the pill row
            .height(52.dp) // Tall row height to comfortably frame inner elements
            .clip(CircleShape)
            .background(rowBg)
            .padding(horizontal = 8.dp, vertical = 6.dp), // Inner pill padding
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Set Indicator
        Box(
            modifier = Modifier
                .size(36.dp)
                .background(activeColor.copy(alpha = 0.2f), CircleShape)
                .border(1.5.dp, activeColor.copy(alpha = 0.5f), CircleShape)
                .clickable(onClick = onTypeClick),
            contentAlignment = Alignment.Center
        ) {
            Text(label, color = activeColor, fontWeight = FontWeight.Bold)
        }

        // Prev Performance
        if (showPrev) {
            Text(
                text = previousSetText,
                modifier = Modifier.weight(1f),
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                fontSize = 15.sp
            )
        } else {
            Spacer(Modifier.weight(1f))
        }

        // Weight Input Box
        Box(
            modifier = Modifier
                .weight(1f)
                .padding(horizontal = 4.dp)
                .height(40.dp)
                .background(
                    if (isCompleted) Color.Transparent else Color(0xFF1C222B),
                    RoundedCornerShape(8.dp)
                ),
            contentAlignment = Alignment.Center
        ) {
            if (isBodyweightMode) {
                Text(stringResource(R.string.weight_bw), color = Color(0xFF4CAF50), fontWeight = FontWeight.Bold)
            } else {
                val sys = if (unitSystem == "imperial") UnitSystem.IMPERIAL else UnitSystem.METRIC
                val displayWeight = when {
                    plannedSet.targetWeight == null -> ""
                    else -> WeightConverter.displayWeight(abs(plannedSet.targetWeight), sys).toString().replace(".0", "")
                }

                BasicTextField(
                    enabled = !isCompleted,
                    value = displayWeight,
                    onValueChange = { newValue ->
                        if (newValue.isEmpty()) {
                            onUpdateSet(plannedSet.copy(targetWeight = null))
                        } else {
                            val input = newValue.toDoubleOrNull()
                            if (input != null) {
                                val absoluteKg = WeightConverter.saveWeight(input, sys) ?: 0.0
                                val finalWeight = if (isAssistedMode) -absoluteKg else absoluteKg
                                onUpdateSet(plannedSet.copy(targetWeight = finalWeight))
                            }
                        }
                    },
                    textStyle = MaterialTheme.typography.bodyLarge.copy(
                        color = if (isAssistedMode) Color(0xFFFF9800) else Color(0xFF2196F3),
                        textAlign = TextAlign.Center,
                        fontWeight = FontWeight.Bold
                    ),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    cursorBrush = SolidColor(MaterialTheme.colorScheme.onSurface),
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }

        // Reps Input Box
        Box(
            modifier = Modifier
                .weight(1f)
                .padding(horizontal = 4.dp)
                .height(40.dp)
                .background(
                    if (isCompleted) Color.Transparent else Color(0xFF1C222B),
                    RoundedCornerShape(8.dp)
                ),
            contentAlignment = Alignment.Center
        ) {
            BasicTextField(
                enabled = !isCompleted,
                value = plannedSet.targetReps ?: "",
                onValueChange = { newValue ->
                    onUpdateSet(plannedSet.copy(targetReps = if (newValue.isEmpty()) null else newValue))
                },
                textStyle = MaterialTheme.typography.bodyLarge.copy(
                    color = MaterialTheme.colorScheme.onSurface,
                    textAlign = TextAlign.Center,
                    fontWeight = FontWeight.Bold
                ),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                cursorBrush = SolidColor(MaterialTheme.colorScheme.onSurface),
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
        }

        // Action: Tick or Trash
        if (onCompleted != null) {
            val checkBg = if (isCompleted) Color(0xFF4CAF50) else Color(0xFF1C222B)
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .background(checkBg, CircleShape)
                    .clickable { onCompleted() },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Check,
                    contentDescription = stringResource(R.string.complete_set),
                    tint = if (isCompleted) Color.White else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.38f),
                    modifier = Modifier.size(20.dp)
                )
            }
        } else if (onDelete != null) {
            IconButton(onClick = onDelete, modifier = Modifier.size(36.dp)) {
                Icon(
                    imageVector = Icons.Default.Delete,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.error,
                    modifier = Modifier.size(20.dp)
                )
            }
        } else {
            Spacer(Modifier.width(36.dp))
        }
    }
}