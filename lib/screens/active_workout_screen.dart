// lib/screens/active_workout_screen.dart

import 'package:burnout/screens/exercise_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// Models & Enums
import '../models/models.dart';
import '../models/enums.dart';
import '../models/battle_report_model.dart';

// ViewModels & Providers
import '../viewmodels/active_workout_view_model.dart';
import '../viewmodels/workout_view_model.dart';
// 🟢 NEW: Swapped UserSettingsProvider for UnitSettingsProvider
import '../providers/unit_settings_provider.dart';

// Widgets & Screens
import '../widgets/hevy_style_set_row.dart';
import 'battle_report_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Routine routine;
  const ActiveWorkoutScreen({super.key, required this.routine});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late DateTime _startTime;
  final Map<String, BuildContext> _openSlidables = {};

  final GlobalKey<SliverAnimatedListState> _exerciseListKey =
      GlobalKey<SliverAnimatedListState>();

  void _registerSlidableContext(String key, BuildContext ctx) {
    _openSlidables[key] = ctx;
  }

  void _closeAllSlidables() {
    for (final ctx in _openSlidables.values.toList()) {
      if (ctx.mounted) {
        Slidable.of(ctx)?.close();
      }
    }
  }

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

  Widget _buildRemovedExercise(
    RoutineExercise exercise,
    int index,
    Animation<double> animation,
  ) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInCubic),
      ),
    );

    final sizeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    );

    return SizeTransition(
      sizeFactor: sizeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: _ExerciseEntry(
          key: ValueKey('${exercise.exerciseId}_removed'),
          routineExercise: exercise,
          exerciseIndex: index,
          onSlidableContext: (_, __) {},
          closeAllSlidables: () {},
          onDelete: () {},
        ),
      ),
    );
  }

  void _handleDeleteExercise(int index) {
    final viewModel = context.read<ActiveWorkoutViewModel>();
    final removedExercise = viewModel.liveExercises[index];

    _exerciseListKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildRemovedExercise(removedExercise, index, animation),
      duration: const Duration(milliseconds: 600),
    );

    viewModel.deleteExercise(index);
  }

  Future<void> _showAddExercisePicker(BuildContext context) async {
    _closeAllSlidables();

    final viewModel = context.read<ActiveWorkoutViewModel>();

    final currentExerciseIds =
        viewModel.liveExercises.map((e) => e.exerciseId).toSet();

    final selectedExercises = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                ExercisePickerScreen(initiallySelectedIds: currentExerciseIds),
      ),
    );

    if (selectedExercises == null) return;

    final newExercisesToAdd =
        selectedExercises
            .where((ex) => !currentExerciseIds.contains(ex.id))
            .toList();

    final selectedIdsSet = selectedExercises.map((e) => e.id).toSet();
    final indicesToRemove = <int>[];

    for (int i = 0; i < viewModel.liveExercises.length; i++) {
      if (!selectedIdsSet.contains(viewModel.liveExercises[i].exerciseId)) {
        indicesToRemove.add(i);
      }
    }

    for (var i in indicesToRemove.reversed) {
      final removedExercise = viewModel.liveExercises[i];
      _exerciseListKey.currentState?.removeItem(
        i,
        (context, animation) =>
            _buildRemovedExercise(removedExercise, i, animation),
        duration: const Duration(milliseconds: 600),
      );
      viewModel.deleteExercise(i);
    }

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

      _exerciseListKey.currentState?.insertItem(
        viewModel.liveExercises.length - 1,
        duration: const Duration(milliseconds: 400),
      );
    }
  }

  void _finishWorkout(BuildContext context) {
    _closeAllSlidables();

    final activeVM = context.read<ActiveWorkoutViewModel>();
    final workoutVM = context.read<WorkoutViewModel>();

    bool hasIncompleteSets = false;
    for (int i = 0; i < activeVM.liveExercises.length; i++) {
      for (int j = 0; j < activeVM.liveExercises[i].plannedSets.length; j++) {
        if (!activeVM.isSetCompleted(i, j)) {
          hasIncompleteSets = true;
          break;
        }
      }
      if (hasIncompleteSets) break;
    }

    if (hasIncompleteSets) {
      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text("Unfinished Business"),
              content: const Text(
                "You still have sets that haven't been marked as complete. How do you want to proceed?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _handleTacticalChangesAndFinish(
                      context,
                      activeVM,
                      workoutVM,
                    );
                  },
                  child: const Text("Finish Anyway"),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);

                    for (int i = 0; i < activeVM.liveExercises.length; i++) {
                      for (
                        int j = 0;
                        j < activeVM.liveExercises[i].plannedSets.length;
                        j++
                      ) {
                        if (!activeVM.isSetCompleted(i, j)) {
                          activeVM.toggleSetCompletion(i, j);
                        }
                      }
                    }

                    _handleTacticalChangesAndFinish(
                      context,
                      activeVM,
                      workoutVM,
                    );
                  },
                  child: const Text("Mark All Complete"),
                ),
              ],
            ),
      );
    } else {
      _handleTacticalChangesAndFinish(context, activeVM, workoutVM);
    }
  }

  bool _hasRoutineChangedDeep(ActiveWorkoutViewModel activeVM) {
    final original = widget.routine.exercises;
    final current = activeVM.liveExercises;

    if (original.length != current.length) return true;

    for (int i = 0; i < original.length; i++) {
      final origEx = original[i];
      final currEx = current[i];

      if (origEx.exerciseId != currEx.exerciseId) return true;
      if (origEx.plannedSets.length != currEx.plannedSets.length) return true;

      for (int j = 0; j < origEx.plannedSets.length; j++) {
        if (origEx.plannedSets[j].setType != currEx.plannedSets[j].setType) {
          return true;
        }
      }
    }

    return false;
  }

  void _handleTacticalChangesAndFinish(
    BuildContext context,
    ActiveWorkoutViewModel activeVM,
    WorkoutViewModel workoutVM,
  ) {
    final performedExercises = activeVM.getPerformedExercises();
    if (performedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No sets were completed. Workout not saved."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_hasRoutineChangedDeep(activeVM)) {
      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text("Tactical Change Detected"),
              content: const Text(
                "You altered the battle plan (added/removed exercises or sets, changed set types). Do you want to update the original routine to match this new layout?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
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
      _proceedToFinish(context, activeVM, workoutVM, updateRoutine: false);
    }
  }

  void _proceedToFinish(
    BuildContext context,
    ActiveWorkoutViewModel activeVM,
    WorkoutViewModel workoutVM, {
    required bool updateRoutine,
  }) {
    if (updateRoutine && activeVM.routine != null) {
      final updatedRoutine = activeVM.routine!.copyWith(
        exercises: activeVM.liveExercises,
      );
      workoutVM.updateRoutine(updatedRoutine);
    }

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
        if (activeVM.isSetCompleted(i, setIndex)) {
          hasCompletedSet = true;
          final set = routineExercise.plannedSets[setIndex];
          if ((set.targetWeight ?? 0) > maxWeight) {
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
    // 1. Only listen to the "isStarted" flag at the root level.
    // This prevents the whole screen from rebuilding when you tick a set.
    final isStarted = context.select<ActiveWorkoutViewModel, bool>(
      (vm) => vm.isWorkoutStarted,
    );

    if (!isStarted) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. The Scaffold is now built ONCE.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // 3. Target ONLY the Title to update if the routine changes
        title: Selector<ActiveWorkoutViewModel, String>(
          selector: (_, vm) => vm.routine?.name ?? 'Workout',
          builder: (context, name, child) => Text(name),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Exercise',
            onPressed: () => _showAddExercisePicker(context),
          ),
          TextButton(
            onPressed: () => _finishWorkout(context),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'FINISH',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          // 4. Target ONLY the Progress Bar to update when sets are checked
          child: Selector<ActiveWorkoutViewModel, double>(
            selector: (_, vm) => vm.workoutProgress,
            builder: (context, progress, child) {
              return LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                color: Theme.of(context).colorScheme.primary,
              );
            },
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _closeAllSlidables,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              _closeAllSlidables();
            }
            return false;
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 120.0),
                sliver: SliverAnimatedList(
                  key: _exerciseListKey,
                  // 5. Read the length ONCE. The AnimatedList manages its own UI state after this!
                  initialItemCount:
                      context
                          .read<ActiveWorkoutViewModel>()
                          .liveExercises
                          .length,
                  itemBuilder: (context, index, animation) {
                    // 6. Use .read() instead of .watch() so scrolling doesn't trigger global rebuilds
                    final viewModel = context.read<ActiveWorkoutViewModel>();
                    final routineExercise = viewModel.liveExercises[index];

                    return SizeTransition(
                      sizeFactor: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: _ExerciseEntry(
                          key: ValueKey(routineExercise.exerciseId),
                          routineExercise: routineExercise,
                          exerciseIndex: index,
                          onSlidableContext: _registerSlidableContext,
                          closeAllSlidables: _closeAllSlidables,
                          onDelete: () => _handleDeleteExercise(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUB-WIDGET: The Exercise Card (List of Sets)
// ---------------------------------------------------------------------------

class _ExerciseEntry extends StatefulWidget {
  final RoutineExercise routineExercise;
  final int exerciseIndex;
  final void Function(String key, BuildContext context) onSlidableContext;
  final VoidCallback closeAllSlidables;
  final VoidCallback onDelete;

  const _ExerciseEntry({
    super.key,
    required this.routineExercise,
    required this.exerciseIndex,
    required this.onSlidableContext,
    required this.closeAllSlidables,
    required this.onDelete,
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
    _exerciseDetails =
        context.read<WorkoutViewModel>().getExerciseById(
          widget.routineExercise.exerciseId,
        )!;

    _setKeys = List.generate(
      widget.routineExercise.plannedSets.length,
      (_) => UniqueKey(),
    );
  }

  void _addSet() {
    widget.closeAllSlidables();

    final sets = widget.routineExercise.plannedSets;
    final newSetIndex = sets.length;

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

    _listKey.currentState?.insertItem(
      newSetIndex,
      duration: const Duration(milliseconds: 300),
    );

    setState(() {});
  }

  void _removeSet(int setIndex) {
    widget.closeAllSlidables();

    final viewModel = context.read<ActiveWorkoutViewModel>();

    final removedSet = widget.routineExercise.plannedSets[setIndex];
    final removedDisplayIndex = _calculateEffectiveDisplayIndex(setIndex);
    final currentWeightMode = viewModel.getWeightModeForExercise(
      _exerciseDetails,
    );
    final isCompleted = viewModel.isSetCompleted(
      widget.exerciseIndex,
      setIndex,
    );

    _listKey.currentState?.removeItem(
      setIndex,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: HevyStyleSetRow(
              setIndex: setIndex,
              displayIndex: removedDisplayIndex,
              plannedSet: removedSet,
              exercise: _exerciseDetails,
              isCompleted: isCompleted,
              weightMode: currentWeightMode,
              onChanged: (_) {},
              onTypeChanged: (_) {},
              onCompleted: () {},
            ),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );

    _setKeys.removeAt(setIndex);
    viewModel.removeSet(widget.exerciseIndex, setIndex);
    setState(() {});
  }

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
        // 🟢 CHANGED: Now listening to UnitSettingsProvider instead of UserSettingsProvider
        final unitSettings = context.watch<UnitSettingsProvider>();

        return Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  PopupMenuButton<String>(
                    onOpened: widget.closeAllSlidables,
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'delete') {
                        widget.onDelete();
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

              // 🟢 CHANGED: Passed unitSettings down to the header row
              _buildHeaderRow(
                context,
                unitSettings,
                viewModel,
                currentWeightMode,
              ),
              const SizedBox(height: 4),

              AnimatedList(
                key: _listKey,
                padding: EdgeInsets.zero,
                initialItemCount: widget.routineExercise.plannedSets.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, setIndex, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Slidable(
                        key: _setKeys[setIndex],
                        groupTag: 'workout_sets',
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.35,
                          children: [
                            SlidableAction(
                              onPressed: (context) => _removeSet(setIndex),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Listener(
                          behavior: HitTestBehavior.translucent,
                          onPointerDown: (_) => widget.closeAllSlidables(),
                          child: Builder(
                            builder: (innerContext) {
                              widget.onSlidableContext(
                                '${widget.exerciseIndex}-$setIndex',
                                innerContext,
                              );
                              return HevyStyleSetRow(
                                setIndex: setIndex,
                                displayIndex: _calculateEffectiveDisplayIndex(
                                  setIndex,
                                ),
                                plannedSet:
                                    widget
                                        .routineExercise
                                        .plannedSets[setIndex],
                                exercise: _exerciseDetails,
                                isCompleted: viewModel.isSetCompleted(
                                  widget.exerciseIndex,
                                  setIndex,
                                ),
                                weightMode: currentWeightMode,
                                onChanged: (updatedSet) {
                                  var finalSet = updatedSet;
                                  if (currentWeightMode ==
                                          WeightMode.assisted &&
                                      updatedSet.targetWeight != null) {
                                    final absWeight =
                                        updatedSet.targetWeight!.abs();
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
                                      widget
                                          .routineExercise
                                          .plannedSets[setIndex];
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
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

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

  // 🟢 CHANGED: Method signature updated to accept UnitSettingsProvider
  Widget _buildHeaderRow(
    BuildContext context,
    UnitSettingsProvider unitSettings,
    ActiveWorkoutViewModel viewModel,
    WeightMode currentMode,
  ) {
    String label;
    Color color;

    // 🟢 NEW: Determine the correct string to display based on the enum
    final unitString =
        unitSettings.unitSystem == UnitSystem.metric ? 'KG' : 'LBS';

    switch (currentMode) {
      case WeightMode.weighted:
        label = unitString; // Will output KG or LBS
        color = Theme.of(context).colorScheme.primary;
        break;
      case WeightMode.bodyweight:
        label = 'BW';
        color = Colors.green;
        break;
      case WeightMode.assisted:
        label = '-$unitString'; // Will output -KG or -LBS
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

            if (_exerciseDetails.supportsWeight ||
                _exerciseDetails.supportsBodyweight ||
                _exerciseDetails.supportsAssistance)
              SizedBox(
                width: 80,
                child: InkWell(
                  onTap: () {
                    widget.closeAllSlidables();
                    viewModel.cycleWeightModeForExercise(
                      widget.exerciseIndex,
                      _exerciseDetails,
                    );
                  },
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

            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}
