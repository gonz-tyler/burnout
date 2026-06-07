// lib/services/labors_service.dart

import 'package:flutter/material.dart';
import '../viewmodels/workout_view_model.dart';

class Labor {
  final String id;
  final String title;
  final String description;
  final String requirement;
  final String medalAsset;
  final String bgAsset;
  final bool isCompleted;
  final double progress; // 0.0 to 1.0

  Labor({
    required this.id,
    required this.title,
    required this.description,
    required this.requirement,
    required this.medalAsset,
    required this.bgAsset,
    required this.isCompleted,
    required this.progress,
  });
}

class LaborsService {
  static List<Labor> checkLabors(WorkoutViewModel vm) {
    // 1. Get User Stats
    final bodyWeight =
        vm.latestMeasurement?.weightKg ?? 75.0; // Default if missing
    final benchPr = vm.getPersonalRecord("Bench Press");
    final squatPr = vm.getPersonalRecord("Squat");
    final deadliftPr = vm.getPersonalRecord("Deadlift");
    final ohpPr = vm.getPersonalRecord("Overhead Press");
    final totalVolume = vm.totalVolume;
    final workoutCount = vm.workoutSessions.length;

    // 2. Define The 12 Labors
    return [
      _buildLabor(
        id: "1",
        title: "The Nemean Lion",
        desc: "Slay the beast with raw pushing power.",
        reqText: "Bench Press 1.25x Bodyweight",
        medalAsset: "assets/data/images/medals/lion_medal.png",
        bgAsset: "assets/data/images/backgrounds/lion_bg.png",
        current: benchPr,
        target: bodyWeight * 1.25,
      ),
      _buildLabor(
        id: "2",
        title: "The Lernean Hydra",
        desc: "Cut off one head, two more appear. Survive the volume.",
        reqText: "Lift 100,000 kg Total Volume (Lifetime)",
        medalAsset: "assets/data/images/medals/hydra_medal.png",
        bgAsset: "assets/data/images/backgrounds/hydra_bg.png",
        current: totalVolume,
        target: 100000,
      ),
      _buildLabor(
        id: "3",
        title: "The Ceryneian Hind",
        desc: "Catch the golden deer with explosive speed.",
        reqText: "Squat 1.5x Bodyweight",
        medalAsset: "assets/data/images/medals/hind_medal.png",
        bgAsset: "assets/data/images/backgrounds/hind_bg.png",
        current: squatPr,
        target: bodyWeight * 1.5,
      ),
      _buildLabor(
        id: "4",
        title: "The Erymanthian Boar",
        desc: "Wrestle the giant beast into submission.",
        reqText: "Deadlift 2.0x Bodyweight",
        medalAsset: "assets/data/images/medals/boar_medal.png",
        bgAsset: "assets/data/images/backgrounds/boar_bg.png",
        current: deadliftPr,
        target: bodyWeight * 2.0,
      ),
      _buildLabor(
        id: "5",
        title: "The Augean Stables",
        desc: "Clean the filth in a single day.",
        reqText: "Complete 50 Workouts",
        medalAsset: "assets/data/images/medals/stables_medal.png",
        bgAsset: "assets/data/images/backgrounds/stables_bg.png",
        current: workoutCount.toDouble(),
        target: 50,
      ),
      _buildLabor(
        id: "6",
        title: "The Stymphalian Birds",
        desc: "Strike them down from the sky.",
        reqText: "Overhead Press 0.75x Bodyweight",
        medalAsset: "assets/data/images/medals/birds_medal.png",
        bgAsset: "assets/data/images/backgrounds/birds_bg.png",
        current: ohpPr,
        target: bodyWeight * 0.75,
      ),
      _buildLabor(
        id: "7",
        title: "Cretan Bull",
        desc: "Lift the bull with incline bench.",
        reqText: "Incline Bench 1.25x Bodyweight",
        medalAsset: "assets/data/images/medals/bull_medal.png",
        bgAsset: "assets/data/images/backgrounds/bull_bg.png",
        current: 0,
        target: bodyWeight * 1.25,
      ),
      _buildLabor(
        id: "8",
        title: "Mares of Diomedes",
        desc: "Tame the wild horses with leg power.",
        reqText: "Leg Press 3.0x Bodyweight",
        medalAsset: "assets/data/images/medals/mares_medal.png",
        bgAsset: "assets/data/images/backgrounds/mares_bg.png",
        current: 0,
        target: bodyWeight * 3.0,
      ),
      _buildLabor(
        id: "9",
        title: "Belt of Hippolyta",
        desc: "Earn the Amazonian queen's favor.",
        reqText: "Weighted Dips 0.5x Bodyweight",
        medalAsset: "assets/data/images/medals/belt_medal.png",
        bgAsset: "assets/data/images/backgrounds/belt_bg.png",
        current: 0,
        target: bodyWeight * 0.5,
      ),
      _buildLabor(
        id: "10",
        title: "Cattle of Geryon",
        desc: "Herd the cattle with sheer strength.",
        reqText: "Lift 1,000,000 kg Total Volume (Lifetime)",
        medalAsset: "assets/data/images/medals/cattle_medal.png",
        bgAsset: "assets/data/images/backgrounds/cattle_bg.png",
        current: totalVolume,
        target: 1000000,
      ),
      _buildLabor(
        id: "11",
        title: "Apples of Hesperides",
        desc: "Maintain your dedication and consistency.",
        reqText: "30-Day Workout Streak",
        medalAsset: "assets/data/images/medals/apples_medal.png",
        bgAsset: "assets/data/images/backgrounds/apples_bg.png",
        current: vm.currentStreak.toDouble(),
        target: 30,
      ),
      _buildLabor(
        id: "12",
        title: "Cerberus",
        desc: "The final guardian. Master the three heads of strength.",
        reqText: "Big 3 Total (S+B+D) > 450kg",
        medalAsset: "assets/data/images/medals/cerberus_medal.png",
        bgAsset: "assets/data/images/backgrounds/cerberus_bg.png",
        current: benchPr + squatPr + deadliftPr,
        target: 450,
      ),
    ];
  }

  static Labor _buildLabor({
    required String id,
    required String title,
    required String desc,
    required String reqText,
    required String medalAsset,
    required String bgAsset,
    required double current,
    required double target,
  }) {
    return Labor(
      id: id,
      title: title,
      description: desc,
      requirement: reqText,
      medalAsset: medalAsset,
      bgAsset: bgAsset,
      isCompleted: current >= target,
      progress: (current / target).clamp(0.0, 1.0),
    );
  }
}
