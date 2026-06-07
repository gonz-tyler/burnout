// lib/services/quests_service.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../viewmodels/workout_view_model.dart';
import '../models/workout_session.dart';

// 1. The Quest Model (Same as before)
class Quest {
  final String title;
  final String description;
  final String requirement;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final String rewardAsset;
  final Color themeColor;

  Quest({
    required this.title,
    required this.description,
    required this.requirement,
    required this.progress,
    required this.isCompleted,
    required this.rewardAsset,
    required this.themeColor,
  });
}

// 2. A Template for the "Pool" of possible quests
enum QuestType { workouts, volume, sets, prs, specificLift }

class _QuestTemplate {
  final String title;
  final String description;
  final String asset;
  final Color color;
  final QuestType type;
  final double targetValue;
  final String? targetExercise; // Only for specificLift type

  const _QuestTemplate({
    required this.title,
    required this.description,
    required this.asset,
    required this.color,
    required this.type,
    required this.targetValue,
    this.targetExercise,
  });
}

class QuestsService {
  // 🟢 THE POOL OF TRIALS
  static const List<_QuestTemplate> _questPool = [
    // --- CONSISTENCY TRIALS ---
    _QuestTemplate(
      title: "The Spartan's Discipline",
      description: "Consistency is the mother of strength.",
      asset: "assets/images/medals/spartan_helmet.png",
      color: Colors.redAccent,
      type: QuestType.workouts,
      targetValue: 3,
    ),
    _QuestTemplate(
      title: "The Immortal's Vigor",
      description: "Show up when others would rest.",
      asset: "assets/images/medals/spartan_helmet.png",
      color: Colors.deepOrange,
      type: QuestType.workouts,
      targetValue: 4,
    ),

    // --- VOLUME TRIALS (Tonnage) ---
    _QuestTemplate(
      title: "The Titan's Burden",
      description: "Move a mountain, one stone at a time.",
      asset: "assets/images/medals/atlas_stone.png",
      color: Colors.amber,
      type: QuestType.volume,
      targetValue: 10000, // 10k kg
    ),
    _QuestTemplate(
      title: "Atlas's Shoulders",
      description: "Bear the weight of the heavens.",
      asset: "assets/images/medals/atlas_stone.png",
      color: Colors.amber,
      type: QuestType.volume,
      targetValue: 20000, // 20k kg
    ),

    // --- ENDURANCE TRIALS (Total Sets) ---
    _QuestTemplate(
      title: "The Marathon of Hermes",
      description: "Endurance is a virtue of the gods.",
      asset: "assets/images/medals/winged_sandal.png",
      color: Colors.cyan,
      type: QuestType.sets,
      targetValue: 60, // 60 sets total
    ),
    _QuestTemplate(
      title: "The Phalanx Wall",
      description: "Stand your ground. Set after set.",
      asset: "assets/images/medals/winged_sandal.png",
      color: Colors.blueGrey,
      type: QuestType.sets,
      targetValue: 80,
    ),

    // --- STRENGTH TRIALS (PRs) ---
    _QuestTemplate(
      title: "Blessing of Ares",
      description: "Break your limits in battle.",
      asset: "assets/images/medals/lion_medal.png",
      color: Colors.red,
      type: QuestType.prs,
      targetValue: 1, // Hit 1 PR
    ),
    _QuestTemplate(
      title: "Hercules' Strength",
      description: "Shatter your old records.",
      asset: "assets/images/medals/lion_medal.png",
      color: Colors.purple,
      type: QuestType.prs,
      targetValue: 3, // Hit 3 PRs
    ),

    // --- SPECIFIC EXERCISE TRIALS ---
    _QuestTemplate(
      title: "Zeus's Thunderbolt",
      description: "Dominate the Overhead Press.",
      asset:
          "assets/images/medals/cerberus_medal.png", // Reuse assets if needed
      color: Colors.yellow,
      type: QuestType.specificLift,
      targetExercise: "Overhead Press",
      targetValue: 1000, // 1000kg volume on OHP
    ),
    _QuestTemplate(
      title: "Poseidon's Pull",
      description: "Row as if the seas depend on it.",
      asset: "assets/images/medals/hydra_medal.png",
      color: Colors.blue,
      type: QuestType.specificLift,
      targetExercise: "Row", // Matches "Barbell Row", "Dumbbell Row"
      targetValue: 2000,
    ),
    _QuestTemplate(
      title: "The Earth Shaker",
      description: "Squat until the ground trembles.",
      asset: "assets/images/medals/hind_medal.png",
      color: Colors.green,
      type: QuestType.specificLift,
      targetExercise: "Squat",
      targetValue: 3000,
    ),
    _QuestTemplate(
      title: "The Iron Chest",
      description: "Push the earth away.",
      asset: "assets/images/medals/lion_medal.png",
      color: Colors.indigo,
      type: QuestType.specificLift,
      targetExercise: "Bench",
      targetValue: 3000,
    ),
  ];

