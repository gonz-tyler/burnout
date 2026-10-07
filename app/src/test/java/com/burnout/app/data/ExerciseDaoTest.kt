package com.burnout.app.data

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import com.burnout.app.data.local.AppDatabase
import com.burnout.app.data.local.dao.ExerciseDao
import com.burnout.app.data.local.entity.Exercise
import com.burnout.app.data.local.entity.ProgressionProfile
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ExerciseDaoTest {
    private lateinit var database: AppDatabase
    private lateinit var exerciseDao: ExerciseDao

    @Before
    fun setup() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        database = Room.inMemoryDatabaseBuilder(context, AppDatabase::class.java)
            .allowMainThreadQueries()
            .build()
        exerciseDao = database.exerciseDao()
    }

    @After
    fun teardown() {
        database.close()
    }

    @Test
    fun insertAndGetById() = runTest {
        val exercise = Exercise(
            id = "ex1",
            name = "Bench Press",
            muscleGroup = "Chest",
            instructions = "Press weight",
            equipment = "Barbell",
            targetedMuscles = mapOf("Pectoralis Major" to 1.0)
        )
        exerciseDao.insert(exercise)

        val fetched = exerciseDao.getById("ex1")
        assertNotNull(fetched)
        assertEquals("Bench Press", fetched?.name)
        assertEquals("Chest", fetched?.muscleGroup)
    }

    @Test
    fun getAllExercises() = runTest {
        val ex1 = Exercise("1", "Pushup", "Chest", "", "Bodyweight", mapOf("Pectoralis Major" to 1.0))
        val ex2 = Exercise("2", "Squat", "Legs", "", "Barbell", mapOf("Quadriceps" to 1.0))
        exerciseDao.insertAll(listOf(ex1, ex2))

        val all = exerciseDao.getAll()
        assertEquals(2, all.size)
    }

    @Test
    fun observeAllFlow() = runTest {
        val ex1 = Exercise("1", "Pullup", "Back", "", "Bodyweight", mapOf("Latissimus Dorsi" to 1.0))
        exerciseDao.insert(ex1)

        val list = exerciseDao.observeAll().first()
        assertEquals(1, list.size)
        assertEquals("Pullup", list[0].name)
    }

    @Test
    fun testHasWeightProgression() = runTest {
        val ex1 = Exercise("ex1", "Pullup", "Back", "", "Bodyweight", mapOf("Latissimus Dorsi" to 1.0), true, false, false, true, true, true)
        exerciseDao.insert(ex1)
        val fetched = exerciseDao.getById("ex1")
        assertEquals(true, fetched?.hasWeightProgression)
        val ex2 = Exercise(
            "ex2",
            "Running",
             "Cardio",
             "Run at a steady pace for a set distance or time, maintaining good form and breathing.",
            "None",
            mapOf(
                "Quadriceps" to 0.4,
                "Hamstrings" to 0.3,
                "Calves" to 0.3
            ),
             false,
             true,
             true,
             false,
             false,
             false,
        )
        exerciseDao.insert(ex2)
        val fetched2 = exerciseDao.getById("ex2")
        assertEquals(false, fetched2?.hasWeightProgression)
        val ex3 = Exercise(
            "ex3",
            "Pushups",
            "Cardio",
            "",
            "None",
            mapOf(
                "Chest" to 0.4,
                "Triceps" to 0.3,
                "Delts" to 0.3
            ),
            true,
            false,
            false,
            false,
            true,
            false,
        )
        exerciseDao.insert(ex3)
        val fetched3 = exerciseDao.getById("ex3")
        assertEquals(true, fetched3?.hasWeightProgression)
    }

    @Test
    fun testIncrementFor() {
        val exercise = Exercise(
            id = "ex_inc",
            name = "Test Exercise",
            muscleGroup = "Chest",
            instructions = "",
            equipment = "Barbell",
            targetedMuscles = mapOf("Chest" to 1.0),
            weightIncrement = 2.5,
            weightIncrementAlt = 1.25
        )

        assertEquals(2.5, exercise.incrementFor(ProgressionProfile.STANDARD), 0.001)
        assertEquals(1.25, exercise.incrementFor(ProgressionProfile.ALT), 0.001)

        val exerciseNoAlt = Exercise(
            id = "ex_inc2",
            name = "Test Exercise 2",
            muscleGroup = "Chest",
            instructions = "",
            equipment = "Barbell",
            targetedMuscles = mapOf("Chest" to 1.0),
            weightIncrement = 5.0,
            weightIncrementAlt = null
        )

        assertEquals(5.0, exerciseNoAlt.incrementFor(ProgressionProfile.STANDARD), 0.001)
        assertEquals(5.0, exerciseNoAlt.incrementFor(ProgressionProfile.ALT), 0.001)
    }

    @Test
    fun testSerialization() {
        val exercise = Exercise(
            id = "ex_ser",
            name = "Squat",
            muscleGroup = "Legs",
            instructions = "Squat down",
            equipment = "Barbell",
            targetedMuscles = mapOf("Quadriceps" to 1.0),
            tracksReps = true,
            weightIncrement = 5.0
        )

        val jsonString = Json.encodeToString(exercise)
        val decoded = Json.decodeFromString<Exercise>(jsonString)

        assertEquals(exercise, decoded)
        assertEquals("Squat", decoded.name)
        assertEquals(true, decoded.tracksReps)
        assertEquals(5.0, decoded.weightIncrement, 0.001)
    }
}
