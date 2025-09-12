// lib/screens/active_workout_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../viewmodels/active_workout_view_model.dart';
import '../widgets/hevy_style_set_row.dart'; // Will be replaced with Hevy style
import '../models/enums.dart';
import '../providers/user_settings_provider.dart';
import 'exercise_picker_screen.dart';
import '../viewmodels/workout_view_model.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActiveWorkoutViewModel>(
        context,
        listen: false,
      ).startWorkout(widget.routine);
    });
  }

  Future<void> _addExercises(ActiveWorkoutViewModel viewModel) async {
    final currentExerciseIds =
        viewModel.liveExercises.map((re) => re.exerciseId).toSet();
    final List<Exercise>? selectedExercises = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) =>
                ExercisePickerScreen(initiallySelectedIds: currentExerciseIds),
        fullscreenDialog: true,
      ),
    );
    if (selectedExercises != null) {
      viewModel.updateExerciseList(selectedExercises);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveWorkoutViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isWorkoutStarted) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Active Workout'),
            // Hevy style uses a clean app bar without elevation
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: LinearProgressIndicator(
                value:
                    viewModel.totalExercises == 0
                        ? 0
                        : viewModel.completedExercisesCount /
                            viewModel.totalExercises,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final routineExercise = viewModel.liveExercises[index];
                    final allExercisesMap = {
                      for (var ex in context.read<WorkoutViewModel>().exercises)
                        ex.id: ex,
                    };
                    final exerciseDetails =
                        allExercisesMap[routineExercise.exerciseId];
                    if (exerciseDetails == null) return const SizedBox.shrink();

                    return _ExerciseEntry(
                      key: ValueKey('exercise-${routineExercise.exerciseId}'),
                      routineExercise: routineExercise,
                      exerciseDetails: exerciseDetails,
                      exerciseIndex: index,
                      viewModel: viewModel,
                    );
                  }, childCount: viewModel.liveExercises.length),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 32.0),
                  child: TextButton.icon(
                    onPressed: () => _addExercises(viewModel),
                    icon: const Icon(Icons.add),
                    label: const Text('Add / Edit Exercises'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExerciseEntry extends StatefulWidget {
  final RoutineExercise routineExercise;
  final Exercise exerciseDetails;
  final int exerciseIndex;
  final ActiveWorkoutViewModel viewModel;

  const _ExerciseEntry({
    super.key,
    required this.routineExercise,
    required this.exerciseDetails,
    required this.exerciseIndex,
    required this.viewModel,
  });

  @override
  State<_ExerciseEntry> createState() => _ExerciseEntryState();
}

class _ExerciseEntryState extends State<_ExerciseEntry> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void _addSet() {
    final newSetIndex = widget.routineExercise.plannedSets.length;
    widget.viewModel.addSet(widget.exerciseIndex);
    _listKey.currentState?.insertItem(
      newSetIndex,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _deleteSet(int setIndex) {
    widget.viewModel.deleteSet(widget.exerciseIndex, setIndex, notify: true);
    // Note: Deletion animation is harder with this model. Hevy uses a different approach.
    // For simplicity, we'll rely on the ViewModel to notify and rebuild.
    // To add animation, a temporary list would be needed.
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.routineExercise.exerciseName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildHeaderRow(context),
          const SizedBox(height: 4),
          ListView.builder(
            itemCount: widget.routineExercise.plannedSets.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, setIndex) {
              return HevyStyleSetRow(
                key: ValueKey('${widget.routineExercise.exerciseId}-$setIndex'),
                setIndex: setIndex,
                plannedSet: widget.routineExercise.plannedSets[setIndex],
                exercise: widget.exerciseDetails,
                weightMode: widget.viewModel.getWeightModeForExercise(
                  widget.exerciseIndex,
                ),
                isCompleted: widget.viewModel.isSetCompleted(
                  widget.exerciseIndex,
                  setIndex,
                ),
                onChanged:
                    (updatedSet) => widget.viewModel.updateSet(
                      widget.exerciseIndex,
                      setIndex,
                      updatedSet,
                    ),
                onCompleted:
                    () => widget.viewModel.completeSet(
                      widget.exerciseIndex,
                      setIndex,
                    ),
              );
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(onPressed: _addSet, child: const Text('Add Set')),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final settings = context.read<UserSettingsProvider>();
    final currentWeightMode = widget.viewModel.getWeightModeForExercise(
      widget.exerciseIndex,
    );
    final weightUnit = settings.weightUnit.name.toUpperCase();
    final bool isReps = widget.exerciseDetails.tracksReps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Spacer for the set circle
          Text("PREV", style: Theme.of(context).textTheme.bodySmall),
          Text(weightUnit, style: Theme.of(context).textTheme.bodySmall),
          if (isReps)
            Text("REPS", style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 40), // Spacer for the check circle
        ],
      ),
    );
  }
}
