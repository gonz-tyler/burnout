package com.burnout.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.burnout.app.data.local.entity.WorkoutSession

@Dao
interface WorkoutSessionDao {
    @Query("SELECT * FROM workout_sessions ORDER BY dateCompleted ASC")
    fun observeAllSortedByDate(): kotlinx.coroutines.flow.Flow<List<WorkoutSession>>

    @Query("SELECT * FROM workout_sessions ORDER BY dateCompleted ASC")
    suspend fun getAllSortedByDate(): List<WorkoutSession>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(session: WorkoutSession)
}
