// lib/services/strength_standards_service.dart

class StrengthStandardsService {
  // Ratios are Multiples of Bodyweight (e.g. 1.5x BW)
  // [Beginner, Novice, Intermediate, Advanced, Elite]

  static Map<String, List<double>> standards = {
    // Push
    'Bench Press': [0.5, 0.8, 1.1, 1.5, 2.0],
    'Incline Bench': [0.4, 0.65, 0.9, 1.25, 1.7],
    'Overhead Press': [0.35, 0.55, 0.8, 1.1, 1.4],
    'Dips': [0.0, 0.3, 0.5, 0.8, 1.2], // Weighted dips (Bodyweight + Added)
    // Pull
    'Deadlift': [0.75, 1.2, 1.6, 2.2, 2.8],
    'Barbell Row': [0.4, 0.6, 0.9, 1.2, 1.5],
    'Pull Up': [0.0, 0.2, 0.4, 0.7, 1.0], // Weighted
    // Legs
    'Squat': [0.75, 1.1, 1.5, 2.0, 2.5],
    'Front Squat': [0.5, 0.85, 1.2, 1.6, 2.0],
    'Leg Press': [1.0, 1.8, 2.5, 3.5, 4.5],
  };

  static String getRankName(int level) {
    switch (level) {
      case 0:
        return "MORTAL"; // Below Beginner
      case 1:
        return "HOPLITE"; // Beginner
      case 2:
        return "LEGIONARY"; // Novice
      case 3:
        return "CENTURION"; // Intermediate
      case 4:
        return "MYRMIDON"; // Advanced
      case 5:
        return "TITAN"; // Elite
      default:
        return "UNKNOWN";
    }
  }

  // Returns {level: 0-5, progress: 0.0-1.0}
  static Map<String, dynamic> calculateRank(
    String exercise,
    double weight,
    double bodyWeight,
  ) {
    if (bodyWeight <= 0) return {'level': 0, 'progress': 0.0, 'nextGoal': 0.0};

    // Find the standard for this exercise (or default to Bench Press ratios if unknown)
    // Normalize exercise strings to match keys
    String key = standards.keys.firstWhere(
      (k) => exercise.toLowerCase().contains(k.toLowerCase()),
      orElse: () => 'Bench Press',
    );

    List<double> ratios = standards[key]!;
    double myRatio = weight / bodyWeight;

    for (int i = 0; i < ratios.length; i++) {
      if (myRatio < ratios[i]) {
        // We are between level i and i+1
        double prev = (i == 0) ? 0 : ratios[i - 1];
        double target = ratios[i];
        double progress = (myRatio - prev) / (target - prev);

        return {
          'level': i,
          'progress': progress.clamp(0.0, 1.0),
          'nextGoal': target * bodyWeight,
          'ratio': myRatio,
        };
      }
    }
    // Titan Level
    return {'level': 5, 'progress': 1.0, 'nextGoal': 0.0, 'ratio': myRatio};
  }
}
