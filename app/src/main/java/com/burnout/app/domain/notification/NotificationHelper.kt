package com.burnout.app.domain.notification

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.compose.ui.res.stringResource
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.burnout.app.MainActivity
import com.burnout.app.R

object NotificationHelper {
    private const val CHANNEL_ID = "daily_reminders"
    private const val CHANNEL_NAME = "Daily Reminders"

    // Separate IDs so the two notifications don't overwrite each other in the tray
    private const val DAILY_REMINDER_ID = 1001
    private const val STREAK_WARNING_ID = 1002
    private const val TEST_NOTIFICATION_ID = 1099

    fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH // Increased importance for pop-up
            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance).apply {
                description = "Notifications for daily workout reminders and streak warnings"
            }
            val notificationManager: NotificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun showNotification(context: Context, notificationId: Int, title: String, message: String) {
        // Double check permission for Android 13+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ActivityCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                return
            }
        }

        // Safely fetch the default launch intent for your app, mimicking a home screen tap.
        // If it can't find it, it falls back to explicit MainActivity routing.
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
            // SINGLE_TOP ensures we don't open duplicate instances of the app if it's already open
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        } ?: Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        // 2. Wrap the Intent in a PendingIntent
        // FLAG_UPDATE_CURRENT ensures any existing pending intent is updated with new data
        val pendingIntent: PendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)

        with(NotificationManagerCompat.from(context)) {
            notify(notificationId, builder.build())
        }
    }

    /** Unconditional daily nudge to work out. Always sent when the worker runs, regardless of streak status. */
    fun showDailyReminderNotification(context: Context) {
        showNotification(
            context,
            DAILY_REMINDER_ID,
            context.getString(R.string.burnout),
            context.getString(R.string.daily_reminder_text)//"Time for your workout!"
        )
    }

    /** Sent only when today is the last day the user can still hit their weekly goal. */
    fun showStreakWarningNotificationHard(context: Context) {
        showNotification(
            context,
            STREAK_WARNING_ID,
            context.getString(R.string.streak_at_risk_title),
            context.getString(R.string.streak_at_risk_message)
        )
    }

    fun showStreakWarningNotificationSoft(context: Context) {
        showNotification(
            context,
            STREAK_WARNING_ID,
            context.getString(R.string.streak_at_risk_title_soft),
            context.getString(R.string.streak_at_risk_message_soft)
        )
    }

    fun showTestNotification(context: Context) {
        showNotification(
            context,
            TEST_NOTIFICATION_ID,
            "Burnout Test Alert",
            "This is a test notification to verify your system alerts are working correctly!"
        )
    }
}