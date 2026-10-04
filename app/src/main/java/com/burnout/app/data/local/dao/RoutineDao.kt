package com.burnout.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.burnout.app.data.local.entity.Routine
import kotlinx.coroutines.flow.Flow

@Dao
interface RoutineDao {
    @Query("SELECT * FROM routines")
    fun observeAll(): Flow<List<Routine>>

    @Query("SELECT * FROM routines")
    suspend fun getAll(): List<Routine>

    @Query("SELECT * FROM routines WHERE id = :id")
    suspend fun getById(id: String): Routine?

    @Query("SELECT COUNT(*) FROM routines")
    suspend fun count(): Int

    // Room's REPLACE-on-conflict upsert covers both addRoutine and
    // updateRoutine from workout_repository.dart — Hive's box.put(id, ...)
    // was doing the same insert-or-overwrite job under both method names.
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(routine: Routine)

    @Query("DELETE FROM routines WHERE id = :id")
    suspend fun deleteById(id: String)
}
