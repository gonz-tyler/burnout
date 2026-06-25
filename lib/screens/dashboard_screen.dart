// lib/screens/dashboard_screen.dart

import 'package:burnout/models/body_measurement.dart';
import 'package:burnout/screens/campaign_screen.dart';
import 'package:burnout/screens/strength_level_screen.dart';
import 'package:burnout/services/labors_service.dart';
import 'package:burnout/services/muscle_analysis_service.dart';
import 'package:burnout/viewmodels/workout_view_model.dart';
import 'package:burnout/widgets/muscle_diagram_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'Week';
  // Data for the Pantheon Scroll
  final List<Map<String, dynamic>> _pantheonGods = [
    {
      "god": "ZEUS",
      "lift": "Bench Press",
      "variations": ["Incline Bench", "Dumbbell Press", "Dips"],
      "color": Colors.cyan.shade600,
      "asset": "assets/data/images/zeus.jpg",
    },
    {
      "god": "HERCULES",
      "lift": "Squat",
      "variations": ["Front Squat", "Leg Press", "Goblet Squat"],
      "color": Colors.red.shade800,
      "asset": "assets/data/images/hercules.jpg",
    },
    {
      "god": "HADES",
      "lift": "Deadlift",
      "variations": ["Romanian Deadlift", "Sumo Deadlift", "Trap Bar"],
      "color": Colors.purple.shade900,
      "asset": "assets/data/images/hades.jpg",
    },
    {
      "god": "ATLAS",
      "lift": "Overhead Press",
      "variations": ["Seated Press", "Arnold Press", "Lateral Raise"],
      "color": Colors.amber.shade700,
      "asset": "assets/data/images/atlas.jpg",
    },
    {
      "god": "POSEIDON",
      "lift": "Barbell Row",
      "variations": ["Pull Up", "Cable Row", "Lat Pulldown"],
      "color": Colors.blue.shade900,
      "asset": "assets/data/images/poseidon.jpg",
    },
    {
      "god": "ARES",
      "lift": "Incline Bench",
      "variations": ["Reverse Grip Bench", "Hammer Strength"],
      "color": Colors.deepOrange.shade900, // War Red
      "asset": "assets/data/images/ares.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final workoutViewModel = context.watch<WorkoutViewModel>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Muscle Data
    final allWorkouts = workoutViewModel.getAllWorkouts();
    final allExercises = workoutViewModel.exercises;
    Map<String, double> muscleIntensity;
    switch (_selectedPeriod) {
      case 'Week':
        muscleIntensity = MuscleAnalysisService.getWeeklyMuscleIntensity(
          allWorkouts,
          allExercises,
        );
        break;
      case 'Month':
        muscleIntensity = MuscleAnalysisService.getMonthlyMuscleIntensity(
          allWorkouts,
          allExercises,
        );
        break;
      case 'All Time':
        muscleIntensity = MuscleAnalysisService.getAllTimeMuscleIntensity(
          allWorkouts,
          allExercises,
        );
        break;
      default:
        muscleIntensity = {};
    }
    final warnings = MuscleAnalysisService.getMuscleImbalanceWarnings(
      muscleIntensity,
    );

    // Aesthetics Data
    final latest = workoutViewModel.latestMeasurement;
    final wristSize = latest?.wristSize ?? 17.5;
    final ideals = workoutViewModel.getIdealProportions(wristSize);

    final labors = LaborsService.checkLabors(workoutViewModel);
    final laborsCompletedCount = labors.where((l) => l.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.dashboardTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CampaignScreen()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The Shield Icon
                  Icon(
                    Icons
                        .shield_outlined, // Filled shield looks better for background
                    size: 28, // Slightly larger to fit text
                    color:
                        laborsCompletedCount == labors.length
                            ? Colors.amber
                            : Colors.grey[600], // Dark grey shield
                  ),

                  // The Count Number
                  Text(
                    "$laborsCompletedCount",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color:
                          laborsCompletedCount == labors.length
                              ? Colors
                                  .black // Black text on Gold shield
                              : Colors.grey[600], // White text on Grey shield
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color:
                        workoutViewModel.didWorkoutToday
                            ? Colors.orange
                            : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${workoutViewModel.currentStreak}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          workoutViewModel.didWorkoutToday
                              ? Colors.orange
                              : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: MUSCLE FOCUS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Muscle Focus",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline, size: 20),
                        onPressed: () => _showMuscleInfoDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPeriodSelector(context),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        MuscleDiagramWidget(muscleIntensity: muscleIntensity),
                        const SizedBox(height: 16),
                        _buildIntensityLegend(context),
                      ],
                    ),
                  ),
                  if (warnings.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      "Insights",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...warnings.map((w) => _buildWarningCard(context, w)),
                  ],

                  const SizedBox(height: 32),

                  // --- SECTION 2: CAREER STATS ---
                  Text(
                    "Career Stats",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFunStatCard(
                          context,
                          title: "Total Tonnage",
                          value:
                              "${(workoutViewModel.totalVolume / 1000).toStringAsFixed(1)}k",
                          unit: "kg",
                          subtitle:
                              "That's ~1 ${workoutViewModel.volumeComparison}!",
                          icon: Icons.monitor_weight_outlined,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFunStatCard(
                          context,
                          title: "Workouts",
                          value: "${workoutViewModel.workoutSessions.length}",
                          unit: "sessions",
                          subtitle: "Consistency is key",
                          icon: Icons.fitness_center,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    "The Pantheon",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2, // Epic feel
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Legendary Feats of Strength",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // The 3 Big Lifts
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: _pantheonGods.length,
                      itemBuilder: (context, index) {
                        final god = _pantheonGods[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: _buildGodCard(
                            context,
                            godName: god["god"],
                            liftName: god["lift"].toString().toUpperCase(),
                            weight: workoutViewModel.getPersonalRecord(
                              god["lift"],
                            ),
                            color: god["color"],
                            assetPath: god["asset"],
                            // 🟢 Pass variations for the detail screen
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => StrengthLevelScreen(
                                        godName: god["god"],
                                        exerciseName: god["lift"],
                                        themeColor: god["color"],
                                        assetPath: god["asset"],
                                        variations: god["variations"],
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- SECTION 3: AESTHETICS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Physique Tracker",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _showMeasurementDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Log Stats"),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildBodyCompCard(context, workoutViewModel.measurements),
                  const SizedBox(height: 12),

                  // 🟢 NEW: V-Taper Analysis
                  _buildVTaperCard(context, latest),
                  const SizedBox(height: 12),

                  _buildIdealsCard(context, latest, ideals),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildGodCard(
    BuildContext context, {
    required String godName,
    required String liftName,
    required double weight,
    required Color color,
    required String assetPath,
    required VoidCallback onTap,
  }) {
    final bool isLocked = weight == 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey[900] : color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isLocked ? Colors.black12 : color.withAlpha(102),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          // Gradient overlay for that "Epic" look
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isLocked
                    ? [Colors.grey.shade800, Colors.black]
                    : [
                      color.withAlpha(230),
                      color.withAlpha(129),
                    ], // Darker to Lighter
          ),
        ),
        child: Stack(
          children: [
            // 1. Background Image (Faded)
            // Ensure you handle missing assets gracefully
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Opacity(
                  opacity: 0.3,
                  // Use a placeholder icon if image fails/is missing
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (c, o, s) => const Icon(
                          Icons.sports_gymnastics,
                          size: 80,
                          color: Colors.white10,
                        ),
                  ),
                ),
              ),
            ),

            // 2. Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        godName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        liftName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  // Weight / Status
                  if (isLocked)
                    Row(
                      children: const [
                        Icon(Icons.lock, color: Colors.white38, size: 16),
                        SizedBox(width: 4),
                        Text(
                          "LOCKED",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${weight.toStringAsFixed(1)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                        const Text(
                          "KG MAX",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🟢 NEW: V-Taper Card
  Widget _buildVTaperCard(BuildContext context, BodyMeasurement? latest) {
    if (latest == null ||
        latest.shoulders == null ||
        latest.waist == null ||
        latest.waist == 0) {
      return const SizedBox.shrink();
    }

    final shoulders = latest.shoulders!;
    final waist = latest.waist!;
    final ratio = shoulders / waist;

    // Logic for rating
    String rating;
    Color color;
    if (ratio < 1.4) {
      rating = "MORTAL"; // Changed from "Developing"
      color = Colors.white70;
    } else if (ratio < 1.55) {
      rating = "HERO";
      color = Colors.white;
    } else if (ratio < 1.65) {
      rating = "DEMIGOD"; // Changed from "Golden V-Taper"
      color = Colors.amberAccent;
    } else {
      rating = "GOD"; // Changed from "Superhero"
      color = Colors.cyanAccent; // Glowing blue/energy look
    }

    return Container(
      height: 220, // Taller to show off the statue
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black, // Fallback color
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        image: const DecorationImage(
          // 🟢 YOU NEED TO ADD THIS IMAGE TO YOUR ASSETS
          image: AssetImage('assets/data/images/greek_statue.jpg'),
          fit: BoxFit.cover,
          // Aligns the top of the image so the head/torso is visible
          alignment: Alignment.topCenter,
        ),
      ),
      child: Stack(
        children: [
          // 1. Gradient Overlay (Darkens the bottom for text readability)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withAlpha(51),
                  Colors.black.withAlpha(229),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // 2. Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Label with spacing
                Row(
                  children: [
                    Icon(Icons.accessibility_new, color: color, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "SHOULDER : WAIST RATIO",
                      style: TextStyle(
                        color: Colors.white.withAlpha(179),
                        fontSize: 12,
                        letterSpacing: 2.0, // "Movie poster" spacing
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // The Big Ratio Number
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ratio.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                        shadows: [
                          Shadow(color: color.withAlpha(128), blurRadius: 20),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: color.withAlpha(128)),
                          borderRadius: BorderRadius.circular(8),
                          color: color.withAlpha(26),
                        ),
                        child: Text(
                          rating,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                // Goal Subtitle
                Text(
                  "GOLDEN RATIO TARGET: 1.618",
                  style: TextStyle(
                    color: Colors.white.withAlpha(128),
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyCompCard(
    BuildContext context,
    List<BodyMeasurement> measurements,
  ) {
    final latest = measurements.isNotEmpty ? measurements.last : null;
    final weight = latest?.weightKg;
    final bf = latest?.bodyFatPercentage;

    String lbmStr = "--";
    String goalWeightStr = "--";

    if (weight != null && bf != null) {
      final lbm = weight * (1 - (bf / 100));
      final goal = lbm / 0.85;
      lbmStr = "${lbm.toStringAsFixed(1)} kg";
      goalWeightStr = "${goal.toStringAsFixed(1)} kg";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surfaceContainer,
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompItem(
                context,
                "Weight",
                weight?.toStringAsFixed(1) ?? "--",
                "kg",
                Icons.scale,
              ),
              Container(
                width: 1,
                height: 50,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              _buildCompItem(
                context,
                "Body Fat",
                bf?.toStringAsFixed(1) ?? "--",
                "%",
                Icons.water_drop_outlined,
              ),
            ],
          ),
          if (weight != null && bf != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSubCompItem("Lean Body Mass", lbmStr),
                _buildSubCompItem("Goal Weight (15% Fat)", goalWeightStr),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompItem(
    BuildContext context,
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 2.0),
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSubCompItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildIdealsCard(
    BuildContext context,
    BodyMeasurement? current,
    Map<String, double> ideals,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.straighten,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Grecian Ideals",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    "Anchor: Wrist ${current?.wristSize ?? 17.5}cm",
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 🟢 CUSTOM: Pass isMaximum=false for Muscles, true for Fat
            _buildIdealRow(
              context,
              "Neck",
              current?.neck,
              ideals['Neck'],
              isMaximum: false,
            ),
            _buildIdealRow(
              context,
              "Shoulders",
              current?.shoulders,
              ideals['Shoulders'],
              isMaximum: false,
            ),
            _buildIdealRow(
              context,
              "Chest",
              current?.chest,
              ideals['Chest'],
              isMaximum: false,
            ),
            // Waist and Hips are "Maximums" - exceeding them is bad
            _buildIdealRow(
              context,
              "Waist",
              current?.waist,
              ideals['Waist'],
              isMaximum: true,
            ),
            _buildIdealRow(
              context,
              "Hips",
              current?.hips,
              ideals['Hips'],
              isMaximum: true,
            ),

            const Divider(height: 1, indent: 20, endIndent: 20),
            _buildSymmetryRow(
              context,
              "Biceps",
              current?.leftBicep,
              current?.rightBicep,
              ideals['Bicep'],
            ),
            _buildSymmetryRow(
              context,
              "Forearms",
              current?.leftForearm,
              current?.rightForearm,
              ideals['Forearm'],
            ),
            _buildSymmetryRow(
              context,
              "Thighs",
              current?.leftThigh,
              current?.rightThigh,
              ideals['Thigh'],
            ),
            _buildSymmetryRow(
              context,
              "Calves",
              current?.leftCalf,
              current?.rightCalf,
              ideals['Calf'],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildIdealRow(
    BuildContext context,
    String label,
    double? current,
    double? ideal, {
    bool isMaximum = false,
  }) {
    final hasValue = current != null && current > 0;
    final valueStr = hasValue ? current.toStringAsFixed(1) : "--";
    final idealStr = ideal != null ? "/ ${ideal.toStringAsFixed(1)}" : "";

    bool isOverflow = false;
    double diffAmount = 0;

    if (hasValue && ideal != null) {
      if (current > ideal) {
        isOverflow = true;
        diffAmount = current - ideal;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      valueStr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        // 🟢 LOGIC: Only red if it's a "Maximum" (Waist/Hips) AND overflowing
                        color: (isMaximum && isOverflow) ? Colors.red : null,
                      ),
                    ),
                    if (ideal != null)
                      Text(
                        " cm $idealStr",
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (hasValue && ideal != null) ...[
                  // 🟢 VISUALIZATION LOGIC
                  if (isOverflow)
                    Stack(
                      children: [
                        // Full Bar
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            // 🟢 If Maximum (Waist): Overflow is RED
                            // 🟢 If Muscle (Chest): Overflow is GREEN (Good!)
                            color:
                                isMaximum
                                    ? Colors.red.withAlpha(204)
                                    : Colors.green.withAlpha(51),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        // The "Ideal" portion
                        if (isMaximum) // Only show the 'good' portion cut if it's a maximum
                          FractionallySizedBox(
                            widthFactor: (ideal / current).clamp(0.0, 1.0),
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          )
                        else // For muscles, if overflowing, fill whole bar green to show 'Bonus'
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                      ],
                    )
                  else
                    // Under Ideal (Standard Progress)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (current / ideal).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                  // 🟢 MESSAGING LOGIC
                  if (isOverflow)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        isMaximum
                            ? "▼ Lose ${diffAmount.toStringAsFixed(1)} cm to goal" // Fat
                            : "▲ +${diffAmount.toStringAsFixed(1)} cm over ideal (Strong!)", // Muscle
                        style: TextStyle(
                          color: isMaximum ? Colors.red : Colors.green[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymmetryRow(
    BuildContext context,
    String label,
    double? left,
    double? right,
    double? ideal,
  ) {
    final lStr = left?.toStringAsFixed(1) ?? "--";
    final rStr = right?.toStringAsFixed(1) ?? "--";
    final idealStr = ideal?.toStringAsFixed(1) ?? "--";

    // For Limbs, usually exceeding ideal is good (muscle), so we don't flag overflow as bad
    // Unless you want strict symmetry checking (L vs R), but that's complex
    // For now we just show values

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildSymBadge("L: $lStr"),
                    const SizedBox(width: 8),
                    _buildSymBadge("R: $rStr"),
                  ],
                ),
                if (ideal != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Goal: $idealStr cm",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- DIALOG & HELPERS ---

  void _showMeasurementDialog(BuildContext context) {
    final controllers = <String, TextEditingController>{};
    for (var key in [
      'weight',
      'fat',
      'neck',
      'shoulders',
      'chest',
      'waist',
      'hips',
      'l_bicep',
      'r_bicep',
      'l_forearm',
      'r_forearm',
      'l_thigh',
      'r_thigh',
      'l_calf',
      'r_calf',
      'wrist',
    ]) {
      controllers[key] = TextEditingController();
    }

    final latest = context.read<WorkoutViewModel>().latestMeasurement;
    if (latest != null) {
      controllers['weight']?.text = latest.weightKg?.toString() ?? '';
      controllers['fat']?.text = latest.bodyFatPercentage?.toString() ?? '';
      controllers['wrist']?.text = latest.wristSize?.toString() ?? '';
      controllers['neck']?.text = latest.neck?.toString() ?? '';
      controllers['shoulders']?.text = latest.shoulders?.toString() ?? '';
      controllers['chest']?.text = latest.chest?.toString() ?? '';
      controllers['waist']?.text = latest.waist?.toString() ?? '';
      controllers['hips']?.text = latest.hips?.toString() ?? '';
      controllers['l_bicep']?.text = latest.leftBicep?.toString() ?? '';
      controllers['r_bicep']?.text = latest.rightBicep?.toString() ?? '';
      controllers['l_forearm']?.text = latest.leftForearm?.toString() ?? '';
      controllers['r_forearm']?.text = latest.rightForearm?.toString() ?? '';
      controllers['l_thigh']?.text = latest.leftThigh?.toString() ?? '';
      controllers['r_thigh']?.text = latest.rightThigh?.toString() ?? '';
      controllers['l_calf']?.text = latest.leftCalf?.toString() ?? '';
      controllers['r_calf']?.text = latest.rightCalf?.toString() ?? '';
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Log Measurements"),
            scrollable: true,
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSectionTitle(context, "Body Composition"),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogInput(
                          controllers['weight']!,
                          "Weight (kg)",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDialogInput(
                          controllers['fat']!,
                          "Body Fat %",
                        ),
                      ),
                    ],
                  ),
                  _buildSectionTitle(context, "Reference"),
                  _buildDialogInput(
                    controllers['wrist']!,
                    "Wrist (cm) - Anchor",
                  ),
                  _buildSectionTitle(context, "Torso"),
                  _buildDialogInput(controllers['neck']!, "Neck (cm)"),
                  _buildDialogInput(
                    controllers['shoulders']!,
                    "Shoulders (cm)",
                  ),
                  _buildDialogInput(controllers['chest']!, "Chest (cm)"),
                  _buildDialogInput(controllers['waist']!, "Waist (cm)"),
                  _buildDialogInput(controllers['hips']!, "Hips (cm)"),
                  _buildSectionTitle(context, "Arms (L / R)"),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogInput(
                          controllers['l_bicep']!,
                          "L Bicep",
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDialogInput(
                          controllers['r_bicep']!,
                          "R Bicep",
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogInput(
                          controllers['l_forearm']!,
                          "L Forearm",
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDialogInput(
                          controllers['r_forearm']!,
                          "R Forearm",
                        ),
                      ),
                    ],
                  ),
                  _buildSectionTitle(context, "Legs (L / R)"),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogInput(
                          controllers['l_thigh']!,
                          "L Thigh",
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDialogInput(
                          controllers['r_thigh']!,
                          "R Thigh",
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogInput(
                          controllers['l_calf']!,
                          "L Calf",
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDialogInput(
                          controllers['r_calf']!,
                          "R Calf",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              FilledButton(
                onPressed: () {
                  final newMeasurement = BodyMeasurement(
                    id: const Uuid().v4(),
                    date: DateTime.now(),
                    weightKg: double.tryParse(controllers['weight']!.text),
                    bodyFatPercentage: double.tryParse(
                      controllers['fat']!.text,
                    ),
                    neck: double.tryParse(controllers['neck']!.text),
                    shoulders: double.tryParse(controllers['shoulders']!.text),
                    chest: double.tryParse(controllers['chest']!.text),
                    waist: double.tryParse(controllers['waist']!.text),
                    hips: double.tryParse(controllers['hips']!.text),
                    leftBicep: double.tryParse(controllers['l_bicep']!.text),
                    rightBicep: double.tryParse(controllers['r_bicep']!.text),
                    leftForearm: double.tryParse(
                      controllers['l_forearm']!.text,
                    ),
                    rightForearm: double.tryParse(
                      controllers['r_forearm']!.text,
                    ),
                    leftThigh: double.tryParse(controllers['l_thigh']!.text),
                    rightThigh: double.tryParse(controllers['r_thigh']!.text),
                    leftCalf: double.tryParse(controllers['l_calf']!.text),
                    rightCalf: double.tryParse(controllers['r_calf']!.text),
                    wristSize: double.tryParse(controllers['wrist']!.text),
                  );
                  context.read<WorkoutViewModel>().addMeasurement(
                    newMeasurement,
                  );
                  // Print max values to console
                  context.read<WorkoutViewModel>().printMaxValues();
                  Navigator.pop(context);
                },
                child: const Text("Save Log"),
              ),
            ],
          ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDialogInput(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // --- EXISTING HELPERS ---

  Widget _buildPeriodSelector(BuildContext context) {
    final periods = ['Week', 'Month', 'All Time'];
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children:
            periods.map((period) {
              final isSelected = _selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = period),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        period,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context, String warning) {
    return Card(
      elevation: 0,
      color: Colors.amber.withAlpha(26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.withAlpha(126)),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                warning,
                style: TextStyle(color: Colors.amber[900], fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntensityLegend(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withAlpha(26),
                Theme.of(context).colorScheme.primary,
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Low Volume',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 10,
              ),
            ),
            Text(
              'High Volume',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakBadge(BuildContext context, WorkoutViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: vm.didWorkoutToday ? Colors.orange : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '${vm.currentStreak}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: vm.didWorkoutToday ? Colors.orange : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: " $unit",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showMuscleInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About Muscle Analysis'),
            content: const Text(
              'This diagram visualizes your workout volume.\n\n- Intensity is relative to your most-worked muscle.\n- Warnings appear if you have major imbalances.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
