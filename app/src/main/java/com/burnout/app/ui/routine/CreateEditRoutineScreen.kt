package com.burnout.app.ui.routine

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import com.burnout.app.R
import com.burnout.app.data.local.entity.*
import com.burnout.app.ui.routine.components.*
import kotlinx.coroutines.launch
import java.util.UUID
import kotlin.math.roundToInt

fun getWeightModeColor(weight: Double?): Color {
    val w = weight ?: 0.0
    return when {
        w > 0.0 -> Color(0xFF2196F3) // Blue (Weighted)
        w < 0.0 -> Color(0xFFFF9800) // Orange (Assisted)
        else -> Color(0xFF4CAF50)    // Green (Bodyweight)
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreateEditRoutineScreen(
    initialRoutine: Routine?,
    availableExercises: List<Exercise>,
    unitSystem: String,
    onSaveRoutine: (Routine) -> Unit,
    onNavigateBack: () -> Unit
) {
    var routineName by remember { mutableStateOf(initialRoutine?.name ?: "") }
    val editableExercises = remember {
        mutableStateListOf<RoutineExercise>().apply {
            initialRoutine?.exercises?.let { addAll(it) }
        }
    }

    var showExercisePicker by remember { mutableStateOf(false) }
    val sheetState = rememberModalBottomSheetState()
    val scope = rememberCoroutineScope()
    var showTypeSheetFor by remember { mutableStateOf<Pair<Int, Int>?>(null) } // exerciseIndex, setIndex

    Scaffold(
        containerColor = MaterialTheme.colorScheme.surface,
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text(if (initialRoutine == null) stringResource(R.string.create_routine) else stringResource(R.string.edit_routine), color = MaterialTheme.colorScheme.onSurface, fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = stringResource(R.string.back_description), tint = MaterialTheme.colorScheme.onSurface)
                    }
                },
                actions = {
                    IconButton(
                        onClick = {
                            if (routineName.isNotBlank()) {
                                val finalRoutine = Routine(
                                    id = initialRoutine?.id ?: UUID.randomUUID().toString(),
                                    name = routineName,
                                    exercises = editableExercises.toList(),
                                    sortOrder = initialRoutine?.sortOrder
                                )
                                onSaveRoutine(finalRoutine)
                            }
                        },
                        enabled = routineName.isNotBlank() && editableExercises.isNotEmpty()
                    ) {
                        Icon(Icons.Default.Save, contentDescription = stringResource(R.string.save_routine_description), tint = if (routineName.isNotBlank() && editableExercises.isNotEmpty()) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.38f))
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.surface)
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            // Header Section
            Column(modifier = Modifier.padding(horizontal = 16.dp)) {
                OutlinedTextField(
                    value = routineName,
                    onValueChange = { routineName = it },
                    placeholder = { Text(stringResource(R.string.routine_name_label), color = MaterialTheme.colorScheme.onSurfaceVariant) },
                    singleLine = true,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 12.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        // Typed text
                        focusedTextColor = MaterialTheme.colorScheme.onSurface,
                        unfocusedTextColor = MaterialTheme.colorScheme.onSurface,
                        // Container background
                        focusedContainerColor = Color.Transparent,
                        unfocusedContainerColor = Color.Transparent,
                        // Borders
                        focusedBorderColor = MaterialTheme.colorScheme.primary,
                        unfocusedBorderColor = MaterialTheme.colorScheme.outline,
                        errorBorderColor = MaterialTheme.colorScheme.error,
                        // Labels and Hints
                        focusedLabelColor = MaterialTheme.colorScheme.primary,
                        unfocusedLabelColor = MaterialTheme.colorScheme.onSurfaceVariant,
                        // Icons
                        focusedLeadingIconColor = MaterialTheme.colorScheme.primary,
                        unfocusedLeadingIconColor = MaterialTheme.colorScheme.onSurfaceVariant,
                        // Cursor
                        cursorColor = MaterialTheme.colorScheme.primary,
                    ),
                )

                Button(
                    onClick = { showExercisePicker = true },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp),
                    shape = CircleShape,
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary, contentColor = MaterialTheme.colorScheme.onPrimary)
                ) {
                    Icon(Icons.Default.Add, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(8.dp))
                    val label = if (editableExercises.isEmpty()) stringResource(R.string.add_exercise) else stringResource(R.string.add_edit_exercises)
                    Text(label, fontWeight = FontWeight.Bold)
                }
            }

            Spacer(Modifier.height(16.dp))
            HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)

            if (editableExercises.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = stringResource(R.string.add_exercises_to_start),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            } else {
                LazyColumn(
                    verticalArrangement = Arrangement.spacedBy(24.dp),
                    contentPadding = PaddingValues(top = 16.dp, bottom = 100.dp),
                    modifier = Modifier.weight(1f)
                ) {
                    itemsIndexed(
                        items = editableExercises,
                        key = { _, item -> item.exerciseId }
                    ) { exerciseIndex, exercise ->
                        val exerciseDetails = availableExercises.find { it.id == exercise.exerciseId }
                        var dragOffset by remember { mutableFloatStateOf(0f) }

                        RoutineExerciseCard(
                            modifier = Modifier
                                .animateItem()
                                .offset { IntOffset(0, dragOffset.roundToInt()) },
                            exercise = exercise,
                            exerciseDetails = exerciseDetails,
                            unitSystem = unitSystem,
                            showPrev = initialRoutine != null,
                            onUpdateExercise = { updatedExercise ->
                                editableExercises[exerciseIndex] = updatedExercise
                            },
                            onDeleteExercise = { editableExercises.removeAt(exerciseIndex) },
                            onAddSet = {
                                val lastSet = exercise.plannedSets.lastOrNull()
                                val newSet = lastSet?.copy() ?: PlannedSet(
                                    setType = SetType.NORMAL,
                                    targetReps = "",
                                    targetWeight = null
                                )
                                editableExercises[exerciseIndex] = exercise.copy(plannedSets = exercise.plannedSets + newSet)
                            },
                            onUpdateSet = { setIndex, updatedSet ->
                                val updatedSets = exercise.plannedSets.toMutableList()
                                updatedSets[setIndex] = updatedSet
                                editableExercises[exerciseIndex] = exercise.copy(plannedSets = updatedSets)
                            },
                            onDeleteSet = { setIndex ->
                                val updatedSets = exercise.plannedSets.toMutableList().apply {
                                    removeAt(setIndex)
                                }
                                editableExercises[exerciseIndex] = exercise.copy(plannedSets = updatedSets)
                            },
                            onShowTypePicker = { setIndex ->
                                showTypeSheetFor = exerciseIndex to setIndex
                            },
                            onDrag = { deltaY ->
                                dragOffset += deltaY
                                val threshold = 80f // dp-ish
                                if (dragOffset > threshold && exerciseIndex < editableExercises.size - 1) {
                                    val item = editableExercises.removeAt(exerciseIndex)
                                    editableExercises.add(exerciseIndex + 1, item)
                                    dragOffset = 0f
                                } else if (dragOffset < -threshold && exerciseIndex > 0) {
                                    val item = editableExercises.removeAt(exerciseIndex)
                                    editableExercises.add(exerciseIndex - 1, item)
                                    dragOffset = 0f
                                }
                            }
                        )
                    }
                }
            }
        }
    }

    if (showExercisePicker) {
        ExercisePickerDialog(
            availableExercises = availableExercises,
            initialSelectedIds = editableExercises.map { it.exerciseId },
            onDismissRequest = { showExercisePicker = false },
            onExercisesSelected = { selectedExercises ->
                // Efficiently sync list: Remove ones not selected, add new ones
                val currentIds = editableExercises.map { it.exerciseId }.toSet()
                val selectedIds = selectedExercises.map { it.id }.toSet()

                // Remove deselected
                val iterator = editableExercises.iterator()
                while (iterator.hasNext()) {
                    if (iterator.next().exerciseId !in selectedIds) {
                        iterator.remove()
                    }
                }

                // Add new ones
                selectedExercises.forEach { selectedExercise ->
                    if (selectedExercise.id !in currentIds) {
                        editableExercises.add(
                            RoutineExercise(
                                exerciseId = selectedExercise.id,
                                exerciseName = selectedExercise.name,
                                plannedSets = listOf(
                                    PlannedSet(setType = SetType.NORMAL, targetReps = "", targetWeight = null)
                                ),
                                restTimeInSeconds = 90
                            )
                        )
                    }
                }
                showExercisePicker = false
            }
        )
    }

    if (showTypeSheetFor != null) {
        ModalBottomSheet(
            onDismissRequest = { showTypeSheetFor = null },
            sheetState = sheetState,
            containerColor = MaterialTheme.colorScheme.surfaceContainer
        ) {
            val (exIdx, setIdx) = showTypeSheetFor!!
            val currentSet = editableExercises[exIdx].plannedSets[setIdx]
            SetTypeSelectionContent(
                selectedType = currentSet.setType,
                onTypeSelected = { newType ->
                    val updatedSet = currentSet.copy(setType = newType)
                    val updatedSets = editableExercises[exIdx].plannedSets.toMutableList()
                    updatedSets[setIdx] = updatedSet
                    editableExercises[exIdx] = editableExercises[exIdx].copy(plannedSets = updatedSets)
                    scope.launch { sheetState.hide() }.invokeOnCompletion {
                        showTypeSheetFor = null
                    }
                }
            )
        }
    }
}

