import 'package:burnout/models/exercise_in_workout.dart';
import 'package:burnout/models/exercise_set.dart';
import 'package:burnout/models/exercise_type.dart';
import 'package:burnout/models/set_type.dart';
import 'package:burnout/models/workout_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutSessionScreen({Key? key, required this.workout}) : super(key: key);

  @override
  _WorkoutSessionScreenState createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late List<ExerciseInWorkout> sessionExercises;
  DateTime? startTime;
  DateTime? endTime;
  bool isFinished = false;
  Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    sessionExercises = widget.workout.exercises.map((exercise) => 
      ExerciseInWorkout(
        exerciseId: exercise.exerciseId,
        exerciseName: exercise.exerciseName,
        muscleGroup: exercise.muscleGroup,
        exerciseType: exercise.exerciseType,
        sets: exercise.sets.map((set) => ExerciseSet(
          setNumber: set.setNumber,
          setType: set.setType,
          targetReps: set.targetReps,
          targetWeight: set.targetWeight,
          targetDuration: set.targetDuration,
          targetDistance: set.targetDistance,
          actualReps: set.actualReps,
          actualWeight: set.actualWeight,
          actualDuration: set.actualDuration,
          actualDistance: set.actualDistance,
          isCompleted: false,
          notes: set.notes,
        )).toList(),
        notes: exercise.notes,
      )
    ).toList();
  }

  @override
  void dispose() {
    // Dispose all controllers
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  String _getControllerKey(int exerciseIndex, int setIndex, String field) {
    return '${exerciseIndex}_${setIndex}_$field';
  }

  TextEditingController _getController(int exerciseIndex, int setIndex, String field, String initialValue) {
    final key = _getControllerKey(exerciseIndex, setIndex, field);
    if (!controllers.containsKey(key)) {
      controllers[key] = TextEditingController(text: initialValue);
    }
    return controllers[key]!;
  }

  void _toggleSetComplete(int exerciseIndex, int setIndex) {
    setState(() {
      final currentSet = sessionExercises[exerciseIndex].sets[setIndex];
      final exercise = sessionExercises[exerciseIndex];
      
      // Update actual values from controllers when completing
      if (!currentSet.isCompleted) {
        ExerciseSet updatedSet = currentSet;
        
        if (exercise.hasReps) {
          final repsController = _getController(exerciseIndex, setIndex, 'reps', '${currentSet.actualReps ?? currentSet.targetReps ?? 0}');
          updatedSet = updatedSet.copyWith(actualReps: int.tryParse(repsController.text) ?? currentSet.targetReps);
        }
        
        if (exercise.hasWeight) {
          final weightController = _getController(exerciseIndex, setIndex, 'weight', '${currentSet.actualWeight ?? currentSet.targetWeight ?? 0}');
          updatedSet = updatedSet.copyWith(actualWeight: double.tryParse(weightController.text) ?? currentSet.targetWeight);
        }
        
        if (exercise.hasDuration) {
          final durationController = _getController(exerciseIndex, setIndex, 'duration', _formatDuration(currentSet.actualDuration ?? currentSet.targetDuration ?? Duration.zero));
          updatedSet = updatedSet.copyWith(actualDuration: _parseDuration(durationController.text) ?? currentSet.targetDuration);
        }
        
        if (exercise.hasDistance) {
          final distanceController = _getController(exerciseIndex, setIndex, 'distance', '${currentSet.actualDistance ?? currentSet.targetDistance ?? 0}');
          updatedSet = updatedSet.copyWith(actualDistance: double.tryParse(distanceController.text) ?? currentSet.targetDistance);
        }
        
        sessionExercises[exerciseIndex].sets[setIndex] = updatedSet.copyWith(isCompleted: true);
      } else {
        sessionExercises[exerciseIndex].sets[setIndex] = currentSet.copyWith(isCompleted: false);
      }
    });
  }

  void _addSet(int exerciseIndex, SetType setType) {
    setState(() {
      final exercise = sessionExercises[exerciseIndex];
      final normalSets = exercise.sets.where((s) => s.setType == SetType.normal).toList();
      final newSetNumber = normalSets.length + 1;
      final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;
      
      sessionExercises[exerciseIndex].sets.add(
        ExerciseSet(
          setNumber: setType == SetType.normal ? newSetNumber : 0, // Warmup and failure don't get numbers
          setType: setType,
          targetReps: exercise.hasReps ? (lastSet?.targetReps ?? 10) : null,
          targetWeight: exercise.hasWeight ? (lastSet?.targetWeight ?? 0) : null,
          targetDuration: exercise.hasDuration ? (lastSet?.targetDuration ?? Duration(minutes: 1)) : null,
          targetDistance: exercise.hasDistance ? (lastSet?.targetDistance ?? 1000) : null,
          isCompleted: false,
        ),
      );
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Duration? _parseDuration(String text) {
    final parts = text.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: minutes, seconds: seconds);
    }
    return null;
  }

  String _getSetDisplayNumber(ExerciseSet set, int actualIndex, List<ExerciseSet> allSets) {
    switch (set.setType) {
      case SetType.warmup:
        return 'W';
      case SetType.failure:
        return 'F';
      case SetType.normal:
        // Count only normal sets before this one
        int normalSetsBefore = 0;
        for (int i = 0; i < actualIndex; i++) {
          if (allSets[i].setType == SetType.normal) {
            normalSetsBefore++;
          }
        }
        return '${normalSetsBefore + 1}';
    }
  }

  Color _getSetTypeColor(SetType setType) {
    switch (setType) {
      case SetType.warmup:
        return Colors.orange;
      case SetType.failure:
        return Colors.red;
      case SetType.normal:
        return Colors.white;
    }
  }

  Widget _buildSetInput(ExerciseInWorkout exercise, ExerciseSet set, int exerciseIndex, int setIndex) {
    return Row(
      children: [
        // Set Number/Type
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: set.isCompleted
              ? BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                )
              : null,
          child: Text(
            _getSetDisplayNumber(set, setIndex, exercise.sets),
            style: TextStyle(
              color: set.isCompleted 
                  ? Colors.green[300] 
                  : _getSetTypeColor(set.setType),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 8),
        
        // Dynamic inputs based on exercise type
        if (exercise.hasReps) ...[
          Expanded(
            child: _buildNumericInput(
              controller: _getController(exerciseIndex, setIndex, 'reps', '${set.actualReps ?? set.targetReps ?? 0}'),
              hint: 'Reps',
              isCompleted: set.isCompleted,
            ),
          ),
          SizedBox(width: 8),
        ],
        
        if (exercise.hasWeight) ...[
          Expanded(
            child: _buildNumericInput(
              controller: _getController(exerciseIndex, setIndex, 'weight', '${set.actualWeight ?? set.targetWeight ?? 0}'),
              hint: exercise.exerciseType == ExerciseType.assistedBodyweight ? '-Weight' : 'Weight',
              isCompleted: set.isCompleted,
              isDecimal: true,
              isNegative: exercise.exerciseType == ExerciseType.assistedBodyweight,
            ),
          ),
          SizedBox(width: 8),
        ],
        
        if (exercise.hasDuration) ...[
          Expanded(
            child: _buildDurationInput(
              controller: _getController(exerciseIndex, setIndex, 'duration', _formatDuration(set.actualDuration ?? set.targetDuration ?? Duration.zero)),
              hint: 'Duration',
              isCompleted: set.isCompleted,
            ),
          ),
          SizedBox(width: 8),
        ],
        
        if (exercise.hasDistance) ...[
          Expanded(
            child: _buildNumericInput(
              controller: _getController(exerciseIndex, setIndex, 'distance', '${set.actualDistance ?? set.targetDistance ?? 0}'),
              hint: 'Distance',
              isCompleted: set.isCompleted,
              isDecimal: true,
            ),
          ),
          SizedBox(width: 8),
        ],
        
        // Checkbox
        GestureDetector(
          onTap: () => _toggleSetComplete(exerciseIndex, setIndex),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: set.isCompleted ? Colors.green : Colors.transparent,
              border: Border.all(
                color: set.isCompleted ? Colors.green : Colors.grey[600]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: set.isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildNumericInput({
    required TextEditingController controller,
    required String hint,
    required bool isCompleted,
    bool isDecimal = false,
    bool isNegative = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted 
            ? Colors.green.withOpacity(0.1)
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: isCompleted
            ? Border.all(color: Colors.green.withOpacity(0.3), width: 1)
            : null,
      ),
      child: TextField(
        controller: controller,
        keyboardType: isDecimal 
            ? TextInputType.numberWithOptions(decimal: true, signed: isNegative)
            : TextInputType.number,
        inputFormatters: [
          if (isDecimal && isNegative)
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))
          else if (isDecimal)
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
          else if (isNegative)
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))
          else
            FilteringTextInputFormatter.digitsOnly,
        ],
        style: TextStyle(
          color: isCompleted ? Colors.green[300] : Colors.white,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: isCompleted ? Colors.green[400] : Colors.grey[500],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationInput({
    required TextEditingController controller,
    required String hint,
    required bool isCompleted,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted 
            ? Colors.green.withOpacity(0.1)
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: isCompleted
            ? Border.all(color: Colors.green.withOpacity(0.3), width: 1)
            : null,
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
        ],
        style: TextStyle(
          color: isCompleted ? Colors.green[300] : Colors.white,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: isCompleted ? Colors.green[400] : Colors.grey[500],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showAddSetDialog(int exerciseIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Add Set', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Normal Set', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _addSet(exerciseIndex, SetType.normal);
              },
            ),
            ListTile(
              title: Text('Warmup Set', style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(context);
                _addSet(exerciseIndex, SetType.warmup);
              },
            ),
            ListTile(
              title: Text('Failure Set', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _addSet(exerciseIndex, SetType.failure);
              },
            ),
          ],
        ),
      ),
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
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.workout.name,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // Finish workout
              Navigator.pop(context, widget.workout.copyWith(lastCompleted: DateTime.now()));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Finish',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: sessionExercises.length,
        itemBuilder: (context, exerciseIndex) {
          final exercise = sessionExercises[exerciseIndex];
          
          return Container(
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
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
                  final set = entry.value;
                  
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildSetInput(exercise, set, exerciseIndex, setIndex),
                  );
                }).toList(),
                
                // Add Set Button
                GestureDetector(
                  onTap: () => _showAddSetDialog(exerciseIndex),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Add set',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}