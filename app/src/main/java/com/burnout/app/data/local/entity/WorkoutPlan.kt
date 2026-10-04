package com.burnout.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "workout_plans")
data class WorkoutPlan(
    @PrimaryKey val id: String,
    val name: String,
    val routineIds: List<String> // stored as JSON via Converters
)
