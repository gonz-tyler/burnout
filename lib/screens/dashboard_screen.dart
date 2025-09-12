// lib/screens/dashboard_screen.dart

import 'package:burnout/viewmodels/workout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workoutViewModel = context.watch<WorkoutViewModel>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.dashboardTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color:
                        workoutViewModel.didWorkoutToday
                            ? Colors.orange
                            : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${workoutViewModel.currentStreak}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          workoutViewModel.didWorkoutToday
                              ? Colors.orange
                              : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Total Workouts',
                    value: '${workoutViewModel.totalWorkouts ?? 0}',
                    icon: Icons.fitness_center,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Best Streak',
                    value: '${workoutViewModel.bestStreak ?? 0}',
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'This Week',
                    value: '${workoutViewModel.weeklyWorkouts ?? 0}',
                    icon: Icons.calendar_today_rounded,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'This Month',
                    value: '${workoutViewModel.monthlyWorkouts ?? 0}',
                    icon: Icons.calendar_month,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Weekly Progress Chart
            Text(
              'Weekly Progress',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildWeeklyChart(context, workoutViewModel),
            ),

            const SizedBox(height: 24),

            // Monthly Overview
            Text(
              'Monthly Overview',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMonthlyChart(context, workoutViewModel),
            ),

            const SizedBox(height: 24),

            // Progress Ring
            Text(
              'Weekly Goal Progress',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildProgressRing(context, workoutViewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, WorkoutViewModel viewModel) {
    // Sample data - replace with actual data from your view model
    final weeklyData = [
      FlSpot(0, viewModel.getWorkoutsForDay(0).toDouble()), // Monday
      FlSpot(1, viewModel.getWorkoutsForDay(1).toDouble()), // Tuesday
      FlSpot(2, viewModel.getWorkoutsForDay(2).toDouble()), // Wednesday
      FlSpot(3, viewModel.getWorkoutsForDay(3).toDouble()), // Thursday
      FlSpot(4, viewModel.getWorkoutsForDay(4).toDouble()), // Friday
      FlSpot(5, viewModel.getWorkoutsForDay(5).toDouble()), // Saturday
      FlSpot(6, viewModel.getWorkoutsForDay(6).toDouble()), // Sunday
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(
                    days[value.toInt()],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: weeklyData,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: 3,
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context, WorkoutViewModel viewModel) {
    // Sample data for last 6 months - replace with actual data
    final monthlyData = [
      BarChartGroupData(
        x: 0,
        barRods: [BarChartRodData(toY: 12, color: Colors.green)],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [BarChartRodData(toY: 8, color: Colors.green)],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [BarChartRodData(toY: 15, color: Colors.green)],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [BarChartRodData(toY: 10, color: Colors.green)],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [BarChartRodData(toY: 18, color: Colors.green)],
      ),
      BarChartGroupData(
        x: 5,
        barRods: [
          BarChartRodData(
            toY: viewModel.monthlyWorkouts?.toDouble() ?? 0,
            color: Colors.green,
          ),
        ],
      ),
    ];

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: monthlyData,
        maxY: 20,
      ),
    );
  }

  Widget _buildProgressRing(BuildContext context, WorkoutViewModel viewModel) {
    final weeklyGoal = 5; // You can make this configurable
    final currentWeekWorkouts = viewModel.weeklyWorkouts ?? 0;
    final double progress = (currentWeekWorkouts / weeklyGoal * 100).clamp(
      0.0,
      100.0,
    );

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: progress,
                    color: Colors.orange,
                    radius: 20,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 100 - progress,
                    color: Colors.grey[300],
                    radius: 20,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${progress.toInt()}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                'Weekly Goal',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                '$currentWeekWorkouts of $weeklyGoal workouts',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
