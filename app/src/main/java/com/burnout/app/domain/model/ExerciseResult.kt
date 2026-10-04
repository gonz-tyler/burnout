package com.burnout.app.domain.model

// Port of battle_report_model.dart's ExerciseResult. Built fresh each time
// a workout is reviewed after a session — never written to Room.
data class ExerciseResult(
    val exerciseId: String,
    val exerciseName: String,
    val weightUsed: Double,
    val isPr: Boolean,
    var difficultyRating: Int = 4, // 1 (Too Light) to 5 (Failed); default "Good"
    var nextWeight: Double,
    val weightMode: WeightMode = WeightMode.WEIGHTED,
    val repsAchieved: Int = 0,
    var nextTargetReps: Int? = null
)
