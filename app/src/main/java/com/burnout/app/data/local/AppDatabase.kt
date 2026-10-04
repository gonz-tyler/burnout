package com.burnout.app.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.burnout.app.data.local.dao.BodyMeasurementDao
import com.burnout.app.data.local.dao.ExerciseDao
import com.burnout.app.data.local.dao.RoutineDao
import com.burnout.app.data.local.dao.WorkoutPlanDao
import com.burnout.app.data.local.dao.WorkoutSessionDao
import com.burnout.app.data.local.entity.BodyMeasurement
import com.burnout.app.data.local.entity.Exercise
import com.burnout.app.data.local.entity.Routine
import com.burnout.app.data.local.entity.WorkoutPlan
import com.burnout.app.data.local.entity.WorkoutSession

@Database(
    entities = [
        Exercise::class,
        BodyMeasurement::class,
        Routine::class,
        WorkoutPlan::class,
        WorkoutSession::class
        // RoutineExercise, PlannedSet, PerformedExercise, PerformedSet are
        // NOT listed here — they're embedded as JSON inside their parent
        // entity's column (see Converters.kt), not separate tables.
    ],
    version = 1,
    exportSchema = true
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun exerciseDao(): ExerciseDao
    abstract fun bodyMeasurementDao(): BodyMeasurementDao
    abstract fun routineDao(): RoutineDao
    abstract fun workoutPlanDao(): WorkoutPlanDao
    abstract fun workoutSessionDao(): WorkoutSessionDao
}
