import 'package:burnout/models/exercise_in_workout.dart';
import 'package:burnout/models/workout_model.dart'; // Add this import
import 'package:burnout/screens/workout_session_screen.dart'; // Add this import
import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  final String id; // Add an ID for the workout
  final String title;
  final List<ExerciseInWorkout> exercises;
  final List<Color> colors;
  final VoidCallback? onStart; // Add a callback for starting the workout

  const WorkoutCard({
    Key? key,
    required this.id, // Initialize the ID
    required this.title,
    required this.exercises,
    required this.colors,
    this.onStart, // Optional callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: colors
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
                        ...exercises.asMap().entries.take(3).map((entry) {
                          final idx = entry.key;
                          final e = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.exerciseName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${e.sets.length} Sets',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        if (exercises.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              'and ${exercises.length - 3} more...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40), // Add space for the button
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: ElevatedButton(
              onPressed: () async {
                // Call onStart callback before navigation if provided
                if (onStart != null) {
                  onStart!();
                }
                
                // Navigate to WorkoutSessionScreen with the current workout data
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutSessionScreen(
                      workout: WorkoutModel(
                        id: id, // Get workout id
                        name: title,
                        exercises: exercises,
                      ),
                    ),
                  ),
                );
                
                // Handle any result from the workout session if needed
                if (result != null) {
                  // You can handle the result here if WorkoutSessionScreen returns data
                  print('Workout session completed with result: $result');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Start'),
                  SizedBox(width: 6),
                  Icon(Icons.play_arrow),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}