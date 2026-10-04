package com.burnout.app.data.local

import androidx.room.TypeConverter
import com.burnout.app.data.local.entity.PerformedExercise
import com.burnout.app.data.local.entity.ProgressionProfile
import com.burnout.app.data.local.entity.RoutineExercise
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

// Room only stores primitives natively. Nested lists (Routine.exercises,
// WorkoutSession.performedExercises, WorkoutPlan.routineIds) are stored as
// JSON blobs in a single column instead of being normalized into their own
// tables with foreign keys — this mirrors what Hive was already doing by
// embedding those objects directly inside a parent box entry. If you later
// need to query into individual sets/exercises directly (not just load the
// whole parent), that's the point to normalize instead.
class Converters {
    private val json = Json { ignoreUnknownKeys = true }

    @TypeConverter
    fun fromStringDoubleMap(map: Map<String, Double>): String = json.encodeToString(map)

    @TypeConverter
    fun toStringDoubleMap(value: String): Map<String, Double> =
        if (value.isBlank()) emptyMap() else json.decodeFromString(value)

    @TypeConverter
    fun fromProgressionProfile(profile: ProgressionProfile): String = profile.name

    @TypeConverter
    fun toProgressionProfile(value: String): ProgressionProfile = ProgressionProfile.valueOf(value)

    @TypeConverter
    fun fromRoutineExerciseList(list: List<RoutineExercise>): String = json.encodeToString(list)

    @TypeConverter
    fun toRoutineExerciseList(value: String): List<RoutineExercise> =
        if (value.isBlank()) emptyList() else json.decodeFromString(value)

    @TypeConverter
    fun fromPerformedExerciseList(list: List<PerformedExercise>): String = json.encodeToString(list)

    @TypeConverter
    fun toPerformedExerciseList(value: String): List<PerformedExercise> =
        if (value.isBlank()) emptyList() else json.decodeFromString(value)

    @TypeConverter
    fun fromStringList(list: List<String>): String = json.encodeToString(list)

    @TypeConverter
    fun toStringList(value: String): List<String> =
        if (value.isBlank()) emptyList() else json.decodeFromString(value)
}
