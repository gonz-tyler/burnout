// lib/screens/active_workout_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../viewmodels/active_workout_view_model.dart';
import '../widgets/performed_set_row.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Routine routine;

  const ActiveWorkoutScreen({super.key, required this.routine});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to safely interact with the provider
    // after the widget has been built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActiveWorkoutViewModel>(
        context,
        listen: false,
      ).startWorkout(widget.routine);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveWorkoutViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isWorkoutStarted) {
          // ... loading indicator
        }

        final currentExercise = viewModel.currentExercise;

        return Scaffold(
          appBar: AppBar(
            // ... existing AppBar ...
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // --- HEADER ROW ---
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text('SET', textAlign: TextAlign.center),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('PREVIOUS', textAlign: TextAlign.center),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('WEIGHT (KG)', textAlign: TextAlign.center),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('REPS', textAlign: TextAlign.center),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 50,
                        child: Text('DONE', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // --- SET LIST ---
                Expanded(
                  child: ListView.builder(
                    itemCount: currentExercise.plannedSets.length,
                    itemBuilder: (context, setIndex) {
                      final plannedSet = currentExercise.plannedSets[setIndex];
                      return PerformedSetRow(
                        plannedSet: plannedSet,
                        setIndex: setIndex,
                        isCompleted: viewModel.isSetCompleted(
                          viewModel.currentExerciseIndex,
                          setIndex,
                        ),
                        onUpdate: (weight, reps) {
                          viewModel.updateSetData(
                            viewModel.currentExerciseIndex,
                            setIndex,
                            weight,
                            reps,
                          );
                        },
                        onCompleted: () {
                          viewModel.completeSet(
                            viewModel.currentExerciseIndex,
                            setIndex,
                          );
                        },
                      );
                    },
                  ),
                ),
                // TODO: Add "Next Exercise" button
              ],
            ),
          ),
        );
      },
    );
  }
}
