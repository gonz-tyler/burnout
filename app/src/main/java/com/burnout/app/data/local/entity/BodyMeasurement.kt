package com.burnout.app.data.local.entity

import android.health.connect.datatypes.units.Percentage
import androidx.room.Entity
import androidx.room.PrimaryKey

// Full port of body_measurement.dart — no longer a placeholder.
@Entity(tableName = "body_measurements")
data class BodyMeasurement(
    @PrimaryKey val id: String,
    val date: Long, // epoch millis
    val weightKg: Double? = null,
    val bodyFatPercentage: Double? = null,
    val goalBodyFatPercentage: Double? = null,
    val neck: Double? = null,
    val shoulders: Double? = null,
    val chest: Double? = null,
    val waist: Double? = null,
    val hips: Double? = null,
    val leftBicep: Double? = null,
    val rightBicep: Double? = null,
    val leftForearm: Double? = null,
    val rightForearm: Double? = null,
    val leftThigh: Double? = null,
    val rightThigh: Double? = null,
    val leftCalf: Double? = null,
    val rightCalf: Double? = null,
    val wristSize: Double? = null,
    val glutes: Double? = null
) {

}
