package com.burnout.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.serialization.Serializable

@Entity(tableName = "routines")
data class Routine(
    @PrimaryKey val id: String,
    val name: String,
    // Stored as a JSON blob via Converters — see the note at the top of
    // this backend's Converters.kt for why nested lists aren't normalized
    // into their own tables.
    val exercises: List<RoutineExercise>,
    val sortOrder: Int? = null
)

// Embedded inside Routine.exercises — not its own table.
@Serializable
data class RoutineExercise(
    val exerciseId: String,
    val exerciseName: String,
    val plannedSets: List<PlannedSet>,
    val restTimeInSeconds: Int
)
