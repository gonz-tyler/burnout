// lib/services/streak_service.dart

import '../models/workout_session.dart';

class StreakService {
  /// Calculates the user's current workout streak based on a rolling cadence.
  ///
  /// [sessions]: A list of all historical workout sessions, sorted by date ascending.
  /// [streakCadenceInDays]: The number of days a user has to complete a workout
  ///                        before the streak breaks (e.g., 3 days).
  int calculateStreak({
    required List<WorkoutSession> sessions,
    required int streakCadenceInDays,
  }) {
    if (sessions.isEmpty) {
      return 0;
    }

    sessions.sort((a, b) => a.dateCompleted.compareTo(b.dateCompleted));
    final List<WorkoutSession> filteredSessions = _filterSameDayWorkouts(
      sessions,
    );

    if (filteredSessions.isEmpty) {
      return 0;
    }

    int currentStreak = 0;
    DateTime? deadline;

    for (final session in filteredSessions) {
      final sessionDate = session.dateCompleted;

      if (deadline == null) {
        currentStreak = 1;
      } else {
        if (!sessionDate.isAfter(deadline)) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      }
      deadline = _calculateNextDeadline(sessionDate, streakCadenceInDays);
    }

    if (deadline != null && DateTime.now().isAfter(deadline)) {
      return 0;
    }

    return currentStreak;
  }

  DateTime _calculateNextDeadline(
    DateTime currentWorkoutDate,
    int cadenceDays,
  ) {
    final nextDate = currentWorkoutDate.add(Duration(days: cadenceDays));
    return DateTime(nextDate.year, nextDate.month, nextDate.day, 23, 59, 59);
  }

  List<WorkoutSession> _filterSameDayWorkouts(List<WorkoutSession> sessions) {
    final Map<DateTime, WorkoutSession> uniqueDaySessions = {};
    for (final session in sessions) {
      final dateOnly = DateTime(
        session.dateCompleted.year,
        session.dateCompleted.month,
        session.dateCompleted.day,
      );
      if (!uniqueDaySessions.containsKey(dateOnly)) {
        uniqueDaySessions[dateOnly] = session;
      }
    }
    return uniqueDaySessions.values.toList();
  }
}