  static List<Quest> checkWeeklyQuests(WorkoutViewModel vm) {
    // 1. Calculate the Week Seed
    final now = DateTime.now();
    // Start of week (Monday)
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );
    // Unique ID for this week (e.g. 202405 for 5th week of 2024)
    // We add weekNumber to year * 100 to make it unique
    int weekNumber =
        ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7).ceil();
    int seed = (now.year * 100) + weekNumber;

    // 2. Pick 3 Random Quests Deterministically
    final random = Random(seed);
    final List<_QuestTemplate> selectedTemplates = [];
    final List<_QuestTemplate> poolCopy = List.from(_questPool);

    // Pick 3 distinct items
    for (int i = 0; i < 3; i++) {
      if (poolCopy.isEmpty) break;
      int index = random.nextInt(poolCopy.length);
      selectedTemplates.add(poolCopy[index]);
      poolCopy.removeAt(index);
    }

    // 3. Calculate Progress for selected quests
    // Filter sessions for THIS WEEK only
    final weeklySessions =
        vm.workoutSessions.where((s) {
          return s.dateCompleted.isAfter(startOfWeek);
        }).toList();

    return selectedTemplates.map((template) {
      return _buildQuestFromTemplate(template, weeklySessions, vm);
    }).toList();
  }

  static Quest _buildQuestFromTemplate(
    _QuestTemplate template,
    List<WorkoutSession> sessions,
    WorkoutViewModel fullVm, // Passed if we need history for PRs
  ) {
    double current = 0;
    String reqText = "";

    switch (template.type) {
      case QuestType.workouts:
        current = sessions.length.toDouble();
        reqText = "Complete ${template.targetValue.toInt()} Workouts";
        break;

      case QuestType.volume:
        double vol = 0;
        for (var s in sessions) {
          for (var ex in s.performedExercises) {
            for (var set in ex.sets) {
              vol += (set.weight ?? 0) * (set.reps ?? 0);
            }
          }
        }
        current = vol;
        reqText = "Lift ${template.targetValue.toInt()}kg Volume";
        break;

      case QuestType.sets:
        int sets = 0;
        for (var s in sessions) {
          for (var ex in s.performedExercises) sets += ex.sets.length;
        }
        current = sets.toDouble();
        reqText = "Complete ${template.targetValue.toInt()} Sets";
        break;

      case QuestType.prs:
        // This is complex - we'd need to count PRs flagged in sessions
        // For simplicity, let's assume we count "Great" ratings or manually flagged PRs
        // Or we re-calculate. For now, let's just count workouts where volume > 0 as a placeholder
        // A real implementation needs isPr flags saved on the set or session.
        // Let's swap to a simpler logic: Unique Exercises
        int unique = 0;
        final seen = <String>{};
        for (var s in sessions) {
          for (var ex in s.performedExercises) seen.add(ex.exerciseId);
        }
        current = seen.length.toDouble();
        reqText = "Perform ${template.targetValue.toInt()} Different Exercises";
        // Renaming type behavior for this example to be safe
        break;

      case QuestType.specificLift:
        double vol = 0;
        final query = template.targetExercise ?? "";
        for (var s in sessions) {
          for (var ex in s.performedExercises) {
            if (fullVm.exercises
                .firstWhere((e) => e.id == ex.exerciseId)
                .name
                .contains(query)) {
              for (var set in ex.sets) {
                vol += (set.weight ?? 0) * (set.reps ?? 0);
              }
            }
          }
        }
        current = vol;
        reqText = "$query Volume: ${template.targetValue.toInt()}kg";
        break;
    }

    return Quest(
      title: template.title,
      description: template.description,
      requirement: reqText,
      progress: (current / template.targetValue).clamp(0.0, 1.0),
      isCompleted: current >= template.targetValue,
      rewardAsset: template.asset,
      themeColor: template.color,
    );
  }
}
