import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../viewmodels/workout_view_model.dart';
import '../widgets/planned_set_editor_row.dart'; // Import the row widget
import '../providers/user_settings_provider.dart'; // Import for KG/LB
import 'exercise_picker_screen.dart';
import '../models/enums.dart';

// enum WeightMode { weighted, bodyweight, assisted }

class RoutineEditorScreen extends StatefulWidget {
  final Routine? initialRoutine;

  const RoutineEditorScreen({Key? key, this.initialRoutine}) : super(key: key);

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final _nameController = TextEditingController();
  final List<RoutineExercise> _routineExercises = [];
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.initialRoutine != null;

  // Track weight mode for each exercise
  final Map<String, WeightMode> _exerciseWeightModes = {};

  @override
  void initState() {
    super.initState();
    // If an initial routine was passed, populate the fields for editing
    if (_isEditing) {
      final routine = widget.initialRoutine!;
      _nameController.text = routine.name;
      // Use copyWith to create a mutable deep copy for the editor
      _routineExercises.addAll(routine.exercises.map((e) => e.copyWith()));
    }
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
            // Initialize weight mode for new exercises
            _exerciseWeightModes[exercise.id] = WeightMode.weighted;
          }
        }
        _routineExercises.clear();
        _routineExercises.addAll(updatedList);
      });
    }
  }

  void _cycleWeightMode(String exerciseId, int exerciseIndex) {
    final exercise = context.read<WorkoutViewModel>().exercises.firstWhere(
      (ex) => ex.id == exerciseId,
    );

    final modes = <WeightMode>[];
    if (exercise.supportsWeight) modes.add(WeightMode.weighted);
    if (exercise.supportsBodyweight) modes.add(WeightMode.bodyweight);
    if (exercise.supportsAssistance) modes.add(WeightMode.assisted);

    if (modes.length < 2) return;

    final currentMode = _exerciseWeightModes[exerciseId] ?? WeightMode.weighted;
    final currentIndex = modes.indexOf(currentMode);
    final nextMode = modes[(currentIndex + 1) % modes.length];

    setState(() {
      _exerciseWeightModes[exerciseId] = nextMode;

      // Update all sets in this exercise based on new mode
      final routineExercise = _routineExercises[exerciseIndex];
      for (int i = 0; i < routineExercise.plannedSets.length; i++) {
        final currentSet = routineExercise.plannedSets[i];
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

        _routineExercises[exerciseIndex].plannedSets[i] = currentSet.copyWith(
          targetWeight: newWeight,
        );
      }
    });
  }

  void _saveRoutine() {
    if (_formKey.currentState!.validate()) {
      if (_routineExercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one exercise.')),
        );
        return;
      }

      if (_isEditing) {
        // --- EDIT LOGIC ---
        // Create the updated routine object, keeping the original ID
        final updatedRoutine = widget.initialRoutine!.copyWith(
          name: _nameController.text,
          exercises: _routineExercises,
        );
        context.read<WorkoutViewModel>().updateRoutine(updatedRoutine);
      } else {
        // --- CREATE LOGIC (your existing code) ---
        final newRoutine = Routine(
          id: const Uuid().v4(),
          name: _nameController.text,
          exercises: _routineExercises,
        );
        context.read<WorkoutViewModel>().addRoutine(newRoutine);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allExercisesMap = {
      for (var ex in context.read<WorkoutViewModel>().exercises) ex.id: ex,
    };

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
                        : _buildExerciseList(allExercisesMap),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseList(Map<String, Exercise> allExercisesMap) {
    return ListView.builder(
      itemCount: _routineExercises.length,
      itemBuilder: (context, exerciseIndex) {
        final routineExercise = _routineExercises[exerciseIndex];
        final exerciseDetails = allExercisesMap[routineExercise.exerciseId];
        if (exerciseDetails == null) return const SizedBox.shrink();

        // Initialize weight mode if not set - prioritize weighted mode
        if (_exerciseWeightModes[routineExercise.exerciseId] == null) {
          if (exerciseDetails.supportsWeight) {
            _exerciseWeightModes[routineExercise.exerciseId] =
                WeightMode.weighted;
          } else if (exerciseDetails.supportsBodyweight) {
            _exerciseWeightModes[routineExercise.exerciseId] =
                WeightMode.bodyweight;
          } else if (exerciseDetails.supportsAssistance) {
            _exerciseWeightModes[routineExercise.exerciseId] =
                WeightMode.assisted;
          }
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routineExercise.exerciseName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                // --- Header Row for Labels ---
                _buildHeaderRow(exerciseDetails, exerciseIndex),
                const Divider(),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: routineExercise.plannedSets.length,
                  itemBuilder: (context, setIndex) {
                    final currentWeightMode =
                        _exerciseWeightModes[routineExercise.exerciseId] ??
                        WeightMode.weighted;
                    return PlannedSetEditorRow(
                      key: ValueKey('${routineExercise.exerciseId}-$setIndex'),
                      plannedSet: routineExercise.plannedSets[setIndex],
                      exercise: exerciseDetails,
                      setIndex: setIndex,
                      allSets: routineExercise.plannedSets,
                      weightMode: currentWeightMode,
                      onChanged: (updatedSet) {
                        setState(() {
                          _routineExercises[exerciseIndex]
                                  .plannedSets[setIndex] =
                              updatedSet;
                        });
                      },
                      onDelete: () {
                        setState(() {
                          _routineExercises[exerciseIndex].plannedSets.removeAt(
                            setIndex,
                          );
                        });
                      },
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Set'),
                      onPressed: () {
                        setState(() {
                          _routineExercises[exerciseIndex].plannedSets.add(
                            PlannedSet(),
                          );
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow(Exercise exercise, int exerciseIndex) {
    final settings = context.watch<UserSettingsProvider>();
    final currentWeightMode =
        _exerciseWeightModes[exercise.id] ?? WeightMode.weighted;

    // Determine Primary Label (Weight or Distance)
    String primaryLabel = '';
    Color? primaryColor;
    VoidCallback? primaryOnTap;

    if (exercise.tracksDistance) {
      primaryLabel =
          context.watch<UserSettingsProvider>().distanceUnit.name.toUpperCase();
    } else if (exercise.supportsWeight ||
        exercise.supportsBodyweight ||
        exercise.supportsAssistance) {
      // Show weight mode in the header
      switch (currentWeightMode) {
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

      // Only make it clickable if multiple modes are supported
      final modes = <WeightMode>[];
      if (exercise.supportsWeight) modes.add(WeightMode.weighted);
      if (exercise.supportsBodyweight) modes.add(WeightMode.bodyweight);
      if (exercise.supportsAssistance) modes.add(WeightMode.assisted);

      if (modes.length > 1) {
        primaryOnTap = () => _cycleWeightMode(exercise.id, exerciseIndex);
      }
    }

    // Determine Secondary Label (Reps or Time)
    String secondaryLabel = '';
    if (exercise.tracksDuration) {
      secondaryLabel = 'TIME';
    } else if (exercise.tracksReps) {
      secondaryLabel = 'REPS';
    }

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
          _buildLabel('', width: 50), // For alignment with delete button
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
      labelWidget = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: labelWidget,
        ),
      );
    }

    return labelWidget;
  }
}
