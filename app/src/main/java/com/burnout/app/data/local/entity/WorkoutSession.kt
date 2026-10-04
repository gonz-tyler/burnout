package com.burnout.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.serialization.Serializable

@Entity(tableName = "workout_sessions")
data class WorkoutSession(
    @PrimaryKey val id: String,
    val routineId: String? = null,
    val dateCompleted: Long, // epoch millis
    val durationInMinutes: Int,
    val performedExercises: List<PerformedExercise>, // JSON via Converters
    val userFeedbackRPE: Int? = null
)

// Embedded inside WorkoutSession.performedExercises — not its own table.
@Serializable
data class PerformedExercise(
    val exerciseId: String,
    val sets: List<PerformedSet>
)

// Embedded inside PerformedExercise.sets — not its own table.
@Serializable
data class PerformedSet(
    val setType: SetType,
    val reps: Int? = null,
    val weight: Double? = null,
    val durationInSeconds: Int? = null,
    // Kept as Int to match workout_session.dart's field exactly, despite
    // the "Kilometers" name suggesting it should be a finer-grained unit —
    // that's a pre-existing naming quirk in the Dart model, not something
    // introduced here.
    val distanceInKilometers: Int? = null,
)
