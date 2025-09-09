// screens/workout_screen.dart
import 'package:burnout/services/workout_storage.dart';
import 'package:flutter/material.dart';
import 'package:burnout/widgets/workout_card.dart';
import 'package:burnout/screens/workout_detail_screen.dart';
import 'package:burnout/screens/create_workout_screen.dart';
import 'package:burnout/models/workout_model.dart';
import 'package:burnout/data/sample_data.dart';

class WorkoutsPage extends StatefulWidget {
  @override
  _WorkoutsPageState createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  List<WorkoutModel> workouts = [];
  String searchQuery = '';
  bool isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _loadWorkouts(); // Load workouts when screen initializes
  }

  // Load workouts from storage
  Future<void> _loadWorkouts() async {
    try {
      final loadedWorkouts = await WorkoutStorage.loadWorkouts();
      setState(() {
        workouts = loadedWorkouts;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading workouts: $e');
      setState(() {
        workouts = [];
        isLoading = false;
      });
    }
  }

  // Add workout and save to storage
  Future<void> _addWorkout(WorkoutModel workout) async {
    try {
      setState(() {
        workouts.add(workout);
      });
      await WorkoutStorage.saveWorkouts(workouts);
    } catch (e) {
      print('Error saving workout: $e');
      // Revert the state if save failed
      setState(() {
        workouts.removeLast();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save workout')),
      );
    }
  }

  // Update workout and save to storage
  Future<void> _updateWorkout(WorkoutModel updatedWorkout) async {
    try {
      setState(() {
        int index = workouts.indexWhere((w) => w.id == updatedWorkout.id);
        if (index != -1) {
          workouts[index] = updatedWorkout;
        }
      });
      await WorkoutStorage.saveWorkouts(workouts);
    } catch (e) {
      print('Error updating workout: $e');
      // Reload workouts if update failed
      await _loadWorkouts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update workout')),
      );
    }
  }

  // Delete workout and save to storage
  Future<void> _deleteWorkout(String workoutId) async {
    try {
      // Store the workout in case we need to restore it
      WorkoutModel? deletedWorkout;
      int deletedIndex = -1;
      
      setState(() {
        deletedIndex = workouts.indexWhere((w) => w.id == workoutId);
        if (deletedIndex != -1) {
          deletedWorkout = workouts[deletedIndex];
          workouts.removeAt(deletedIndex);
        }
      });
      
      await WorkoutStorage.saveWorkouts(workouts);
    } catch (e) {
      print('Error deleting workout: $e');
      // Reload workouts if delete failed
      await _loadWorkouts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete workout')),
      );
    }
  }

  List<WorkoutModel> get filteredWorkouts {
    if (searchQuery.isEmpty) return workouts;
    return workouts.where((workout) =>
        workout.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        workout.description.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Workouts',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.refresh, color: Colors.white),
                                onPressed: _loadWorkouts, // Add refresh button
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.white),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateWorkoutScreen(),
                                    ),
                                  );
                                  if (result != null && result is WorkoutModel) {
                                    await _addWorkout(result);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search workouts...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.grey[500]),
                          ),
                          style: TextStyle(color: Colors.white),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : filteredWorkouts.isEmpty 
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.fitness_center,
                                      size: 64,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      searchQuery.isEmpty 
                                        ? 'No workouts yet'
                                        : 'No workouts found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      searchQuery.isEmpty
                                        ? 'Create your first workout to get started'
                                        : 'Try a different search term',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredWorkouts.length,
                                itemBuilder: (context, index) {
                                  final workout = filteredWorkouts[index];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: GestureDetector(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WorkoutDetailScreen(
                                              workout: workout,
                                              onWorkoutUpdated: _updateWorkout,
                                              onWorkoutDeleted: _deleteWorkout,
                                            ),
                                          ),
                                        );
                                        if (result != null && result is WorkoutModel) {
                                          await _updateWorkout(result);
                                        }
                                      },
                                      child: WorkoutCard(
                                        id: workout.id,
                                        title: workout.name,
                                        exercises: workout.exercises,
                                        colors: workout.exercises
                                            .map((e) {
                                              final colorMap = {
                                                'Chest': Colors.pink,
                                                'Back': Colors.green,
                                                'Shoulders': Colors.orange,
                                                'Arms': Colors.purple,
                                                'Legs': Colors.blue,
                                                'Core': Colors.yellow,
                                                'Cardio': Colors.red,
                                                'Full Body': Colors.teal,
                                                'Hamstrings': Colors.red,
                                                'Quads': Colors.blue,
                                                'Biceps': Colors.purple,
                                              };
                                              return colorMap[e.muscleGroup] ?? Colors.grey;
                                            })
                                            .toSet()
                                            .toList(),

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
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Workout Card Widget
class EnhancedWorkoutCard extends StatelessWidget {
  final WorkoutModel workout;

  const EnhancedWorkoutCard({
    Key? key,
    required this.workout,
  }) : super(key: key);

  List<Color> get muscleGroupColors {
    Map<String, Color> colorMap = {
      'Chest': Colors.pink,
      'Back': Colors.green,
      'Shoulders': Colors.orange,
      'Arms': Colors.purple,
      'Legs': Colors.blue,
      'Core': Colors.yellow,
      'Cardio': Colors.red,
      'Full Body': Colors.teal,
      'Hamstrings': Colors.red,
      'Quads': Colors.blue,
      'Biceps': Colors.purple,
    };

    Set<String> uniqueMuscleGroups = workout.exercises
        .map((e) => e.muscleGroup)
        .toSet();

    return uniqueMuscleGroups
        .map((group) => colorMap[group] ?? Colors.grey)
        .toList();
  }

  String get lastSessionText {
    if (workout.lastCompleted == null) return '-';
    
    final now = DateTime.now();
    final difference = now.difference(workout.lastCompleted!);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    
    return '${workout.lastCompleted!.day}.${workout.lastCompleted!.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (workout.description.isNotEmpty)
                      Text(
                        workout.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[600]),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: muscleGroupColors
                .take(5)
                .map((color) => Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.exercises.length.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Exercises',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.totalSets.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Sets',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lastSessionText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Last Session',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}