// lib/screens/routine_editor_screen.dart

import 'package:burnout/models/models.dart';
import 'package:burnout/providers/user_settings_provider.dart';
import 'package:burnout/viewmodels/workout_view_model.dart';
import 'package:burnout/widgets/hevy_style_set_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'exercise_picker_screen.dart';

class RoutineEditorScreen extends StatefulWidget {
  final Routine? initialRoutine;

  const RoutineEditorScreen({super.key, this.initialRoutine});

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final _nameController = TextEditingController();
  final List<RoutineExercise> _routineExercises = [];
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.initialRoutine != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final routine = widget.initialRoutine!;
      _nameController.text = routine.name;
      _routineExercises.addAll(routine.exercises.map((e) => e.copyWith()));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addExercises() async {
    final currentExerciseIds =
        _routineExercises.map((re) => re.exerciseId).toSet();
    final List<Exercise>? selectedExercises = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) =>
                ExercisePickerScreen(initiallySelectedIds: currentExerciseIds),
        fullscreenDialog: true,
      ),
    );

    if (selectedExercises != null) {
      setState(() {
        final Map<String, RoutineExercise> existingExercisesMap = {
          for (var re in _routineExercises) re.exerciseId: re,
        };
        final List<RoutineExercise> updatedList = [];

        for (var exercise in selectedExercises) {
          if (existingExercisesMap.containsKey(exercise.id)) {
            updatedList.add(existingExercisesMap[exercise.id]!);
          } else {
            updatedList.add(
              RoutineExercise(
                exerciseId: exercise.id,
                exerciseName: exercise.name,
                plannedSets: [PlannedSet(setType: SetType.normal)],
                restTimeInSeconds: 60,
              ),
            );
          }
        }
        _routineExercises.clear();
        _routineExercises.addAll(updatedList);
      });
    }
  }

  void _saveRoutine() {
    if (_formKey.currentState!.validate()) {
      if (_routineExercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one exercise.')),
        );
        return;
      }
      final workoutViewModel = context.read<WorkoutViewModel>();
      if (_isEditing) {
        final updatedRoutine = widget.initialRoutine!.copyWith(
          name: _nameController.text,
          exercises: _routineExercises,
        );
        workoutViewModel.updateRoutine(updatedRoutine);
      } else {
        final newRoutine = Routine(
          id: const Uuid().v4(),
          name: _nameController.text,
          exercises: _routineExercises,
        );
        workoutViewModel.addRoutine(newRoutine);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Routine' : 'Create Routine'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveRoutine),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Routine Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a routine name.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OutlinedButton.icon(
                onPressed: _addExercises,
                icon: const Icon(Icons.add),
                label: const Text('Add / Edit Exercises'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            const Divider(height: 32),
            Expanded(
              child:
                  _routineExercises.isEmpty
                      ? const Center(
                        child: Text('Add exercises to get started.'),
                      )
                      : _buildExerciseList(),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      buildDefaultDragHandles: false,
      itemCount: _routineExercises.length,
      itemBuilder: (context, index) {
        final routineExercise = _routineExercises[index];
        return _ExerciseEditorCard(
          // **FIX 1 of 2: Use a stable, unique key.**
          // The exerciseId is guaranteed to be unique and won't change,
          // which prevents Flutter from getting confused during rebuilds.
          key: ValueKey(routineExercise.exerciseId),
          routineExercise: routineExercise,
          index: index,
          onDelete: () {
            setState(() {
              _routineExercises.removeAt(index);
            });
          },
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _routineExercises.removeAt(oldIndex);
          _routineExercises.insert(newIndex, item);
        });
      },
    );
  }
}

class _ExerciseEditorCard extends StatefulWidget {
  final RoutineExercise routineExercise;
  final VoidCallback onDelete;
  final int index;

  const _ExerciseEditorCard({
    super.key,
    required this.routineExercise,
    required this.onDelete,
    required this.index,
  });

  @override
  State<_ExerciseEditorCard> createState() => _ExerciseEditorCardState();
}

class _ExerciseEditorCardState extends State<_ExerciseEditorCard> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late final Exercise _exerciseDetails;
  late WeightMode _currentWeightMode;

  @override
  void initState() {
    super.initState();
    _exerciseDetails =
        context.read<WorkoutViewModel>().getExerciseById(
          widget.routineExercise.exerciseId,
        )!;
    _initializeWeightMode();
  }

  void _initializeWeightMode() {
    if (_exerciseDetails.supportsWeight) {
      _currentWeightMode = WeightMode.weighted;
    } else if (_exerciseDetails.supportsBodyweight) {
      _currentWeightMode = WeightMode.bodyweight;
    } else if (_exerciseDetails.supportsAssistance) {
      _currentWeightMode = WeightMode.assisted;
    } else {
      _currentWeightMode = WeightMode.weighted;
    }
  }

  void _cycleWeightMode() {
    final modes = <WeightMode>[
      if (_exerciseDetails.supportsWeight) WeightMode.weighted,
      if (_exerciseDetails.supportsBodyweight) WeightMode.bodyweight,
      if (_exerciseDetails.supportsAssistance) WeightMode.assisted,
    ];
    if (modes.length < 2) return;

    final currentIndex = modes.indexOf(_currentWeightMode);
    final nextMode = modes[(currentIndex + 1) % modes.length];

    setState(() {
      _currentWeightMode = nextMode;
    });
  }

  void _addSet() {
    final newSetIndex = widget.routineExercise.plannedSets.length;
    setState(() {
      widget.routineExercise.plannedSets.add(PlannedSet());
    });
    _listKey.currentState?.insertItem(
      newSetIndex,
      duration: const Duration(milliseconds: 300),
    );
  }

  // **NEW METHOD**: Shows the confirmation dialog.
  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Exercise?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to delete "${widget.routineExercise.exerciseName}" from this routine?',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
                widget.onDelete(); // Execute the original delete function
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // **FIX 2 of 2: Replaced Card with a decorated Container.**
    // This gives us the same visual look but removes any built-in behaviors
    // from the Card widget that might interfere with the ReorderableListView's drag visuals.
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.routineExercise.exerciseName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: _showDeleteConfirmationDialog,
                ),
                ReorderableDragStartListener(
                  index: widget.index,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.drag_handle_rounded),
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildHeaderRow(context),
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
                    isCompleted: false,
                    weightMode: _currentWeightMode,
                    onChanged: (updatedSet) {
                      widget.routineExercise.plannedSets[setIndex] = updatedSet;
                    },
                    onCompleted: () {},
                  ),
                );
              },
            ),
            TextButton.icon(
              onPressed: _addSet,
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final settings = context.watch<UserSettingsProvider>();
    String label;
    Color color;

    switch (_currentWeightMode) {
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                child: InkWell(
                  onTap: _cycleWeightMode,
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
