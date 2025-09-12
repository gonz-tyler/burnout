// lib/screens/routine_editor_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../viewmodels/workout_view_model.dart';
import '../widgets/planned_set_editor_row.dart';
import '../providers/user_settings_provider.dart';
import 'exercise_picker_screen.dart';
import '../models/enums.dart';

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
      // Deep copy to ensure the original routine isn't mutated until saved
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
                plannedSets: [
                  PlannedSet(setType: SetType.normal, targetReps: ''),
                ],
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

      final routineToSave =
          _isEditing
              ? widget.initialRoutine!.copyWith(
                name: _nameController.text,
                exercises: _routineExercises,
              )
              : Routine(
                id: const Uuid().v4(),
                name: _nameController.text,
                exercises: _routineExercises,
              );

      if (_isEditing) {
        context.read<WorkoutViewModel>().updateRoutine(routineToSave);
      } else {
        context.read<WorkoutViewModel>().addRoutine(routineToSave);
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
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRoutine,
            tooltip: 'Save Routine',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
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
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _addExercises,
                icon: const Icon(Icons.add),
                label: const Text('Add / Edit Exercises'),
              ),
              const SizedBox(height: 16),
              const Divider(),
              Text('Exercises', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Expanded(
                child:
                    _routineExercises.isEmpty
                        ? const Center(child: Text('No exercises added yet.'))
                        : _buildExerciseList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    final allExercisesMap = {
      for (var ex in context.read<WorkoutViewModel>().exercises) ex.id: ex,
    };

    // **PERFORMANCE FIX 1: ReorderableListView**
    // Allows for efficient drag-and-drop reordering of exercises.
    return ReorderableListView.builder(
      itemCount: _routineExercises.length,
      itemBuilder: (context, index) {
        final routineExercise = _routineExercises[index];
        final exerciseDetails = allExercisesMap[routineExercise.exerciseId];

        if (exerciseDetails == null) {
          // Return a container with a key to prevent errors
          return Container(key: ValueKey('empty_$index'));
        }

        return _ExerciseCard(
          // Use a unique, stable key for each item
          key: ValueKey(routineExercise.hashCode),
          routineExercise: routineExercise,
          exerciseDetails: exerciseDetails,
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _routineExercises.removeAt(oldIndex);
          _routineExercises.insert(newIndex, item);
        });
      },
    );
  }
}

// **PERFORMANCE FIX 2: State Isolation**
// This widget now fully manages its own state, preventing the entire
// screen from rebuilding when a single set is added, deleted, or changed.
class _ExerciseCard extends StatefulWidget {
  final RoutineExercise routineExercise;
  final Exercise exerciseDetails;

