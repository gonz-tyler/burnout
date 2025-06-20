import 'package:burnout/models/workout_model.dart';
import 'package:flutter/material.dart';

class EditWorkoutScreen extends StatefulWidget {
  final String? workoutName;
  final String? workoutDescription;
  
  final dynamic workoutModel;

  const EditWorkoutScreen({
    Key? key,
    this.workoutName,
    this.workoutDescription,
  this.workoutModel, required WorkoutModel workout,
  }) : super(key: key);

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workoutName ?? '');
    _descriptionController = TextEditingController(text: widget.workoutDescription ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveWorkout() {
    if (_formKey.currentState!.validate()) {
      // Save logic here
      Navigator.of(context).pop({
        'name': _nameController.text,
        'description': _descriptionController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutName == null ? 'Create Workout' : 'Edit Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWorkout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a workout name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveWorkout,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}