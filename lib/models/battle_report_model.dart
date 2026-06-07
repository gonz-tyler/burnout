// lib/models/battle_report_model.dart

class ExerciseResult {
  final String exerciseId;
  final String exerciseName;
  final double weightUsed;
  final bool isPr;
  // User feedback: 1 (Too Light) to 5 (Failed)
  int difficultyRating;
  double nextWeight;

  ExerciseResult({
    required this.exerciseId,
    required this.exerciseName,
    required this.weightUsed,
    required this.isPr,
    this.difficultyRating = 4, // Default to "Good"
    required this.nextWeight,
  });
}
