import 'package:flutter/material.dart';
import 'package:burnout/models/exercise_model.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseDetailScreen({Key? key, required this.exercise}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          exercise.name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with muscle group
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getColorForMuscleGroup(exercise.muscleGroup),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      exercise.muscleGroup.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Equipment section
            if (exercise.equipment != null && exercise.equipment!.isNotEmpty)
              _buildInfoSection(
                'Equipment',
                exercise.equipment!,
                Icons.fitness_center,
              ),
            
            SizedBox(height: 20),
            
            // Instructions section
            if (exercise.instructions != null && exercise.instructions!.isNotEmpty)
              _buildInfoSection(
                'Instructions',
                exercise.instructions is List<String>
                    ? (exercise.instructions as List<String>).join('\n\n')
                    : exercise.instructions.toString(),
                Icons.list_alt,
              ),
            
            SizedBox(height: 20),
            
            // Targeted muscles section
            if (exercise.targetedMuscles != null && exercise.targetedMuscles!.isNotEmpty)
              _buildInfoSection(
                'Targeted Muscles',
                exercise.targetedMuscles!.entries
                  .map((entry) => '${entry.key} (${entry.value * 100}%)')
                  .join('\n'),
                Icons.accessibility_new,
              ),
            
            SizedBox(height: 40),
            
            
          
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
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