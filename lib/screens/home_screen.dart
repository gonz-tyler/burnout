import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<String> workouts = ["Push Day", "Pull Day", "Leg Day"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Burnout'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(workouts[index], style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to workout screen
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new workout logic
        },
        child: Icon(Icons.add),
      ),
    );
  }
}