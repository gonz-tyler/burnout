// lib/screens/battle_report_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/workout_view_model.dart';
import '../models/routine.dart';
import '../models/battle_report_model.dart';

class BattleReportScreen extends StatefulWidget {
  final List<ExerciseResult> results;
  final String routineId; // To update the saved routine
  final Duration duration;

  const BattleReportScreen({
    super.key,
    required this.results,
    required this.routineId,
    required this.duration,
  });

  @override
  State<BattleReportScreen> createState() => _BattleReportScreenState();
}

class _BattleReportScreenState extends State<BattleReportScreen> {
  // Logic to adjust weight based on feeling
  void _adjustWeight(ExerciseResult result, int rating) {
    setState(() {
      result.difficultyRating = rating;

      // AUTO-REGULATION LOGIC
      switch (rating) {
        case 1: // Dominated (Too Easy) -> +5kg / +10lbs
          result.nextWeight = result.weightUsed + 5.0;
          break;
        case 2: // Easy -> +2.5kg / +5lbs
          result.nextWeight = result.weightUsed + 2.5;
          break;
        case 3: // Good (Standard Progressive Overload) -> +1.25kg or Keep
          result.nextWeight = result.weightUsed + 1.25;
          break;
        case 4: // Hard (Grind) -> Keep Same
          result.nextWeight = result.weightUsed;
          break;
        case 5: // Overwhelmed (Failure) -> Deload -10%
          result.nextWeight = (result.weightUsed * 0.9).roundToDouble();
          break;
      }
    });
  }

  void _finishAndSave(BuildContext context) {
    // 🟢 CALL THE VIEWMODEL TO SAVE CHANGES
    context.read<WorkoutViewModel>().updateRoutineWeights(
      widget.routineId,
      widget.results,
    );

    // Close the screen and go back to Dashboard
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final prCount = widget.results.where((r) => r.isPr).length;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER (Victory Banner)
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade900, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, size: 60, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    "VICTORY",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4.0,
                    ),
                  ),
                  Text(
                    "${widget.duration.inMinutes} MINUTES • $prCount LEGENDARY FEATS",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 2. TACTICAL ADJUSTMENTS LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.results.length,
                itemBuilder: (context, index) {
                  final item = widget.results[index];
                  return _buildAdjustmentCard(item);
                },
              ),
            ),

            // 3. CONFIRM BUTTON
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _finishAndSave(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "ETCH IN STONE",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentCard(ExerciseResult item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.isPr) ...[
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  item.exerciseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${item.weightUsed}kg",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "HOW WAS THE BATTLE?",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),

          // Difficulty Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRatingBtn(item, 1, "EASY", Colors.green),
              _buildRatingBtn(item, 3, "GOOD", Colors.blue),
              _buildRatingBtn(item, 4, "HARD", Colors.orange),
              _buildRatingBtn(item, 5, "FAIL", Colors.red),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 4),

          // Recommendation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "NEXT CAMPAIGN:",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Row(
                children: [
                  if (item.nextWeight > item.weightUsed)
                    const Icon(
                      Icons.arrow_upward,
                      color: Colors.green,
                      size: 14,
                    ),
                  if (item.nextWeight < item.weightUsed)
                    const Icon(
                      Icons.arrow_downward,
                      color: Colors.red,
                      size: 14,
                    ),
                  const SizedBox(width: 4),
                  Text(
                    "${item.nextWeight} kg",
                    style: TextStyle(
                      color:
                          item.nextWeight > item.weightUsed
                              ? Colors.green
                              : (item.nextWeight < item.weightUsed
                                  ? Colors.red
                                  : Colors.white),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBtn(
    ExerciseResult item,
    int rating,
    String label,
    Color color,
  ) {
    final isSelected = item.difficultyRating == rating;
    return GestureDetector(
      onTap: () => _adjustWeight(item, rating),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.grey[800]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
