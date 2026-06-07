// lib/screens/active_workout_screen.dart

import 'package:burnout/screens/exercise_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// Models & Enums
import '../models/models.dart';
import '../models/enums.dart';
import '../models/battle_report_model.dart'; // 🟢 NEW: For the result logic

// ViewModels & Providers
import '../viewmodels/active_workout_view_model.dart';
import '../viewmodels/workout_view_model.dart';
import '../providers/user_settings_provider.dart';

// Widgets & Screens
import '../widgets/hevy_style_set_row.dart';
import 'battle_report_screen.dart'; // 🟢 NEW: The destination screen

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

    // Initialize the view model with the routine data once the frame is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActiveWorkoutViewModel>(
        context,
        listen: false,
      ).startWorkout(widget.routine);
    });
  }

  Future<void> _showAddExercisePicker(BuildContext context) async {
    final viewModel = context.read<ActiveWorkoutViewModel>();

    // 1. Get currently active exercise IDs to Pre-Select them
    final currentExerciseIds =
        viewModel.liveExercises.map((e) => e.exerciseId).toSet();

    // 2. Open the Picker with current IDs passed in
    final selectedExercises = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                ExercisePickerScreen(initiallySelectedIds: currentExerciseIds),
      ),
    );

    if (selectedExercises == null) return;

    // 3. SYNC LOGIC: Add new ones, Remove unchecked ones

    // A. Identify what to ADD (In selection, but NOT in current active workout)
    final newExercisesToAdd =
        selectedExercises
            .where((ex) => !currentExerciseIds.contains(ex.id))
            .toList();

    // B. Identify what to REMOVE (In current active workout, but unchecked in picker)
    // We collect indices first to avoid shifting issues during removal
    final selectedIdsSet = selectedExercises.map((e) => e.id).toSet();
    final indicesToRemove = <int>[];

    for (int i = 0; i < viewModel.liveExercises.length; i++) {
      if (!selectedIdsSet.contains(viewModel.liveExercises[i].exerciseId)) {
        indicesToRemove.add(i);
      }
    }

    // 4. Apply Changes

    // Remove first (Iterate in reverse so indices don't shift)
    for (var i in indicesToRemove.reversed) {
      viewModel.deleteExercise(i);
    }

    // Add new exercises
    for (var exercise in newExercisesToAdd) {
      final defaultSet = PlannedSet(
        targetWeight: null,
        targetReps: "10",
        targetDistanceInMeters: null,
        targetDurationInSeconds: null,
        setType: SetType.normal,
      );

      final newRoutineExercise = RoutineExercise(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        plannedSets: [defaultSet],
        restTimeInSeconds: 90,
      );

      viewModel.addExercise(newRoutineExercise);
    }
  }

  void _finishWorkout(BuildContext context) {
    // 🟢 1. Capture ViewModels HERE, using the screen's context
    // The dialog context won't be able to find ActiveWorkoutViewModel later
    final activeVM = context.read<ActiveWorkoutViewModel>();
    final workoutVM = context.read<WorkoutViewModel>();

    final performedExercises = activeVM.getPerformedExercises();
    if (performedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No sets were completed. Workout not saved."),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    if (activeVM.hasRoutineChanged()) {
      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text("Tactical Change Detected"),
              content: const Text(
                "You altered the battle plan (added/removed exercises). Do you want to update the original routine to match this new layout?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    // 🟢 Pass the captured VMs
                    _proceedToFinish(
                      context,
                      activeVM,
                      workoutVM,
                      updateRoutine: false,
                    );
                  },
                  child: const Text("No, One-Time Only"),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    // 🟢 Pass the captured VMs
                    _proceedToFinish(
                      context,
                      activeVM,
                      workoutVM,
                      updateRoutine: true,
                    );
                  },
                  child: const Text("Yes, Update Routine"),
                ),
              ],
            ),
      );
    } else {
      // 🟢 Pass the captured VMs
      _proceedToFinish(context, activeVM, workoutVM, updateRoutine: false);
    }
  }

  void _proceedToFinish(
    BuildContext context,
    ActiveWorkoutViewModel activeVM, // 🟢 Added argument
    WorkoutViewModel workoutVM, { // 🟢 Added argument
    required bool updateRoutine,
  }) {
    // ❌ REMOVED: final activeVM = context.read<...>();
    // We use the passed-in variables instead.

    // 1. Update Routine if requested
    if (updateRoutine && activeVM.routine != null) {
      final updatedRoutine = activeVM.routine!.copyWith(
        exercises: activeVM.liveExercises,
      );
      workoutVM.updateRoutine(updatedRoutine);
    }

    // 2. Calculate Battle Results
    final battleResults = <ExerciseResult>[];

    for (var i = 0; i < activeVM.liveExercises.length; i++) {
      final routineExercise = activeVM.liveExercises[i];
      double maxWeight = 0.0;
      bool hasCompletedSet = false;

      for (
        int setIndex = 0;
        setIndex < routineExercise.plannedSets.length;
        setIndex++
      ) {
        final set = routineExercise.plannedSets[setIndex];
        // Note: isSetCompleted needs the index, which is fine as activeVM is valid
        if (activeVM.isSetCompleted(i, setIndex) &&
            (set.targetWeight ?? 0) > 0) {
          hasCompletedSet = true;
          if (set.targetWeight! > maxWeight) {
            maxWeight = set.targetWeight!;
          }
        }
      }

      if (hasCompletedSet) {
        final previousRecord = workoutVM.getPersonalRecord(
          routineExercise.exerciseName,
        );
        final isPr = maxWeight > previousRecord;

        battleResults.add(
          ExerciseResult(
            exerciseId: routineExercise.exerciseId,
            exerciseName: routineExercise.exerciseName,
            weightUsed: maxWeight,
            isPr: isPr,
            nextWeight: maxWeight,
          ),
        );
      }
    }

    // 3. Save Session
    final durationInMinutes = DateTime.now().difference(_startTime).inMinutes;
    final performedData = activeVM.getPerformedExercises();

    final session = WorkoutSession(
      id: const Uuid().v4(),
      routineId: widget.routine.id,
      dateCompleted: DateTime.now(),
      durationInMinutes: durationInMinutes > 0 ? durationInMinutes : 1,
      performedExercises: performedData,
    );

    workoutVM.addWorkoutSession(session);

    // 4. Navigate
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => BattleReportScreen(
              results: battleResults,
              routineId: widget.routine.id,
              duration: Duration(
                minutes: durationInMinutes > 0 ? durationInMinutes : 1,
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 FIX: Use Consumer so the screen rebuilds whenever the list changes
    return Consumer<ActiveWorkoutViewModel>(
      builder: (context, viewModel, child) {
        // 1. Check if loading
        if (!viewModel.isWorkoutStarted) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Render the Workout UI
        return Scaffold(
          resizeToAvoidBottomInset: false,
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
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 300.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final routineExercise = viewModel.liveExercises[index];
                      return _ExerciseEntry(
                        // 🟢 Use exerciseId for Key to prevent UI bugs when deleting
                        key: ValueKey(routineExercise.exerciseId),
                        routineExercise: routineExercise,
                        exerciseIndex: index,
                      );
                    },
                    // 🟢 This will now correctly update when exercises are added/removed
                    childCount: viewModel.liveExercises.length,
                  ),
                ),
              ),

              // --- ADD EXERCISE BUTTON ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddExercisePicker(context),
                    icon: const Icon(Icons.add),
                    label: const Text("ADD EXERCISE"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              // --- FINISH WORKOUT BUTTON ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _finishWorkout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'FINISH WORKOUT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 16,
                        ),
                      ),
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

// ---------------------------------------------------------------------------
// SUB-WIDGET: The Exercise Card (List of Sets)
// ---------------------------------------------------------------------------

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
  late List<UniqueKey> _setKeys;

  @override
  void initState() {
    super.initState();
    // Retrieve static details (like supportsWeight, tracksDistance) from main VM
    _exerciseDetails =
        context.read<WorkoutViewModel>().getExerciseById(
          widget.routineExercise.exerciseId,
        )!;

    // Generate unique keys for sets to maintain focus/state during list updates
    _setKeys = List.generate(
      widget.routineExercise.plannedSets.length,
      (_) => UniqueKey(),
    );
  }

  void _addSet() {
    final sets = widget.routineExercise.plannedSets;
    final newSetIndex = sets.length;

    // Copy values from the previous set for convenience
    double? prevWeight;
    String? prevReps;
    int? prevDistance;
    int? prevDuration;

    if (newSetIndex > 0) {
      final lastSet = sets[newSetIndex - 1];
      prevWeight = lastSet.targetWeight;
      prevReps = lastSet.targetReps;
      prevDistance = lastSet.targetDistanceInMeters;
      prevDuration = lastSet.targetDurationInSeconds;
    }

    final newSet = PlannedSet(
      targetWeight: prevWeight,
      targetReps: prevReps,
      targetDistanceInMeters: prevDistance,
      targetDurationInSeconds: prevDuration,
      setType: SetType.normal,
    );

    _setKeys.add(UniqueKey());
    widget.routineExercise.plannedSets.add(newSet);

    // Animate insertion
    _listKey.currentState?.insertItem(
      newSetIndex,
      duration: const Duration(milliseconds: 300),
    );

    setState(() {});
  }

  void _removeSet(int setIndex) {
    final viewModel = context.read<ActiveWorkoutViewModel>();

    // Animate removal
    _listKey.currentState?.removeItem(
      setIndex,
      (context, animation) =>
          SizeTransition(sizeFactor: animation, child: const SizedBox.shrink()),
      duration: const Duration(milliseconds: 300),
    );

    _setKeys.removeAt(setIndex);
    viewModel.removeSet(widget.exerciseIndex, setIndex);
    setState(() {});
  }

  // Calculate the visual index (e.g. "1", "2") ignoring warmups if you preferred,
  // currently just returns 1-based index logic.
  int _calculateEffectiveDisplayIndex(int currentSetIndex) {
    int count = 0;
    for (int i = 0; i <= currentSetIndex; i++) {
      final set = widget.routineExercise.plannedSets[i];
      if (set.setType != SetType.warmup) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ActiveWorkoutViewModel>();

    return Selector<ActiveWorkoutViewModel, WeightMode>(
      selector: (_, vm) => vm.getWeightModeForExercise(_exerciseDetails),
      builder: (context, currentWeightMode, child) {
        final settings = context.watch<UserSettingsProvider>();

        return Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.routineExercise.exerciseName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  // 🟢 NEW: Option Menu (Delete)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'delete') {
                        // Call delete on VM
                        context.read<ActiveWorkoutViewModel>().deleteExercise(
                          widget.exerciseIndex,
                        );
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  "Remove Exercise",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Column Headers (Set, Prev, Kg, Reps)
              _buildHeaderRow(context, settings, viewModel, currentWeightMode),
              const SizedBox(height: 4),

              // The List of Sets
              AnimatedList(
                key: _listKey,
                initialItemCount: widget.routineExercise.plannedSets.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, setIndex, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Dismissible(
                      key: _setKeys[setIndex],
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => _removeSet(setIndex),
                      background: Container(
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: HevyStyleSetRow(
                        setIndex: setIndex,
                        displayIndex: _calculateEffectiveDisplayIndex(setIndex),
                        plannedSet:
                            widget.routineExercise.plannedSets[setIndex],
                        exercise: _exerciseDetails,
                        isCompleted: viewModel.isSetCompleted(
                          widget.exerciseIndex,
                          setIndex,
                        ),
                        weightMode: currentWeightMode,
                        onChanged: (updatedSet) {
                          var finalSet = updatedSet;
                          // Force negative sign for assisted weight
                          if (currentWeightMode == WeightMode.assisted &&
                              updatedSet.targetWeight != null) {
                            final absWeight = updatedSet.targetWeight!.abs();
                            finalSet = updatedSet.copyWith(
                              targetWeight: -absWeight,
                            );
                          }
                          viewModel.updateSetData(
                            widget.exerciseIndex,
                            setIndex,
                            finalSet,
                          );
                        },
                        onTypeChanged: (newType) {
                          final currentSet =
                              widget.routineExercise.plannedSets[setIndex];
                          viewModel.updateSetData(
                            widget.exerciseIndex,
                            setIndex,
                            currentSet.copyWith(setType: newType),
                          );
                          setState(() {});
                        },
                        onCompleted: () {
                          viewModel.toggleSetCompletion(
                            widget.exerciseIndex,
                            setIndex,
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Add Set Button
              Center(
                child: TextButton.icon(
                  onPressed: _addSet,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Set'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 40,
              child: Text('SET', textAlign: TextAlign.center),
            ),
            const Expanded(
              child: Text("PREVIOUS", textAlign: TextAlign.center),
            ),

            // Weight Column Header (Clickable to cycle modes)
            if (_exerciseDetails.supportsWeight ||
                _exerciseDetails.supportsBodyweight ||
                _exerciseDetails.supportsAssistance)
              SizedBox(
                width: 80,
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
                      style: TextStyle(color: color),
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

            if (_exerciseDetails.tracksDistance)
              const SizedBox(
                width: 80,
                child: Text("DIST", textAlign: TextAlign.center),
              ),

            const SizedBox(width: 48), // Spacing for Checkbox
          ],
        ),
      ),
    );
  }
}
