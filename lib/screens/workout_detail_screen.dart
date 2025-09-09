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

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Delete Workout', style: TextStyle(color: Colors.red)),
              leading: Icon(Icons.delete, color: Colors.red),
              onTap: () {
                Navigator.pop(context);
                _deleteWorkout();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getSetDisplayText(ExerciseInWorkout exercise) {
    final normalSets = exercise.sets.where((s) => s.setType.toString() == 'SetType.normal').length;
    final warmupSets = exercise.sets.where((s) => s.setType.toString() == 'SetType.warmup').length;
    final failureSets = exercise.sets.where((s) => s.setType.toString() == 'SetType.failure').length;
    
    List<String> setParts = [];
    if (normalSets > 0) setParts.add('$normalSets');
    if (warmupSets > 0) setParts.add('${warmupSets}W');
    if (failureSets > 0) setParts.add('${failureSets}F');
    
    return setParts.join(' + ');
  }

  Widget _buildSetDisplay(ExerciseInWorkout exercise, int setIndex) {
    final set = exercise.sets[setIndex];
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              _getSetDisplayNumber(set, setIndex, exercise.sets),
              style: TextStyle(
                color: _getSetTypeColor(set.setType),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16),
          
          if (exercise.hasReps) ...[
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${set.targetReps ?? 0}',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
          
          if (exercise.hasWeight) ...[
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${set.targetWeight ?? 0}',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
          
          if (exercise.hasDuration) ...[
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatDuration(set.targetDuration ?? Duration.zero),
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
          
          if (exercise.hasDistance) ...[
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${set.targetDistance ?? 0}',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  String _getSetDisplayNumber(dynamic set, int actualIndex, List<dynamic> allSets) {
    // Simplified version - you may need to adjust based on your SetType enum
    final setTypeString = set.setType.toString();
    if (setTypeString.contains('warmup')) {
      return 'W';
    } else if (setTypeString.contains('failure')) {
      return 'F';
    } else {
      int normalSetsBefore = 0;
      for (int i = 0; i < actualIndex; i++) {
        if (allSets[i].setType.toString().contains('normal')) {
          normalSetsBefore++;
        }
      }
      return '${normalSetsBefore + 1}';
    }
  }

  Color _getSetTypeColor(dynamic setType) {
    final setTypeString = setType.toString();
    if (setTypeString.contains('warmup')) {
      return Colors.orange;
    } else if (setTypeString.contains('failure')) {
      return Colors.red;
    } else {
      return Colors.white;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
        title: Center(
          child: Text(
            currentWorkout.name,
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Start Workout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.play_arrow, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
                ),
                onPressed: _editWorkout,
                child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit Routine',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.edit, color: Colors.white),
            ],
                ),
              ),
            ),
          ),
          ...currentWorkout.exercises.asMap().entries.map((entry) {
            final exerciseIndex = entry.key;
            final exercise = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[700]!, width: 2),
              ),
              child: Column(
                children: [
            // Exercise Header
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
              child: Text(
                exercise.exerciseName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
                  ),
                ],
              ),
            ),
            // Sets List
            ...exercise.sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _buildSetDisplay(exercise, setIndex),
              );
            }).toList(),
            SizedBox(height: 16),
                ],
              ),
            );
          }).toList(),
          SizedBox(height: 20),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}