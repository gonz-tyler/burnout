import 'package:burnout/models/exercise_in_workout.dart';
import 'package:burnout/models/exercise_set.dart';
import 'package:burnout/models/exercise_type.dart';
import 'package:burnout/models/set_type.dart';
import 'package:burnout/models/workout_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class CreateWorkoutScreen extends StatefulWidget {
  final WorkoutModel? existingWorkout;

  const CreateWorkoutScreen({Key? key, this.existingWorkout}) : super(key: key);

  @override
  CreateWorkoutScreenState createState() => CreateWorkoutScreenState();
}

class CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  
  List<ExerciseInWorkout> workoutExercises = [];
  List<Map<String, dynamic>> availableExercises = [];
  List<Map<String, dynamic>> filteredExercises = [];
  Set<int> selectedExerciseIndices = {};
  String selectedMuscleGroup = 'All';
  bool isSelectingExercises = false;
  
  final List<String> muscleGroups = [
    'All',
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Biceps',
    'Legs',
    'Quads',
    'Hamstrings',
    'Core',
    'Cardio',
    'Full Body'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingWorkout != null) {
      _nameController.text = widget.existingWorkout!.name;
      workoutExercises = List.from(widget.existingWorkout!.exercises);
    }
    _loadExercises();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    try {
      String jsonString = await rootBundle.loadString('lib/data/standardized_exercises.json');
      List<dynamic> jsonList = json.decode(jsonString);
      availableExercises = jsonList.cast<Map<String, dynamic>>();
      
      setState(() {
        _filterExercises();
      });
    } catch (e) {
      print('Error loading exercises: $e');
    }
  }

  void _filterExercises() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredExercises = availableExercises.where((exercise) {
        String muscleGroup = exercise['muscleGroup']?.toString() ?? '';
        String exerciseName = exercise['name']?.toString() ?? '';
        
        bool matchesMuscleGroup = selectedMuscleGroup == 'All' || 
                                 muscleGroup == selectedMuscleGroup;
        bool matchesSearch = query.isEmpty ||
                           exerciseName.toLowerCase().contains(query) ||
                           muscleGroup.toLowerCase().contains(query);
        return matchesMuscleGroup && matchesSearch;
      }).toList();
    });
  }

  void _search(String query) {
    _filterExercises();
  }

  String _getExerciseTypeDisplayName(String type) {
    switch (type) {
      case 'Weighted Reps':
        return 'Weighted Reps';
      case 'Duration':
        return 'Duration';
      case 'Duration + Distance':
        return 'Duration + Distance';
      case 'Assisted Bodyweight':
        return 'Assisted Bodyweight';
      case 'Bodyweight Reps':
        return 'Bodyweight Reps';
      case 'Weighted Bodyweight':
        return 'Weighted Bodyweight';
      case 'Weight + Distance':
        return 'Weight + Distance';
      default:
        return 'Weighted Reps'; // Default case for unknown types
    }
  }

  Color _getColorForMuscleGroup(String group) {
    if (group == null) return Colors.grey;
    
    switch (group.toLowerCase()) {
      case 'chest':
        return Colors.pink;
      case 'back':
        return Colors.green;
      case 'arms':
      case 'biceps':
        return Colors.purple;
      case 'shoulders':
        return Colors.orange;
      case 'legs':
      case 'quads':
      case 'hamstrings':
        return Colors.blue;
      case 'core':
        return Colors.teal;
      case 'cardio':
        return Colors.red;
      case 'full body':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  ExerciseSet _getDefaultSet(String exerciseType, int setNumber) {
    switch (exerciseType) {
      case 'Weighted Reps':
        return ExerciseSet(setNumber: setNumber, targetReps: 10, targetWeight: 0, setType: SetType.normal);
      case 'Duration':
        return ExerciseSet(setNumber: setNumber, targetDuration: Duration(minutes: 1), setType: SetType.normal);
      case 'Duration + Distance':
        return ExerciseSet(setNumber: setNumber, targetDuration: Duration(minutes: 5), targetDistance: 1000, setType: SetType.normal);
      case 'Assisted Bodyweight':
        return ExerciseSet(setNumber: setNumber, targetReps: 8, targetAssistedBodyweight: 20, setType: SetType.normal);
      case 'Weighted Bodyweight':
        return ExerciseSet(setNumber: setNumber, targetReps: 10, targetWeightedBodyweight: 10, setType: SetType.normal);
      case 'Bodyweight Reps':
        return ExerciseSet(setNumber: setNumber, targetReps: 10, setType: SetType.normal);
      case 'Weight + Distance':
        return ExerciseSet(setNumber: setNumber, targetWeight: 50, targetDistance: 100, setType: SetType.normal);
      default:
        throw Exception('Unknown exercise type: $exerciseType');
    }
  }

  void _openExerciseSelection() {
    setState(() {
      isSelectingExercises = true;
      selectedExerciseIndices.clear();
      _searchController.clear();
      selectedMuscleGroup = 'All';
      _filterExercises();
    });
  }

  void _confirmExerciseSelection() {
    List<ExerciseInWorkout> newExercises = [];
    
    for (int index in selectedExerciseIndices) {
      final exerciseData = filteredExercises[index];
      print('Selected exercise: $exerciseData');
      final exerciseType = exerciseData['type']?.toString() ?? 'Weighted Reps';
      final exerciseName = exerciseData['name']?.toString() ?? 'Unknown Exercise';
      final muscleGroup = exerciseData['muscleGroup']?.toString() ?? 'Unknown';
      
      final exercise = ExerciseInWorkout(
        exerciseId: exerciseName.toLowerCase().replaceAll(' ', '_'),
        exerciseName: exerciseName,
        muscleGroup: muscleGroup,
        exerciseType: exerciseType,
        sets: [_getDefaultSet(exerciseType, 1)],
        notes: '',
      );
      
      newExercises.add(exercise);
    }
    
    setState(() {
      workoutExercises.addAll(newExercises);
      isSelectingExercises = false;
      selectedExerciseIndices.clear();
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final exercise = workoutExercises[exerciseIndex];
      final newSetNumber = exercise.sets.length + 1;
      final newSet = _getDefaultSet(exercise.exerciseType, newSetNumber);
      exercise.sets.add(newSet);
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      final exercise = workoutExercises[exerciseIndex];
      if (exercise.sets.length > 1) {
        exercise.sets.removeAt(setIndex);
        // Renumber remaining sets
        for (int i = 0; i < exercise.sets.length; i++) {
          exercise.sets[i].setNumber = i + 1;
        }
      }
    });
  }

  void _removeExercise(int exerciseIndex) {
    setState(() {
      workoutExercises.removeAt(exerciseIndex);
    });
  }

  void _saveWorkout() {
    if (_nameController.text.isNotEmpty && workoutExercises.isNotEmpty) {
      final workout = WorkoutModel(
        id: widget.existingWorkout?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: '',
        exercises: workoutExercises,
      );

      Navigator.pop(context, workout);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a workout name and at least one exercise')),
      );
    }
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, int index) {
    final bool isSelected = selectedExerciseIndices.contains(index);
    final String muscleGroup = exercise['muscleGroup']?.toString() ?? 'Unknown';
    final String exerciseName = exercise['name']?.toString() ?? 'Unknown Exercise';
    final String exerciseType = exercise['type']?.toString() ?? 'Weighted Reps';
    final Color color = _getColorForMuscleGroup(muscleGroup);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: color, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedExerciseIndices.remove(index);
              } else {
                selectedExerciseIndices.add(index);
              }
            });
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        muscleGroup,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _getExerciseTypeDisplayName(exerciseType),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetRow(ExerciseInWorkout exercise, int exerciseIndex, int setIndex) {
    final set = exercise.sets[setIndex];
    // TODO: Handle different weight units based on user preference or locale
    final String weightUnit = 'KG';
    final String distanceUnit = 'km';
    
    switch (exercise.exerciseType) { 
      case 'Duration':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text('${set.setNumber}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'MIN',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: set.targetDuration?.inMinutes.toString() ?? '1'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removeSet(exerciseIndex, setIndex),
              ),
            ],
          ),
        );
      
      case 'Duration + Distance':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text('${set.setNumber}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'MIN',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: set.targetDuration?.inMinutes.toString() ?? '5'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: distanceUnit,
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: set.targetDistance?.toString() ?? '1000'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removeSet(exerciseIndex, setIndex),
              ),
            ],
          ),
        );
      
      case 'Assisted Bodyweight':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text('${set.setNumber}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '-${weightUnit}',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: set.targetAssistedBodyweight?.toString() ?? '20'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'REPS',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: set.targetReps?.toString() ?? '8'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removeSet(exerciseIndex, setIndex),
              ),
            ],
          ),
        );
      
      case 'Weighted Bodyweight':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text('${set.setNumber}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '+$weightUnit,',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: set.targetWeight?.toString() ?? '10'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Reps',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: set.targetReps?.toString() ?? '10'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removeSet(exerciseIndex, setIndex),
              ),
            ],
          ),
        );

      case 'Bodyweight Reps':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text('${set.setNumber}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'REPS',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: set.targetReps?.toString() ?? '10'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removeSet(exerciseIndex, setIndex),
              ),
            ],
          ),
        );
      
      case 'Weight + Distance':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text('${set.setNumber}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: weightUnit,
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: set.targetWeight?.toString() ?? '50'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: distanceUnit,
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: set.targetDistance?.toString() ?? '100'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removeSet(exerciseIndex, setIndex),
              ),
            ],
          ),
        );

      default:
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Text('${set.setNumber}', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: weightUnit,
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: set.targetWeight?.toString() ?? '0'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'REPS',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: set.targetReps?.toString() ?? '0'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => _removeSet(exerciseIndex, setIndex),
                ),
              ],
            ),
          );
      
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isSelectingExercises) {
      // Exercise Selection Screen with ExercisesPage styling
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Select Exercises', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              setState(() {
                isSelectingExercises = false;
                selectedExerciseIndices.clear();
              });
            },
          ),
          actions: [
            if (selectedExerciseIndices.isNotEmpty)
              IconButton(
                icon: Icon(Icons.check, color: Colors.white),
                onPressed: _confirmExerciseSelection,
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _search,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.grey[500]),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.filter_list, color: Colors.white),
                        onSelected: (value) {
                          setState(() {
                            selectedMuscleGroup = value;
                            _filterExercises();
                          });
                        },
                        itemBuilder: (context) => muscleGroups.map((group) {
                          return PopupMenuItem<String>(
                            value: group,
                            child: Row(
                              children: [
                                if (selectedMuscleGroup == group)
                                  Icon(Icons.check, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(group),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selected count
              if (selectedExerciseIndices.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selectedExerciseIndices.length} exercise(s) selected',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _confirmExerciseSelection,
                        child: Text('Add Selected'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Exercise List
              Expanded(
                child: filteredExercises.isEmpty
                    ? Center(
                        child: Text(
                          "No exercises found",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = filteredExercises[index];
                          return _buildExerciseCard(exercise, index);
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    }

    // Main Workout Creation Screen
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Workout Name',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveWorkout,
          ),
        ],
      ),
      body: workoutExercises.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _openExerciseSelection,
                    icon: Icon(Icons.add),
                    label: Text('Add Exercise'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Add Exercise Button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _openExerciseSelection,
                    icon: Icon(Icons.add),
                    label: Text('Add Exercise'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                // Exercise List
                Expanded(
                  child: ListView.builder(
                    itemCount: workoutExercises.length,
                    itemBuilder: (context, exerciseIndex) {
                      final exercise = workoutExercises[exerciseIndex];
                      
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Exercise Header
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.exerciseName,
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${exercise.muscleGroup} • ${_getExerciseTypeDisplayName(exercise.exerciseType)}, ${exercise.exerciseType}',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeExercise(exerciseIndex),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Sets
                              ...exercise.sets.asMap().entries.map((entry) {
                                int setIndex = entry.key;
                                return _buildSetRow(exercise, exerciseIndex, setIndex);
                              }).toList(),
                              
                              // Add Set Button
                              SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => _addSet(exerciseIndex),
                                icon: Icon(Icons.add),
                                label: Text('Add Set'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}