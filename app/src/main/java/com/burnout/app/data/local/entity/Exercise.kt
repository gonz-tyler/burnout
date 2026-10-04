package com.burnout.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.serialization.Serializable

// Direct port of lib/models/exercise.dart. Field names and defaults match
// exactly so the same standardized_exercises.json asset can seed both apps.
@Serializable
@Entity(tableName = "exercises")
data class Exercise(
    @PrimaryKey val id: String,
    val name: String,
    val muscleGroup: String,
    val instructions: String,
    val equipment: String,
    val targetedMuscles: Map<String, Double>,
    val tracksReps: Boolean = false,
    val tracksDuration: Boolean = false,
    val tracksDistance: Boolean = false,
    val supportsWeight: Boolean = false,
    val supportsBodyweight: Boolean = false,
    val supportsAssistance: Boolean = false,
    val weightIncrement: Double = 2.5,
    val weightIncrementAlt: Double? = null,
    val lowRepThreshold: Int? = null
) {
    // Cardio (or anything with no weight/bodyweight/assistance relevance)
    // has nothing for the battle-report weight quiz to adjust.
    val hasWeightProgression: Boolean
        get() = supportsWeight || supportsBodyweight || supportsAssistance

    /** Base ("GOOD" rating) increment to use, given the chosen progression profile. */
    fun incrementFor(profile: ProgressionProfile): Double =
        if (profile == ProgressionProfile.ALT && weightIncrementAlt != null) {
            weightIncrementAlt
        } else {
            weightIncrement
        }
}
