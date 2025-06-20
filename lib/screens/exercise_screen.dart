import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:burnout/widgets/exercise_card.dart';
import 'package:burnout/models/exercise_model.dart';

class ExercisesPage extends StatefulWidget {
  @override
  _ExercisesPageState createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  List<ExerciseModel> allExercises = [];
  List<ExerciseModel> filteredExercises = [];

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  Future<void> loadExercises() async {
    final String jsonString = await rootBundle.loadString('lib/data/standardized_exercises.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);
    final List<ExerciseModel> exercises = jsonResponse.map((e) => ExerciseModel.fromJson(e)).toList();

    setState(() {
      allExercises = exercises;
      filteredExercises = exercises;
    });
  }

  void _search(String query) {
    final results = allExercises.where((exercise) =>
      exercise.name.toLowerCase().contains(query.toLowerCase()) ||
      exercise.muscleGroup.toLowerCase().contains(query.toLowerCase())
    ).toList();

    setState(() {
      filteredExercises = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.black,
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
                    child: IconButton(
                      icon: Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredExercises.isEmpty
                  ? Center(child: Text("No exercises found", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: filteredExercises.length,
                      itemBuilder: (context, index) {
                        final ex = filteredExercises[index];
                        final color = _getColorForMuscleGroup(ex.muscleGroup);
                        return ExerciseCard(
                          exercise: ex,  // Pass the full exercise model
                          color: color,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForMuscleGroup(String group) {
    switch (group.toLowerCase()) {
      case 'chest':
        return Colors.pink;
      case 'back':
        return Colors.green;
      case 'arms':
        return Colors.purple;
      case 'shoulders':
        return Colors.orange;
      case 'legs':
        return Colors.blue;
      case 'core':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}