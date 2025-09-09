import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/workout_screen.dart';
import 'screens/exercise_screen.dart';
import 'screens/body_metrics_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: SafeArea(child: WorkoutApp()),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WorkoutApp extends StatefulWidget {
  @override
  _WorkoutAppState createState() => _WorkoutAppState();
}

class _WorkoutAppState extends State<WorkoutApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ExercisesPage(),
    BodyMetricsPage(),
    WorkoutsPage(),
    InsightsPage(),
    ProfilePage(),
    // SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(top: BorderSide(color: Colors.grey[800]!, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey[600],
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_rounded),
              label: 'Exercises',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monitor_weight),
              label: 'Metrics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded, size: 48),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights),
              label: 'Insights',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
