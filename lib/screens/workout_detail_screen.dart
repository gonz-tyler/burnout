import 'package:burnout/models/exercise_in_workout.dart';
import 'package:flutter/material.dart';
import 'package:burnout/models/workout_model.dart';
import 'package:burnout/screens/workout_session_screen.dart';
import 'package:burnout/screens/edit_workout_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutModel workout;
  final Function(WorkoutModel) onWorkoutUpdated;
  final Function(String) onWorkoutDeleted;

  const WorkoutDetailScreen({
    Key? key,
    required this.workout,
    required this.onWorkoutUpdated,
    required this.onWorkoutDeleted,
  }) : super(key: key);

  @override
  _WorkoutDetailScreenState createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late WorkoutModel currentWorkout;

  @override
  void initState() {
    super.initState();
    currentWorkout = widget.workout;
  }

  void _startWorkout() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSessionScreen(workout: currentWorkout),
      ),
    );
    
    if (result != null && result is WorkoutModel) {
      setState(() {
        currentWorkout = result;
      });
      widget.onWorkoutUpdated(result);
    }
  }

  void _editWorkout() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWorkoutScreen(workout: currentWorkout),
      ),
    );
    
    if (result != null && result is WorkoutModel) {
      setState(() {
        currentWorkout = result;
      });
      widget.onWorkoutUpdated(result);
    }
  }

  void _deleteWorkout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Delete Workout',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${currentWorkout.name}"? This action cannot be undone.',
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
            ),
            TextButton(
              onPressed: () {
                widget.onWorkoutDeleted(currentWorkout.id);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close detail screen
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: _editWorkout,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            color: Colors.grey[800],
            onSelected: (value) {
              if (value == 'delete') {
                _deleteWorkout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Workout Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.fitness_center, 
                                   color: Colors.white, size: 28),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  currentWorkout.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (currentWorkout.description.isNotEmpty) ...[
                            SizedBox(height: 8),
                            Text(
                              currentWorkout.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                          SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStatItem(
                                'Exercises', 
                                currentWorkout.exercises.length.toString()
                              ),
                              _buildStatItem(
                                'Sets', 
                                currentWorkout.totalSets.toString()
                              ),
                              _buildStatItem(
                                'Last', 
                                currentWorkout.lastCompleted != null 
                                  ? _formatLastCompleted(currentWorkout.lastCompleted!)
                                  : 'Never'
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Exercises List
                    Text(
                      'Exercises (${currentWorkout.exercises.length})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    ...currentWorkout.exercises.asMap().entries.map((entry) {
                      int index = entry.key;
                      ExerciseInWorkout exercise = entry.value;
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blueGrey[700],
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.exerciseName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${exercise.sets} sets',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
                                    SizedBox(height: 6),
                                    Text(
                                      exercise.notes!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    
                    if (currentWorkout.exercises.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'No exercises added yet.',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Start Workout Button
            Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: currentWorkout.exercises.isEmpty ? null : _startWorkout,
                  child: Text(
                    'Start Workout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastCompleted(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}