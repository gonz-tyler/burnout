package com.burnout.app.data

import com.burnout.app.data.local.dao.*
import com.burnout.app.data.local.entity.*
import com.burnout.app.data.repository.WorkoutRepository
import io.mockk.*
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test

class WorkoutRepositoryTest {

    private val exerciseDao: ExerciseDao = mockk(relaxed = true)
    private val bodyMeasurementDao: BodyMeasurementDao = mockk(relaxed = true)
    private val routineDao: RoutineDao = mockk(relaxed = true)
    private val workoutPlanDao: WorkoutPlanDao = mockk(relaxed = true)
    private val workoutSessionDao: WorkoutSessionDao = mockk(relaxed = true)

    private lateinit var repository: WorkoutRepository

    @Before
    fun setup() {
        repository = WorkoutRepository(
            exerciseDao,
            bodyMeasurementDao,
            routineDao,
            workoutPlanDao,
            workoutSessionDao
        )
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun getExercisesDelegatesToDao() = runTest {
        val exercises = listOf(Exercise("1", "Pushup", "Chest", "", "Bodyweight", emptyMap()))
        coEvery { exerciseDao.getAll() } returns exercises

        val result = repository.getExercises()
        assertEquals(exercises, result)
        coVerify { exerciseDao.getAll() }
    }

    @Test
    fun getExerciseByIdDelegatesToDao() = runTest {
        val exercise = Exercise("1", "Pushup", "Chest", "", "Bodyweight", emptyMap())
        coEvery { exerciseDao.getById("1") } returns exercise

        val result = repository.getExerciseById("1")
        assertEquals(exercise, result)
        coVerify { exerciseDao.getById("1") }
    }

    @Test
    fun addExercisesDelegatesToDao() = runTest {
        val exercises = listOf(Exercise("1", "Pushup", "Chest", "", "Bodyweight", emptyMap()))
        coEvery { exerciseDao.insertAll(exercises) } just Runs

        repository.addExercises(exercises)
        coVerify { exerciseDao.insertAll(exercises) }
    }

    @Test
    fun exerciseCountDelegatesToDao() = runTest {
        coEvery { exerciseDao.count() } returns 5

        val count = repository.exerciseCount()
        assertEquals(5, count)
        coVerify { exerciseDao.count() }
    }

    @Test
    fun getBodyMeasurementsDelegatesToDao() = runTest {
        val measurements = listOf(BodyMeasurement("m1", 1000L, 70.0))
        coEvery { bodyMeasurementDao.getAll() } returns measurements

        val result = repository.getBodyMeasurements()
        assertEquals(measurements, result)
        coVerify { bodyMeasurementDao.getAll() }
    }

    @Test
    fun addMeasurementDelegatesToDao() = runTest {
        val measurement = BodyMeasurement("m1", 1000L, 70.0)
        coEvery { bodyMeasurementDao.insert(measurement) } just Runs

        repository.addMeasurement(measurement)
        coVerify { bodyMeasurementDao.insert(measurement) }
    }

    @Test
    fun deleteMeasurementDelegatesToDao() = runTest {
        coEvery { bodyMeasurementDao.deleteById("m1") } just Runs

        repository.deleteMeasurement("m1")
        coVerify { bodyMeasurementDao.deleteById("m1") }
    }

    @Test
    fun getRoutinesDelegatesToDao() = runTest {
        val routines = listOf(Routine("r1", "Full Body", emptyList(), 0))
        coEvery { routineDao.getAll() } returns routines

        val result = repository.getRoutines()
        assertEquals(routines, result)
        coVerify { routineDao.getAll() }
    }

    @Test
    fun addRoutineDelegatesToDao() = runTest {
        val routine = Routine("r1", "Full Body", emptyList(), 0)
        coEvery { routineDao.upsert(routine) } just Runs

        repository.addRoutine(routine)
        coVerify { routineDao.upsert(routine) }
    }

    @Test
    fun deleteRoutineDelegatesToDao() = runTest {
        coEvery { routineDao.deleteById("r1") } just Runs

        repository.deleteRoutine("r1")
        coVerify { routineDao.deleteById("r1") }
    }

    @Test
    fun duplicateRoutineCopiesAndUpserts() = runTest {
        val original = Routine("r1", "Upper", emptyList(), 0)
        coEvery { routineDao.getById("r1") } returns original
        coEvery { routineDao.count() } returns 1
        coEvery { routineDao.upsert(any()) } just Runs

        repository.duplicateRoutine("r1")

        coVerify { routineDao.getById("r1") }
        coVerify { routineDao.upsert(match { it.name == "Upper (Copy)" && it.sortOrder == 1 }) }
    }

    @Test
    fun getWorkoutPlansDelegatesToDao() = runTest {
        val plans = listOf(WorkoutPlan("p1", "Plan 1", emptyList()))
        coEvery { workoutPlanDao.getAll() } returns plans

        val result = repository.getWorkoutPlans()
        assertEquals(plans, result)
        coVerify { workoutPlanDao.getAll() }
    }

    @Test
    fun addWorkoutPlanDelegatesToDao() = runTest {
        val plan = WorkoutPlan("p1", "Plan 1", emptyList())
        coEvery { workoutPlanDao.upsert(plan) } just Runs

        repository.addWorkoutPlan(plan)
        coVerify { workoutPlanDao.upsert(plan) }
    }

    @Test
    fun deleteWorkoutPlanDelegatesToDao() = runTest {
        coEvery { workoutPlanDao.deleteById("p1") } just Runs

        repository.deleteWorkoutPlan("p1")
        coVerify { workoutPlanDao.deleteById("p1") }
    }

    @Test
    fun getWorkoutSessionsDelegatesToDao() = runTest {
        val sessions = listOf(WorkoutSession("s1", "r1", 1000L, 30, emptyList()))
        coEvery { workoutSessionDao.getAllSortedByDate() } returns sessions

        val result = repository.getWorkoutSessions()
        assertEquals(sessions, result)
        coVerify { workoutSessionDao.getAllSortedByDate() }
    }

    @Test
    fun addWorkoutSessionDelegatesToDao() = runTest {
        val session = WorkoutSession("s1", "r1", 1000L, 30, emptyList())
        coEvery { workoutSessionDao.insert(session) } just Runs

        repository.addWorkoutSession(session)
        coVerify { workoutSessionDao.insert(session) }
    }
}
