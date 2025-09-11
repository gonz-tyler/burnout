// lib/screens/workouts_screen.dart

import 'package:burnout/screens/active_workout_screen.dart';
import 'package:burnout/screens/routine_editor_screen.dart';
import 'package:burnout/viewmodels/active_workout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/workout_view_model.dart';
import '../models/routine.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/routine_card.dart';
// import 'routine_editor_screen.dart'; // We will create this screen next

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({Key? key}) : super(key: key);

  void _createNewRoutine(BuildContext context) {
    // Navigate to the screen where a user builds a new routine.
    // Navigator.push(context, MaterialPageRoute(builder: (_) => RoutineEditorScreen()));
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RoutineEditorScreen()));
  }

  void _startWorkout(BuildContext context, Routine routine) {
    // Navigate to the live workout screen, passing the selected routine.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting workout: ${routine.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutViewModel = context.watch<WorkoutViewModel>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.workoutsTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
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
      body: Consumer<WorkoutViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.routines.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.routines.length,
            itemBuilder: (context, index) {
              final routine = viewModel.routines[index];
              // return Card(
              //   elevation: 2.0,
              //   margin: const EdgeInsets.symmetric(vertical: 8.0),
              //   child: ListTile(
              //     title: Text(
              //       routine.name,
              //       style: const TextStyle(fontWeight: FontWeight.bold),
              //     ),
              //     subtitle: Text('${routine.exercises.length} exercises'),
              //     trailing: const Icon(Icons.arrow_forward_ios),
              //     onTap: () => _startWorkout(context, routine),
              //   ),
              // );
              return RoutineCard(
                routine: routine,
                onStart: () {
                  print('Starting routine: ${routine.name}');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      // We wrap the new screen in a ChangeNotifierProvider
                      // so it and its children can access the ActiveWorkoutViewModel.
                      builder:
                          (_) => ChangeNotifierProvider(
                            create: (_) => ActiveWorkoutViewModel(),
                            child: ActiveWorkoutScreen(routine: routine),
                          ),
                    ),
                  );
                },
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => RoutineEditorScreen(initialRoutine: routine),
                    ),
                  );
                },
                onDelete: () {
                  // Show a confirmation dialog before deleting
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Delete Routine?'),
                        content: Text(
                          'Are you sure you want to delete "${routine.name}"? This action cannot be undone.',
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(
                                dialogContext,
                              ).pop(); // Close the dialog
                            },
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                            onPressed: () {
                              // Use the ViewModel from the parent context
                              // --- ADD THIS ---
                              final viewModel =
                                  context.read<WorkoutViewModel>();
                              print(
                                '❌ Attempting to delete. Using ViewModel with HashCode: ${viewModel.hashCode}',
                              );
                              // ---------------

                              viewModel.deleteRoutine(
                                routine.id,
                              ); // Use the variable we just made
                              Navigator.of(
                                dialogContext,
                              ).pop(); // Close the dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                onDuplicate: () {
                  context.read<WorkoutViewModel>().duplicateRoutine(routine.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewRoutine(context),
        child: const Icon(Icons.add),
        tooltip: 'Create Routine',
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Routines Yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Create workout routines to track your progress and stay organized.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
