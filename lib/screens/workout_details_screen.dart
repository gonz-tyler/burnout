// lib/screens/workout_details_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../viewmodels/workout_view_model.dart';
import '../models/enums.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final WorkoutSession session;
  const WorkoutDetailsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMd().format(session.dateCompleted)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: session.performedExercises.length,
        itemBuilder: (context, index) {
          final performedExercise = session.performedExercises[index];
          return _PerformedExerciseCard(performedExercise: performedExercise);
        },
      ),
    );
  }
}

class _PerformedExerciseCard extends StatelessWidget {
  final PerformedExercise performedExercise;
  const _PerformedExerciseCard({required this.performedExercise});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<WorkoutViewModel>();
    // Find the exercise details using the exerciseId
    final exercise = viewModel.exercises.firstWhere(
      (ex) => ex.id == performedExercise.exerciseId,
      orElse:
          () => Exercise(
            id: '',
            name: 'Unknown Exercise',
            muscleGroup: '',
            instructions: '',
            equipment: '',
            targetedMuscles: {},
            tracksReps: true,
            tracksDuration: false,
            tracksDistance: false,
            supportsWeight: true,
            supportsBodyweight: false,
            supportsAssistance: false,
          ),
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSetHeader(context),
            const Divider(),
            ...performedExercise.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return _buildSetRow(context, index + 1, set);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSetHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('SET', style: Theme.of(context).textTheme.labelSmall),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'WEIGHT (KG)',
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'REPS',
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(BuildContext context, int setIndex, PerformedSet set) {
    final weightText = set.weight?.toStringAsFixed(1) ?? '--';
    final repsText = set.reps?.toString() ?? '--';
    Color? rowColor;

    if (set.setType == SetType.warmup) {
      rowColor = Colors.orange.withOpacity(0.1);
    } else if (set.setType == SetType.failure) {
      rowColor = Colors.red.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: rowColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              setIndex.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(weightText, textAlign: TextAlign.center),
          ),
          Expanded(flex: 2, child: Text(repsText, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
