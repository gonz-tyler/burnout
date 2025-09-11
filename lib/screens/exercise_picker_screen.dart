import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../viewmodels/workout_view_model.dart';

class ExercisePickerScreen extends StatefulWidget {
  final Set<String> initiallySelectedIds;

  const ExercisePickerScreen({
    Key? key,
    required this.initiallySelectedIds, // Make it required
  }) : super(key: key);

  @override
  State<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends State<ExercisePickerScreen> {
  // Holds the IDs of the exercises the user has ticked
  late final Set<String> _selectedExerciseIds;

  // State for the search functionality
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedExerciseIds = Set<String>.from(widget.initiallySelectedIds);
    // Listen for changes in the search field
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutViewModel = context.read<WorkoutViewModel>();
    final allExercises = workoutViewModel.exercises;

    // Filter the exercises based on the search query
    final filteredExercises =
        allExercises.where((exercise) {
          final exerciseName = exercise.name.toLowerCase();
          final query = _searchQuery.toLowerCase();
          return exerciseName.contains(query);
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercises'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final selectedExercises =
                  allExercises
                      .where((ex) => _selectedExerciseIds.contains(ex.id))
                      .toList();
              Navigator.of(context).pop(selectedExercises);
            },
            tooltip: 'Confirm Selection',
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Search Bar UI ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Exercises',
                hintText: 'e.g., Bench Press',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                // Add a clear button to the search bar
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
              ),
            ),
          ),
          // --- List of Exercises ---
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                final isSelected = _selectedExerciseIds.contains(exercise.id);

                return CheckboxListTile(
                  title: Text(exercise.name),
                  subtitle: Text(exercise.muscleGroup),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedExerciseIds.add(exercise.id);
                      } else {
                        _selectedExerciseIds.remove(exercise.id);
                      }
                    });
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
