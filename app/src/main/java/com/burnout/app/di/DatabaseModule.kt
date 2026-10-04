package com.burnout.app.di

import android.content.Context
import androidx.room.Room
import com.burnout.app.data.local.AppDatabase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): AppDatabase =
        Room.databaseBuilder(context, AppDatabase::class.java, "burnout.db").build()

    @Provides
    fun provideExerciseDao(db: AppDatabase) = db.exerciseDao()

    @Provides
    fun provideBodyMeasurementDao(db: AppDatabase) = db.bodyMeasurementDao()

    @Provides
    fun provideRoutineDao(db: AppDatabase) = db.routineDao()

    @Provides
    fun provideWorkoutPlanDao(db: AppDatabase) = db.workoutPlanDao()

    @Provides
    fun provideWorkoutSessionDao(db: AppDatabase) = db.workoutSessionDao()
}
