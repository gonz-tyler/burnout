// lib/widgets/routine_card.dart

import 'package:flutter/material.dart';
import 'package:path/path.dart';
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
      // 🟢 COMPACT: Reduced margins
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      elevation: 1.0, // 🟢 COMPACT: Lower elevation for a flatter look
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        // 🟢 COMPACT: Reduced internal padding from 16 to 12
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Row: Name & Menu ---
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 🟢 COMPACT: Moved "Total Sets" here to save vertical space
                      Text(
                        '$totalSets Sets • ${routine.exercises.length} Exercises',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPopupMenu(Theme.of(context).colorScheme.surface),
              ],
            ),

            // 🟢 COMPACT: Removed Divider and large SizedBox
            const SizedBox(height: 12),

            // --- Middle Section: Exercise List ---
            if (displayedExercises.isNotEmpty)
              Column(
                children:
                    displayedExercises.map((exercise) {
                      return Padding(
                        // 🟢 COMPACT: Tighter list spacing (3.0 -> 1.0)
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                exercise.exerciseName,
                                style: Theme.of(context).textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${exercise.plannedSets.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              )
            else
              Text(
                'Empty routine',
                style: Theme.of(context).textTheme.bodySmall,
              ),

            const SizedBox(height: 12),

            // --- Bottom Row: Start Button ---
            Row(
              children: [
                if (remainingExercisesCount > 0)
                  Text(
                    '+ $remainingExercisesCount more',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const Spacer(),

                // 🟢 COMPACT: Smaller Button
                SizedBox(
                  height: 36,
                  child: FilledButton.icon(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Start'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for the three-dot menu
  Widget _buildPopupMenu(bgColor) {
    return PopupMenuButton<String>(
      color: bgColor,
      borderRadius: BorderRadius.circular(24.0),
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
