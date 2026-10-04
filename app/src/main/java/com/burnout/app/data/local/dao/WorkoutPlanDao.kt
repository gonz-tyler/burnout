package com.burnout.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.burnout.app.data.local.entity.WorkoutPlan

@Dao
interface WorkoutPlanDao {
    @Query("SELECT * FROM workout_plans")
    suspend fun getAll(): List<WorkoutPlan>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(plan: WorkoutPlan)

    @Query("DELETE FROM workout_plans WHERE id = :id")
    suspend fun deleteById(id: String)
}
