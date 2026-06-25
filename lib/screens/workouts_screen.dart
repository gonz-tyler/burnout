// lib/screens/workouts_screen.dart

import 'package:burnout/screens/active_workout_screen.dart';
import 'package:burnout/screens/campaign_screen.dart';
import 'package:burnout/screens/routine_editor_screen.dart';
import 'package:burnout/services/labors_service.dart';
import 'package:burnout/viewmodels/active_workout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // 🟢 IMPORT UUID
import '../viewmodels/workout_view_model.dart';
import '../models/routine.dart';
import '../l10n/app_localizations.dart';
import '../widgets/routine_card.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({Key? key}) : super(key: key);

  void _createNewRoutine(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RoutineEditorScreen()));
  }

  // 🟢 NEW: Logic to start an empty "Freestyle" workout
  void _startEmptyWorkout(BuildContext context) {
    // Create a temporary routine that isn't saved to the DB yet.
    // We just use it to initialize the ActiveWorkoutScreen.
    final freestyleRoutine = Routine(
      id: const Uuid().v4(),
      name: "Freestyle Workout",
      exercises: [],
      sortOrder: null,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider(
              create: (_) => ActiveWorkoutViewModel(),
              child: ActiveWorkoutScreen(routine: freestyleRoutine),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<WorkoutViewModel>();
    final labors = LaborsService.checkLabors(vm);
    final laborsCompletedCount = labors.where((l) => l.isCompleted).length;

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
          // ... (Existing Shield Icon Logic) ...
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
                  Icon(
                    Icons.shield_outlined,
                    size: 28,
                    color:
                        laborsCompletedCount == labors.length
                            ? Colors.amber
                            : Colors.grey[600],
                  ),
                  Text(
                    "$laborsCompletedCount",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color:
                          laborsCompletedCount == labors.length
                              ? Colors.black
                              : Colors.grey[600],
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: Selector<WorkoutViewModel, (bool, int)>(
                selector: (_, vm) => (vm.didWorkoutToday, vm.currentStreak),
                builder: (context, data, _) {
                  final didWorkoutToday = data.$1;
                  final currentStreak = data.$2;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: didWorkoutToday ? Colors.orange : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$currentStreak',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: didWorkoutToday ? Colors.orange : Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Selector<WorkoutViewModel, List<Routine>>(
        selector: (_, vm) => vm.routines,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, routines, child) {
          if (routines.isEmpty) {
            return _buildEmptyState(context);
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            header: Padding(
              padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
              child: Column(
                children: [
                  _buildCreateButton(context),
                  const SizedBox(height: 20),
                  _buildQuickStartButton(context),
                ],
              ),
            ),
            footer: _buildCampaignCard(context),
            itemCount: routines.length,
            onReorder: (oldIndex, newIndex) {
              context.read<WorkoutViewModel>().reorderRoutines(
                oldIndex,
                newIndex,
              );
            },
            proxyDecorator: (
              Widget child,
              int index,
              Animation<double> animation,
            ) {
              return AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget? child) {
                  // 1. Create a matching curve for a responsive spring animation feel
                  final CurvedAnimation liftCurve = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );

                  // 2. Map the animation value to an elevation transition (0.0 to 8.0)
                  final double elevationValue =
                      Tween<double>(
                        begin: 0.0,
                        end: 8.0,
                      ).animate(liftCurve).value;

                  // 3. Map the animation value to a scale growth multiplier (1.0 to 1.03)
                  // Adjust 1.03 higher (e.g., 1.05) if you want an even more pronounced scale up
                  final double scaleValue =
                      Tween<double>(
                        begin: 1.0,
                        end: 1.03,
                      ).animate(liftCurve).value;

                  return Transform.scale(
                    scale:
                        scaleValue, // 🟢 Scales up the card sizes smoothly during active reordering
                    child: Material(
                      elevation: elevationValue,
                      color: Colors.transparent,
                      shadowColor: Theme.of(
                        context,
                      ).colorScheme.shadow.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final routine = routines[index];
              return Padding(
                key: ValueKey(routine.id),
                // 🟢 Fix: Spacing is now handled here externally on a transparent layer
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 4.0,
                ),
                child: RoutineCard(
                  routine: routine,
                  onStart: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
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
                  onDelete: () => _showDeleteDialog(context, routine),
                  onDuplicate:
                      () => context.read<WorkoutViewModel>().duplicateRoutine(
                        routine.id,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🟢 NEW: Quick Start Button Widget
  Widget _buildQuickStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _startEmptyWorkout(context),
        icon: const Icon(Icons.play_arrow),
        label: const Text(
          "START EMPTY WORKOUT",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _createNewRoutine(context),
        icon: const Icon(Icons.add),
        label: const Text(
          "CREATE NEW WORKOUT",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  // ... (Delete Dialog - Unchanged) ...
  void _showDeleteDialog(BuildContext context, Routine routine) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Routine?'),
          content: Text('Are you sure you want to delete "${routine.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                context.read<WorkoutViewModel>().deleteRoutine(routine.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ... (Campaign Card - Unchanged) ...
  Widget _buildCampaignCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 100),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/data/images/hercules_cerberus.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CampaignScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CAMPAIGN MODE",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "THE 12 LABORS",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.shield, color: Colors.white70, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "Prove your strength",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.amber),
                ),
              ],
            ),
          ),
        ),
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
            // 🟢 NEW: Add Quick Start button here too so user isn't stuck
            _buildQuickStartButton(context),
            const SizedBox(height: 48),

            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Routines Yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a routine or start an empty workout above.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
