package com.burnout.app.data.repository

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
import kotlinx.coroutines.flow.Flow
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

// Full port of workout_repository.dart's public surface — one façade over
// all five DAOs, injected into ViewModels. No init()/open() step needed;
// Room's database instance is provided already-built by DatabaseModule.
@Singleton
class WorkoutRepository @Inject constructor(
    private val exerciseDao: ExerciseDao,
    private val bodyMeasurementDao: BodyMeasurementDao,
    private val routineDao: RoutineDao,
    private val workoutPlanDao: WorkoutPlanDao,
    private val workoutSessionDao: WorkoutSessionDao
) {
    // --- EXERCISES ---
    fun observeExercises(): Flow<List<Exercise>> = exerciseDao.observeAll()

    suspend fun getExercises(): List<Exercise> = exerciseDao.getAll()

    suspend fun getExerciseById(id: String): Exercise? = exerciseDao.getById(id)

    suspend fun addExercises(exercises: List<Exercise>) = exerciseDao.insertAll(exercises)

    suspend fun exerciseCount(): Int = exerciseDao.count()

    // --- BODY MEASUREMENTS ---
    suspend fun getBodyMeasurements(): List<BodyMeasurement> =
        bodyMeasurementDao.getAll().sortedBy { it.date }

    suspend fun addMeasurement(measurement: BodyMeasurement) =
        bodyMeasurementDao.insert(measurement)

    suspend fun deleteMeasurement(id: String) = bodyMeasurementDao.deleteById(id)

    // --- ROUTINES ---
    fun observeRoutines(): Flow<List<Routine>> = routineDao.observeAll()

    suspend fun getRoutines(): List<Routine> = routineDao.getAll()

    // addRoutine and updateRoutine both just upsert — Hive's box.put(id, ...)
    // did the same insert-or-overwrite job under both Dart method names.
    suspend fun addRoutine(routine: Routine) = routineDao.upsert(routine)

    suspend fun updateRoutine(routine: Routine) = routineDao.upsert(routine)

    suspend fun deleteRoutine(id: String) = routineDao.deleteById(id)

    suspend fun duplicateRoutine(id: String) {
        val original = routineDao.getById(id) ?: return
        val duplicated = original.copy(
            id = UUID.randomUUID().toString(),
            name = "${original.name} (Copy)",
            sortOrder = routineDao.count()
        )
        routineDao.upsert(duplicated)
    }

    // --- WORKOUT PLANS ---
    suspend fun getWorkoutPlans(): List<WorkoutPlan> = workoutPlanDao.getAll()

    suspend fun addWorkoutPlan(plan: WorkoutPlan) = workoutPlanDao.upsert(plan)

    suspend fun deleteWorkoutPlan(id: String) = workoutPlanDao.deleteById(id)

    // --- WORKOUT SESSIONS ---
    fun observeWorkoutSessions(): Flow<List<WorkoutSession>> =
        workoutSessionDao.observeAllSortedByDate()

    suspend fun getWorkoutSessions(): List<WorkoutSession> =
        workoutSessionDao.getAllSortedByDate()

    suspend fun addWorkoutSession(session: WorkoutSession) =
        workoutSessionDao.insert(session)
}
