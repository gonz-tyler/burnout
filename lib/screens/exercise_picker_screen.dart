// lib/screens/exercise_picker_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../viewmodels/workout_view_model.dart';

class ExercisePickerScreen extends StatefulWidget {
  final Set<String> initiallySelectedIds;

  const ExercisePickerScreen({super.key, this.initiallySelectedIds = const {}});

  @override
  State<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends State<ExercisePickerScreen> {
  late final Set<String> _selectedExerciseIds;
  List<Exercise> _filteredExercises = [];
  final TextEditingController _searchController = TextEditingController();
  late final List<Exercise> _allExercises;

  @override
  void initState() {
    super.initState();
    _selectedExerciseIds = Set.from(widget.initiallySelectedIds);
    _allExercises = context.read<WorkoutViewModel>().exercises;
    _filteredExercises = _allExercises;

    // --- DEBUGGING PRINT STATEMENT ---
    // This will print the list of exercises to your debug console.
    // If the list is empty, it confirms the data isn't being loaded from Hive correctly.
    debugPrint("--- Exercise Picker Loaded ---");
    debugPrint("Found ${_allExercises.length} total exercises.");
    // Uncomment the line below to see every single exercise name
    // _allExercises.forEach((ex) => debugPrint("- ${ex.name}"));
    // ---------------------------------

    _searchController.addListener(_filterExercises);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterExercises);
    _searchController.dispose();
    super.dispose();
  }

  void _filterExercises() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredExercises = _allExercises;
      } else {
        _filteredExercises =
            _allExercises
                .where((ex) => ex.name.toLowerCase().contains(query))
                .toList();
      }
    });
  }

  void _toggleSelection(String exerciseId) {
    setState(() {
      if (_selectedExerciseIds.contains(exerciseId)) {
        _selectedExerciseIds.remove(exerciseId);
      } else {
        _selectedExerciseIds.add(exerciseId);
      }
    });
  }

  void _saveSelection() {
    final selectedExercises =
        _allExercises
            .where((ex) => _selectedExerciseIds.contains(ex.id))
            .toList();
    Navigator.of(context).pop(selectedExercises);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercises'),
        actions: [
          TextButton(onPressed: _saveSelection, child: const Text('Done')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.5),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = _filteredExercises[index];
                final isSelected = _selectedExerciseIds.contains(exercise.id);
                return ListTile(
                  title: Text(exercise.name),
                  subtitle: Text(exercise.muscleGroup),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      _toggleSelection(exercise.id);
                    },
                  ),
                  onTap: () {
                    _toggleSelection(exercise.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
