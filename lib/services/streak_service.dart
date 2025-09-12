// lib/services/streak_service.dart

import 'package:burnout/models/workout_session.dart';

class StreakService {
  bool didWorkoutToday(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) {
      return false;
    }
    final now = DateTime.now();
    final lastWorkoutDate = sessions.last.dateCompleted;

    return now.year == lastWorkoutDate.year &&
        now.month == lastWorkoutDate.month &&
        now.day == lastWorkoutDate.day;
  }

  int calculateStreak(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) {
      return 0;
    }

    final uniqueWorkoutDays =
        sessions
            .map(
              (s) => DateTime(
                s.dateCompleted.year,
                s.dateCompleted.month,
                s.dateCompleted.day,
              ),
            )
            .toSet()
            .toList();

    uniqueWorkoutDays.sort((a, b) => b.compareTo(a));

    if (uniqueWorkoutDays.isEmpty) {
      return 0;
    }

    int streak = 0;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if the most recent workout was today or yesterday to start the streak
    if (uniqueWorkoutDays.first == today ||
        uniqueWorkoutDays.first == yesterday) {
      streak = 1;
      for (int i = 0; i < uniqueWorkoutDays.length - 1; i++) {
        final currentDay = uniqueWorkoutDays[i];
        final nextDay = uniqueWorkoutDays[i + 1];
        final difference = currentDay.difference(nextDay).inDays;

        if (difference == 1) {
          streak++;
        } else {
          break; // Streak is broken
        }
      }
    }

    // If the only workout was today, the streak should be 1.
    if (didWorkoutToday(sessions) && streak == 0 && sessions.length == 1) {
      return 1;
    }

    return streak;
  }
}
