package com.burnout.app.domain.notification

import android.content.Context
import androidx.hilt.work.HiltWorker
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.burnout.app.data.datastore.SettingsDataStore
import com.burnout.app.data.repository.WorkoutRepository
import dagger.assisted.Assisted
import dagger.assisted.AssistedInject
import kotlinx.coroutines.flow.first
import java.util.Calendar

@HiltWorker
class ReminderWorker @AssistedInject constructor(
    @Assisted context: Context,
    @Assisted workerParams: WorkerParameters,
    private val repository: WorkoutRepository,
    private val settingsDataStore: SettingsDataStore
) : CoroutineWorker(context, workerParams) {

    override suspend fun doWork(): androidx.work.ListenableWorker.Result {
        return try {
            performWork()
        } catch (e: Exception) {
            android.util.Log.e("ReminderWorker", "Fatal error during background work", e)
            androidx.work.ListenableWorker.Result.retry()
        }
    }

    private suspend fun performWork(): androidx.work.ListenableWorker.Result {
        val notificationManager = applicationContext.getSystemService(android.content.Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        val areNotificationsEnabled = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            notificationManager.areNotificationsEnabled()
        } else true

        if (!areNotificationsEnabled) {
            android.util.Log.w("ReminderWorker", "System-level notifications are DISABLED for this app")
        }

        if (!settingsDataStore.notificationsEnabled.first()) {
            android.util.Log.d("ReminderWorker", "App-level notifications disabled in settings, skipping")
            return androidx.work.ListenableWorker.Result.success()
        }

        // --- 1. Unconditional daily reminder ---
        // Always fires when the worker runs, independent of streak/goal status.
        android.util.Log.d("ReminderWorker", "Sending daily reminder")
        NotificationHelper.showDailyReminderNotification(applicationContext)

        // --- 2. Streak-risk warning (separate, conditional notification) ---
        val weeklyGoal = settingsDataStore.weeklyGoal.first()
        val sessions = repository.getWorkoutSessions()

        val now = Calendar.getInstance()
        val dayOfWeek = now.get(Calendar.DAY_OF_WEEK) // 1=Sun, 2=Mon...

        // Convert to 1=Mon...7=Sun for easier math
        val isoDay = if (dayOfWeek == Calendar.SUNDAY) 7 else dayOfWeek - 1

        val daysRemainingInclToday = 7 - isoDay + 1

        // Filter sessions for the current week (starting Monday)
        val startOfWeek = Calendar.getInstance().apply {
            set(Calendar.DAY_OF_WEEK, Calendar.MONDAY)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (dayOfWeek == Calendar.SUNDAY) add(Calendar.DATE, -7)
        }.timeInMillis

        val currentWeekSessions = sessions.filter { it.dateCompleted >= startOfWeek }
        val daysWorkedThisWeek = currentWeekSessions.map { s ->
            Calendar.getInstance().apply { timeInMillis = s.dateCompleted }.get(Calendar.DAY_OF_YEAR)
        }.distinct().size

        val hasWorkedToday = currentWeekSessions.any { s ->
            val cal = Calendar.getInstance().apply { timeInMillis = s.dateCompleted }
            cal.get(Calendar.YEAR) == now.get(Calendar.YEAR) &&
                    cal.get(Calendar.DAY_OF_YEAR) == now.get(Calendar.DAY_OF_YEAR)
        }

        android.util.Log.d("ReminderWorker", "Check results: WeeklyGoal=$weeklyGoal, DaysWorkedThisWeek=$daysWorkedThisWeek, DaysRemainingInclToday=$daysRemainingInclToday, HasWorkedToday=$hasWorkedToday")

        val streakAtRisk = !hasWorkedToday && (daysWorkedThisWeek + daysRemainingInclToday == weeklyGoal)

        if (streakAtRisk) {
            android.util.Log.d("ReminderWorker", "Sending streak warning")
            NotificationHelper.showStreakWarningNotification(applicationContext)
        } else {
            android.util.Log.d("ReminderWorker", "No streak warning needed")
        }

        return androidx.work.ListenableWorker.Result.success()
    }
}