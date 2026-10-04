package com.burnout.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.burnout.app.data.local.entity.BodyMeasurement

@Dao
interface BodyMeasurementDao {
    @Query("SELECT * FROM body_measurements")
    suspend fun getAll(): List<BodyMeasurement>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(measurement: BodyMeasurement)

    @Query("DELETE FROM body_measurements WHERE id = :id")
    suspend fun deleteById(id: String)
}
