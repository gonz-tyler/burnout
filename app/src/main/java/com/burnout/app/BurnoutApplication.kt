package com.burnout.app

import android.app.Application
import androidx.hilt.work.HiltWorkerFactory
import androidx.work.Configuration
import com.burnout.app.data.local.entity.Exercise
import com.burnout.app.data.repository.WorkoutRepository
import com.burnout.app.domain.notification.NotificationHelper
import dagger.hilt.android.HiltAndroidApp
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json
import kotlinx.serialization.decodeFromString
import javax.inject.Inject

@HiltAndroidApp
class BurnoutApplication : Application(), Configuration.Provider {

    @Inject lateinit var repository: WorkoutRepository
    @Inject lateinit var workerFactory: HiltWorkerFactory

    override val workManagerConfiguration: Configuration
        get() = Configuration.Builder()
            .setWorkerFactory(workerFactory)
            .build()

    override fun onCreate() {
        super.onCreate()
        NotificationHelper.createNotificationChannel(this)
        CoroutineScope(Dispatchers.IO).launch {
            seedExercisesIfEmpty()
        }
    }

    private suspend fun seedExercisesIfEmpty() {
        if (repository.exerciseCount() > 0) return
        val jsonString = assets.open("data/standardized_exercises.json")
            .bufferedReader()
            .use { it.readText() }
        val exercises = Json { ignoreUnknownKeys = true }
            .decodeFromString<List<Exercise>>(jsonString)
        repository.addExercises(exercises)
    }
}
