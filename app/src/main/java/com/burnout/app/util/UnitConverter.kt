package com.burnout.app.util

import kotlin.math.round

enum class UnitSystem { METRIC, IMPERIAL }
enum class WeightUnit { KG, LBS }
enum class DistanceUnit { KM, MILES }

object WeightConverter {
    private const val LBS_PER_KG = 2.20462262

    /** Converts KG from Database -> LBS for UI. */
    fun displayWeight(weightInKg: Double?, system: UnitSystem): Double {
        if (weightInKg == null || weightInKg == 0.0) return 0.0
        if (system == UnitSystem.METRIC) return weightInKg
        return round(weightInKg * LBS_PER_KG * 10.0) / 10.0
    }

    /** Converts UI input in LBS -> KG for Database storage. */
    fun saveWeight(inputWeight: Double?, system: UnitSystem): Double? {
        if (inputWeight == null || inputWeight == 0.0) return null
        if (system == UnitSystem.METRIC) return inputWeight
        return inputWeight / LBS_PER_KG
    }
}

object LengthConverter {
    private const val INCHES_PER_CM = 0.393700787

    /** Converts CM from Database -> INCHES for UI. */
    fun displayLength(lengthInCm: Double?, system: UnitSystem): Double {
        if (lengthInCm == null || lengthInCm == 0.0) return 0.0
        if (system == UnitSystem.METRIC) return lengthInCm
        return round(lengthInCm * INCHES_PER_CM * 10.0) / 10.0
    }

    /** Converts UI input in INCHES -> CM for Database storage. */
    fun saveLength(inputLength: Double?, system: UnitSystem): Double? {
        if (inputLength == null || inputLength == 0.0) return null
        if (system == UnitSystem.METRIC) return inputLength
        return inputLength / INCHES_PER_CM
    }
}