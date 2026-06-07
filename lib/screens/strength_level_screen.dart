// lib/screens/strength_level_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/strength_standards_service.dart';
import '../viewmodels/workout_view_model.dart';

class StrengthLevelScreen extends StatelessWidget {
  final String godName;
  final String exerciseName;
  final Color themeColor;
  final String assetPath;
  final List<String> variations; // e.g. ["Incline Bench", "Dumbbell Press"]

  const StrengthLevelScreen({
    super.key,
    required this.godName,
    required this.exerciseName,
    required this.themeColor,
    required this.assetPath,
    this.variations = const [],
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkoutViewModel>();
    final pr = vm.getPersonalRecord(exerciseName);

    // Get Bodyweight (Default to 75kg if not set)
    final bw = vm.latestMeasurement?.weightKg ?? 75.0;

    final rankData = StrengthStandardsService.calculateRank(
      exerciseName,
      pr,
      bw,
    );
    final int level = rankData['level'];
    final double progress = rankData['progress'];
    final double nextGoal = rankData['nextGoal'];
    final double ratio = rankData['ratio'];
    final String rankTitle = StrengthStandardsService.getRankName(level);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // 1. HERO HEADER
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                godName,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (c, o, s) =>
                              Container(color: themeColor.withOpacity(0.2)),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. MAIN STATS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    "CURRENT MAX",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "${pr.toStringAsFixed(1)} KG",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: themeColor),
                      borderRadius: BorderRadius.circular(20),
                      color: themeColor.withOpacity(0.1),
                    ),
                    child: Text(
                      "$rankTitle (${ratio.toStringAsFixed(2)}x BW)",
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Progress Bar
                  if (level < 5) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Progress to ${StrengthStandardsService.getRankName(level + 1)}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "${nextGoal.toStringAsFixed(1)} kg",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[800],
                        color: themeColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],

                  // 3. VARIATIONS LIST
                  if (variations.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "ALTERNATIVE TRIALS",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...variations.map((variant) {
                      final variantPr = vm.getPersonalRecord(variant);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              variant,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              variantPr > 0
                                  ? "${variantPr.toStringAsFixed(1)} kg"
                                  : "--",
                              style: TextStyle(
                                color:
                                    variantPr > 0
                                        ? Colors.white
                                        : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
