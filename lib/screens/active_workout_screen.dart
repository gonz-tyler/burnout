// lib/screens/active_workout_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../viewmodels/active_workout_view_model.dart';
import '../viewmodels/workout_view_model.dart';
import '../providers/user_settings_provider.dart';
import '../widgets/hevy_style_set_row.dart';
import 'exercise_picker_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Routine routine;
  const ActiveWorkoutScreen({super.key, required this.routine});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActiveWorkoutViewModel>(
        context,
        listen: false,
      ).startWorkout(widget.routine);
    });
  }

  void _finishWorkout(BuildContext context, ActiveWorkoutViewModel viewModel) {
    final workoutViewModel = context.read<WorkoutViewModel>();
    final duration = DateTime.now().difference(_startTime).inMinutes;

    final performedExercises = viewModel.getPerformedExercises();

    if (performedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No sets were completed. Workout not saved."),
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    final session = WorkoutSession(
      id: const Uuid().v4(),
      routineId: widget.routine.id,
      dateCompleted: DateTime.now(),
      durationInMinutes: duration > 0 ? duration : 1,
      performedExercises: performedExercises,
    );

    workoutViewModel.addWorkoutSession(session);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ActiveWorkoutViewModel>();

    if (!viewModel.isWorkoutStarted) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.routine?.name ?? 'Workout'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: viewModel.workoutProgress,
            backgroundColor: Colors.grey.shade300,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final routineExercise = viewModel.liveExercises[index];
                return _ExerciseEntry(
                  key: ValueKey(routineExercise.hashCode),
                  routineExercise: routineExercise,
                  exerciseIndex: index,
                );
              }, childCount: viewModel.liveExercises.length),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
              child: TextButton(
                onPressed: () => _finishWorkout(context, viewModel),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Finish Workout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseEntry extends StatefulWidget {
  final RoutineExercise routineExercise;
  final int exerciseIndex;

  const _ExerciseEntry({
    super.key,
    required this.routineExercise,
    required this.exerciseIndex,
  });

  @override
  State<_ExerciseEntry> createState() => _ExerciseEntryState();
}

class _ExerciseEntryState extends State<_ExerciseEntry> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late final Exercise _exerciseDetails;

  @override
  void initState() {
    super.initState();
    _exerciseDetails =
        context.read<WorkoutViewModel>().getExerciseById(
          widget.routineExercise.exerciseId,
        )!;
  }

  void _addSet() {
    final newSetIndex = widget.routineExercise.plannedSets.length;
    setState(() {
      widget.routineExercise.plannedSets.add(
        PlannedSet(
          targetReps:
              newSetIndex > 0
                  ? widget
                      .routineExercise
                      .plannedSets[newSetIndex - 1]
                      .targetReps
                  : null,
          targetWeight:
              newSetIndex > 0
                  ? widget
                      .routineExercise
                      .plannedSets[newSetIndex - 1]
                      .targetWeight
                  : null,
        ),
      );
    });
    _listKey.currentState?.insertItem(
      newSetIndex,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use `watch` here to rebuild the card when the weight mode changes
    final viewModel = context.watch<ActiveWorkoutViewModel>();
    final settings = context.watch<UserSettingsProvider>();
    final currentWeightMode = viewModel.getWeightModeForExercise(
      _exerciseDetails,
    );

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
          _buildHeaderRow(context, settings, viewModel, currentWeightMode),
          const SizedBox(height: 4),
          AnimatedList(
            key: _listKey,
            initialItemCount: widget.routineExercise.plannedSets.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, setIndex, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: HevyStyleSetRow(
                  setIndex: setIndex,
                  plannedSet: widget.routineExercise.plannedSets[setIndex],
                  exercise: _exerciseDetails,
                  isCompleted: viewModel.isSetCompleted(
                    widget.exerciseIndex,
                    setIndex,
                  ),
                  weightMode: currentWeightMode, // <-- PASS THE MODE DOWN
                  onChanged: (updatedSet) {
                    viewModel.updateSetData(
                      widget.exerciseIndex,
                      setIndex,
                      updatedSet,
                    );
                  },
                  onCompleted: () {
                    viewModel.toggleSetCompletion(
                      widget.exerciseIndex,
                      setIndex,
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _addSet,
              child: const Text('+ Add Set'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(
    BuildContext context,
    UserSettingsProvider settings,
    ActiveWorkoutViewModel viewModel,
    WeightMode currentMode,
  ) {
    String label;
    Color color;

    switch (currentMode) {
      case WeightMode.weighted:
        label = settings.weightUnit.name.toUpperCase();
        color = Theme.of(context).colorScheme.primary;
        break;
      case WeightMode.bodyweight:
        label = 'BW';
        color = Colors.green;
        break;
      case WeightMode.assisted:
        label = '-${settings.weightUnit.name.toUpperCase()}';
        color = Colors.orange;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodySmall!,
        child: Row(
          children: [
            const SizedBox(
              width: 40,
              child: Text('SET', textAlign: TextAlign.center),
            ),
            const Expanded(child: Text("PREV", textAlign: TextAlign.center)),
            if (_exerciseDetails.supportsWeight ||
                _exerciseDetails.supportsBodyweight ||
                _exerciseDetails.supportsAssistance)
              SizedBox(
                width: 80,
                // **NEW**: Make the header tappable
                child: InkWell(
                  onTap:
                      () => viewModel.cycleWeightModeForExercise(
                        widget.exerciseIndex,
                        _exerciseDetails,
                      ),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
            if ((_exerciseDetails.supportsWeight ||
                    _exerciseDetails.supportsBodyweight ||
                    _exerciseDetails.supportsAssistance) &&
                _exerciseDetails.tracksReps)
              const SizedBox(width: 8),
            if (_exerciseDetails.tracksReps)
              const SizedBox(
                width: 80,
                child: Text("REPS", textAlign: TextAlign.center),
              ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}