  const _ExerciseCard({
    super.key,
    required this.routineExercise,
    required this.exerciseDetails,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late WeightMode _currentWeightMode;

  @override
  void initState() {
    super.initState();
    _initializeWeightMode();
  }

  void _initializeWeightMode() {
    final exercise = widget.exerciseDetails;
    if (exercise.supportsWeight) {
      _currentWeightMode = WeightMode.weighted;
    } else if (exercise.supportsBodyweight) {
      _currentWeightMode = WeightMode.bodyweight;
    } else if (exercise.supportsAssistance) {
      _currentWeightMode = WeightMode.assisted;
    } else {
      _currentWeightMode = WeightMode.weighted;
    }
  }

  void _addSet() {
    // This setState call only rebuilds this specific _ExerciseCard
    setState(() {
      final newSetIndex = widget.routineExercise.plannedSets.length;
      widget.routineExercise.plannedSets.add(PlannedSet());
      _listKey.currentState?.insertItem(
        newSetIndex,
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  void _deleteSet(int setIndex) {
    // The data model is updated directly. The animation handles the UI removal.
    final removedSet = widget.routineExercise.plannedSets.removeAt(setIndex);
    _listKey.currentState?.removeItem(
      setIndex,
      (context, animation) => _buildRemovedSet(context, animation, removedSet),
      duration: const Duration(milliseconds: 300),
    );
    // A setState is needed to update other widgets within the card if necessary,
    // like set number labels.
    setState(() {});
  }

  void _cycleWeightMode() {
    final exercise = widget.exerciseDetails;
    final modes = <WeightMode>[
      if (exercise.supportsWeight) WeightMode.weighted,
      if (exercise.supportsBodyweight) WeightMode.bodyweight,
      if (exercise.supportsAssistance) WeightMode.assisted,
    ];

    if (modes.length < 2) return;

    final currentIndex = modes.indexOf(_currentWeightMode);
    final nextMode = modes[(currentIndex + 1) % modes.length];

    // Local setState ensures only this card rebuilds
    setState(() {
      _currentWeightMode = nextMode;
      for (int i = 0; i < widget.routineExercise.plannedSets.length; i++) {
        final currentSet = widget.routineExercise.plannedSets[i];
        final currentWeight = currentSet.targetWeight ?? 0;
        double newWeight;
        switch (nextMode) {
          case WeightMode.weighted:
            newWeight = currentWeight.abs();
            break;
          case WeightMode.bodyweight:
            newWeight = 0;
            break;
          case WeightMode.assisted:
            newWeight = currentWeight == 0 ? -20.0 : -currentWeight.abs();
            break;
        }
        widget.routineExercise.plannedSets[i] = currentSet.copyWith(
          targetWeight: newWeight,
        );
      }
    });
  }

  Widget _buildRemovedSet(
    BuildContext context,
    Animation<double> animation,
    PlannedSet removedSet,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: Opacity(
        opacity: animation.value,
        child: PlannedSetEditorRow(
          mode: EditorMode.planning, // Corrected from 'template'
          plannedSet: removedSet,
          exercise: widget.exerciseDetails,
          setIndex: -1,
          allSets: const [],
          weightMode: _currentWeightMode,
          isCompleted: false,
          onChanged: (_) {},
          onCompleted: () {},
          onDelete: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // This handle is for the ReorderableListView
            ReorderableDragStartListener(
              index: Provider.of<int>(context), // Assumes index is provided
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.routineExercise.exerciseName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Icon(Icons.drag_handle, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildHeaderRow(widget.exerciseDetails),
            const Divider(),
            AnimatedList(
              key: _listKey,
              initialItemCount: widget.routineExercise.plannedSets.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, setIndex, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: PlannedSetEditorRow(
                    mode: EditorMode.planning, // Corrected from 'template'
                    plannedSet: widget.routineExercise.plannedSets[setIndex],
                    exercise: widget.exerciseDetails,
                    setIndex: setIndex,
                    allSets: widget.routineExercise.plannedSets,
                    weightMode: _currentWeightMode,
                    // No need for a separate callback, changes are handled by the row's controllers
                    onChanged: (updatedSet) {
                      widget.routineExercise.plannedSets[setIndex] = updatedSet;
                    },
                    onDelete: () => _deleteSet(setIndex),
                    isCompleted: false,
                    onCompleted: () {},
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Set'),
                  onPressed: _addSet,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(Exercise exercise) {
    // ... This method's implementation remains the same
    final settings = context.watch<UserSettingsProvider>();
    String primaryLabel = '';
    Color? primaryColor;
    VoidCallback? primaryOnTap;

    if (exercise.tracksDistance) {
      primaryLabel = settings.distanceUnit.name.toUpperCase();
    } else if (exercise.supportsWeight ||
        exercise.supportsBodyweight ||
        exercise.supportsAssistance) {
      switch (_currentWeightMode) {
        case WeightMode.weighted:
          primaryLabel = settings.weightUnit.name.toUpperCase();
          primaryColor = Colors.blue;
          break;
        case WeightMode.bodyweight:
          primaryLabel = 'BW';
          primaryColor = Colors.green;
          break;
        case WeightMode.assisted:
          primaryLabel = '-${settings.weightUnit.name.toUpperCase()}';
          primaryColor = Colors.orange;
          break;
      }
      final modes = <WeightMode>[
        if (exercise.supportsWeight) WeightMode.weighted,
        if (exercise.supportsBodyweight) WeightMode.bodyweight,
        if (exercise.supportsAssistance) WeightMode.assisted,
      ];
      if (modes.length > 1) {
        primaryOnTap = _cycleWeightMode;
      }
    }

    String secondaryLabel =
        exercise.tracksDuration ? 'TIME' : (exercise.tracksReps ? 'REPS' : '');
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLabel('SET', width: 50),
          _buildLabel('PREV'),
          _buildLabel(
            primaryLabel,
            color: primaryColor,
            onTap: primaryOnTap,
            isClickable: primaryOnTap != null,
          ),
          _buildLabel(secondaryLabel),
          _buildLabel('', width: 50),
        ],
      ),
    );
  }

  Widget _buildLabel(
    String text, {
    double width = 70.0,
    Color? color,
    VoidCallback? onTap,
    bool isClickable = false,
  }) {
    Widget labelWidget = SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color ?? Colors.grey[600],
          fontWeight: isClickable ? FontWeight.bold : null,
        ),
      ),
    );
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: labelWidget,
        ),
      );
    }
    return labelWidget;
  }
}
