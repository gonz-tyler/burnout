// lib/widgets/routine_card.dart

import 'package:flutter/material.dart';
import '../models/models.dart'; // Make sure this path is correct for your project

class RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onStart,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    // --- Calculations ---
    // Calculate the total number of sets in the entire routine
    final int totalSets = routine.exercises.fold(
      0,
      (sum, exercise) => sum + exercise.plannedSets.length,
    );

    // Get the first 3 exercises to display, or fewer if the routine is short
    final displayedExercises = routine.exercises.take(3);

    // Calculate how many exercises are left over
    final int remainingExercisesCount =
        routine.exercises.length - displayedExercises.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Row: Routine Name & Menu ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    routine.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildPopupMenu(),
              ],
            ),
            const SizedBox(height: 4),

            // --- Subtitle: Total Sets ---
            Text(
              '$totalSets Total Sets',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const Divider(height: 24),

            // --- Middle Section: Exercise List ---
            if (displayedExercises.isNotEmpty)
              Column(
                children:
                    displayedExercises.map((exercise) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(exercise.exerciseName),
                            Text(
                              '${exercise.plannedSets.length} sets',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              )
            else
              const Text('This routine has no exercises yet.'),

            const SizedBox(height: 16),

            // --- Bottom Row: "X more" & Start Button ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (remainingExercisesCount > 0)
                  Text(
                    'and $remainingExercisesCount more...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  const Spacer(), // Use a Spacer if there's no "more" text

                FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Routine'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for the three-dot menu
  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'duplicate':
            onDuplicate();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy_outlined),
                title: Text('Duplicate'),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red[700]),
                title: Text('Delete', style: TextStyle(color: Colors.red[700])),
              ),
            ),
          ],
    );
  }
}
