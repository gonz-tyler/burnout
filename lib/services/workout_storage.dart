import 'dart:convert';
import 'package:burnout/models/exercise_model.dart';
import 'package:burnout/models/exercise_type.dart';
import 'package:burnout/models/set_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:burnout/models/workout_model.dart';
import 'package:burnout/models/workout_session.dart';
import 'package:burnout/models/exercise_in_workout.dart';
import 'package:burnout/models/exercise_set.dart';

class WorkoutStorage {
  static const String _workoutsKey = 'saved_workouts';
  static const String _sessionsKey = 'workout_sessions';
  static const String _exerciseHistoryKey = 'exercise_history';

  // Save workout templates
  static Future<void> saveWorkouts(List<WorkoutModel> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    final workoutsJson = workouts.map((w) => w.toJson()).toList();
    await prefs.setString(_workoutsKey, jsonEncode(workoutsJson));
  }

  // Load workout templates
  static Future<List<WorkoutModel>> loadWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final workoutsString = prefs.getString(_workoutsKey);
    if (workoutsString == null) return [];
    
    final List<dynamic> workoutsJson = jsonDecode(workoutsString);
    return workoutsJson.map((json) => WorkoutModel.fromJson(json)).toList();
  }

  // Update existing workout template
  static Future<void> updateWorkout(WorkoutModel updatedWorkout) async {
    final workouts = await loadWorkouts();
    final index = workouts.indexWhere((w) => w.id == updatedWorkout.id);
    if (index != -1) {
      workouts[index] = updatedWorkout;
      await saveWorkouts(workouts);
    }
  }

  // Get specific workout by ID
  static Future<WorkoutModel?> getWorkoutById(String workoutId) async {
    final workouts = await loadWorkouts();
    try {
      return workouts.firstWhere((w) => w.id == workoutId);
    } catch (e) {
      return null;
    }
  }

  // Save completed workout session
  static Future<void> saveWorkoutSession(WorkoutSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await loadWorkoutSessions();
    sessions.add(session);
    
    // Keep only last 100 sessions to prevent storage overflow
    if (sessions.length > 100) {
      sessions.removeRange(0, sessions.length - 100);
    }
    
    final sessionsJson = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sessionsKey, jsonEncode(sessionsJson));
    
    // Update exercise history
    await _updateExerciseHistory(session);
  }

  // Load workout sessions
  static Future<List<WorkoutSession>> loadWorkoutSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsString = prefs.getString(_sessionsKey);
    if (sessionsString == null) return [];
    
    final List<dynamic> sessionsJson = jsonDecode(sessionsString);
    return sessionsJson.map((json) => WorkoutSession.fromJson(json)).toList();
  }

  // Update exercise history for quick lookup
  static Future<void> _updateExerciseHistory(WorkoutSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_exerciseHistoryKey);
    
    Map<String, List<Map<String, dynamic>>> history = {};
    if (historyString != null) {
      final Map<String, dynamic> historyJson = jsonDecode(historyString);
      history = historyJson.map((key, value) => 
        MapEntry(key, List<Map<String, dynamic>>.from(value))
      );
    }
    
    // Add new exercise data
    for (final exercise in session.exercises) {
      final exerciseId = exercise.exerciseId;
      if (!history.containsKey(exerciseId)) {
        history[exerciseId] = [];
      }
      
      // Create exercise session entry
      final exerciseSessionData = {
        'date': session.completedAt.toIso8601String(),
        'workoutName': session.workoutName,
        'sets': exercise.sets.map((set) => {
          'setNumber': set.setNumber,
          'setType': set.setType.toString(),
          'actualReps': set.actualReps,
          'actualWeight': set.actualWeight,
          'actualDuration': set.actualDuration?.inSeconds,
          'actualDistance': set.actualDistance,
          'isCompleted': set.isCompleted,
        }).toList(),
      };
      
      history[exerciseId]!.add(exerciseSessionData);
      
      // Keep only last 50 sessions per exercise
      if (history[exerciseId]!.length > 50) {
        history[exerciseId]!.removeAt(0);
      }
    }
    
    await prefs.setString(_exerciseHistoryKey, jsonEncode(history));
  }

  // Get last performance for an exercise
  static Future<ExerciseInWorkout?> getLastExercisePerformance(String exerciseId) async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_exerciseHistoryKey);
    
    if (historyString == null) return null;
    
    final Map<String, dynamic> historyJson = jsonDecode(historyString);
    final List<dynamic>? exerciseHistory = historyJson[exerciseId];
    
    if (exerciseHistory == null || exerciseHistory.isEmpty) return null;
    
    // Get the most recent session
    final lastSession = exerciseHistory.last;
    final List<dynamic> setsData = lastSession['sets'];
    
    final sets = setsData.map((setData) => ExerciseSet(
      setNumber: setData['setNumber'],
      setType: SetType.values.firstWhere((e) => e.toString() == setData['setType']),
      actualReps: setData['actualReps'],
      actualWeight: setData['actualWeight'],
      actualDuration: setData['actualDuration'] != null 
        ? Duration(seconds: setData['actualDuration']) 
        : null,
      actualDistance: setData['actualDistance'],
      isCompleted: setData['isCompleted'] ?? false,
    )).toList();
    
    // Find exercise name and type from saved workouts
    String exerciseName = '';
    String exerciseType = 'Weighted Reps';
    String muscleGroup = '';
    
    final workoutsString = prefs.getString(_workoutsKey);
    if (workoutsString != null) {
      final List<dynamic> workoutsJson = jsonDecode(workoutsString);
      
      // Search for the exercise in all workouts
      outerLoop:
      for (final workoutJson in workoutsJson) {
        final workout = WorkoutModel.fromJson(workoutJson);
        for (final exercise in workout.exercises) {
          if (exercise.exerciseId == exerciseId) {
            exerciseName = exercise.exerciseName;
            exerciseType = exercise.exerciseType;
            muscleGroup = exercise.muscleGroup;
            break outerLoop;
          }
        }
      }
    }
    
    return ExerciseInWorkout(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      sets: sets,
      exerciseType: exerciseType,
      muscleGroup: muscleGroup,
    );
  }

  // Get exercise history for trends
  static Future<List<WorkoutSession>> getExerciseHistory(String exerciseId, {int? limit}) async {
    final sessions = await loadWorkoutSessions();
    final exerciseSessions = sessions.where((session) => 
      session.exercises.any((exercise) => exercise.exerciseId == exerciseId)
    ).toList();
    
    // Sort by date (newest first)
    exerciseSessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    
    if (limit != null && exerciseSessions.length > limit) {
      return exerciseSessions.take(limit).toList();
    }
    
    return exerciseSessions;
  }

  // Get workout statistics
  static Future<Map<String, dynamic>> getWorkoutStats() async {
    final sessions = await loadWorkoutSessions();
    
    if (sessions.isEmpty) {
      return {
        'totalWorkouts': 0,
        'totalSets': 0,
        'averageDuration': 0,
        'streakDays': 0,
      };
    }
    
    final totalWorkouts = sessions.length;
    final totalSets = sessions.fold<int>(0, (sum, session) => 
      sum + session.exercises.fold<int>(0, (exerciseSum, exercise) => 
        exerciseSum + exercise.sets.where((set) => set.isCompleted).length
      )
    );
    
    final totalDuration = sessions.fold<int>(0, (sum, session) => 
      sum + (session.duration?.inMinutes ?? 0)
    );
    final averageDuration = totalDuration / totalWorkouts;
    
    // Calculate current streak
    int streakDays = 0;
    final sortedSessions = sessions..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    
    DateTime? lastWorkoutDate;
    final now = DateTime.now();
    
    for (final session in sortedSessions) {
      final sessionDate = DateTime(
        session.completedAt.year,
        session.completedAt.month,
        session.completedAt.day,
      );
      
      if (lastWorkoutDate == null) {
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(Duration(days: 1));
        
        if (sessionDate == today || sessionDate == yesterday) {
          streakDays = 1;
          lastWorkoutDate = sessionDate;
        } else {
          break;
        }
      } else {
        final expectedDate = lastWorkoutDate.subtract(Duration(days: 1));
        if (sessionDate == expectedDate || sessionDate == lastWorkoutDate) {
          if (sessionDate != lastWorkoutDate) {
            streakDays++;
          }
          lastWorkoutDate = sessionDate;
        } else {
          break;
        }
      }
    }
    
    return {
      'totalWorkouts': totalWorkouts,
      'totalSets': totalSets,
      'averageDuration': averageDuration.round(),
      'streakDays': streakDays,
    };
  }

  // Delete workout template
  static Future<void> deleteWorkout(String workoutId) async {
    final workouts = await loadWorkouts();
    workouts.removeWhere((w) => w.id == workoutId);
    await saveWorkouts(workouts);
  }

  // Clear all data (for testing/reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_workoutsKey);
    await prefs.remove(_sessionsKey);
    await prefs.remove(_exerciseHistoryKey);
  }
}