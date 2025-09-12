// lib/screens/workout_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../viewmodels/workout_view_model.dart';
import 'workout_details_screen.dart'; // We will create this next

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel to get the list of workout sessions
    final viewModel = context.watch<WorkoutViewModel>();
    final sessions = viewModel.workoutSessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body:
          sessions.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  // Display sessions in reverse chronological order
                  final session = sessions[sessions.length - 1 - index];
                  return _WorkoutHistoryCard(session: session);
                },
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
            Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No History Yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your first workout to see your history here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  final WorkoutSession session;
  const _WorkoutHistoryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<WorkoutViewModel>();
    // Find the routine name using the routineId stored in the session
    final routine = viewModel.routines.firstWhere(
      (r) => r.id == session.routineId,
      orElse: () => Routine(id: '', name: 'Quick Workout', exercises: []),
    );

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 16,
        ),
        title: Text(
          routine.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${session.performedExercises.length} Exercises • ${session.durationInMinutes} min',
          style: TextStyle(color: Colors.grey[600]),
        ),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('d').format(session.dateCompleted), // Day e.g., "12"
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat(
                'MMM',
              ).format(session.dateCompleted), // Month e.g., "Sep"
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WorkoutDetailsScreen(session: session),
            ),
          );
        },
      ),
    );
  }
}
