package com.burnout.app.data.local.entity

import kotlinx.serialization.Serializable

// Embedded inside RoutineExercise.plannedSets, stored as part of the parent
// Routine's JSON blob — mirrors Hive embedding PlannedSet objects directly
// inside a RoutineExercise inside a Routine box entry. Not its own table.
@Serializable
data class PlannedSet(
    val setType: SetType = SetType.NORMAL,
    val targetReps: String? = null, // e.g. "5" or "8-12"
    val targetWeight: Double? = null, // positive for weighted, negative for assisted
    val targetDurationInSeconds: Int? = null,
    val targetDistanceInMeters: Int? = null
)
// Kotlin data classes get .copy() for free — no need to hand-write
// copyWith() the way planned_set.dart does.
