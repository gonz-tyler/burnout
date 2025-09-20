// lib/screens/dashboard_screen.dart

import 'package:burnout/models/models.dart';
import 'package:burnout/services/muscle_analysis_service.dart';
import 'package:burnout/viewmodels/workout_view_model.dart';
import 'package:burnout/widgets/muscle_diagram_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'Week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutViewModel = context.watch<WorkoutViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profileTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Stats'),
            Tab(icon: Icon(Icons.accessibility_new), text: 'Muscles'),
          ],
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(context, workoutViewModel),
          _buildMuscleDiagramTab(context, workoutViewModel),
        ],
      ),
    );
  }

  Widget _buildStatsTab(BuildContext context, WorkoutViewModel viewModel) {
    final workoutViewModel = context.watch<WorkoutViewModel>();
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
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
    );
  }

  Widget _buildMuscleDiagramTab(
    BuildContext context,
    WorkoutViewModel viewModel,
  ) {
    // Note: You will need to ensure viewModel.exercises correctly loads your JSON data.
    final allWorkouts = viewModel.getAllWorkouts();
    final allExercises = viewModel.exercises;

    Map<String, double> muscleIntensity;
    switch (selectedPeriod) {
      case 'Week':
        muscleIntensity = MuscleAnalysisService.getWeeklyMuscleIntensity(
          allWorkouts,
          allExercises,
        );
        break;
      case 'Month':
        muscleIntensity = MuscleAnalysisService.getMonthlyMuscleIntensity(
          allWorkouts,
          allExercises,
        );
        break;
      case 'All Time':
        muscleIntensity = MuscleAnalysisService.getAllTimeMuscleIntensity(
          allWorkouts,
          allExercises,
        );
        break;
      default:
        muscleIntensity = MuscleAnalysisService.getWeeklyMuscleIntensity(
          allWorkouts,
          allExercises,
        );
    }

    final warnings = MuscleAnalysisService.getMuscleImbalanceWarnings(
      muscleIntensity,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Muscle Focus - $selectedPeriod',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showMuscleInfoDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Colors indicate workout volume for each muscle group.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
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
            child: MuscleDiagramWidget(muscleIntensity: muscleIntensity),
          ),
          const SizedBox(height: 24),
          _buildIntensityLegend(context),
          const SizedBox(height: 24),
          _buildMuscleBreakdown(context, muscleIntensity),
          const SizedBox(height: 24),
          if (warnings.isNotEmpty) _buildWarnings(context, warnings),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children:
            ['Week', 'Month', 'All Time'].map((period) {
              final isSelected = selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedPeriod = period),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: Center(
                      child: Text(
                        period,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildIntensityLegend(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intensity Scale',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.primary,
              ],
            ),
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Low Volume'), Text('High Volume')],
        ),
      ],
    );
  }

  Widget _buildMuscleBreakdown(
    BuildContext context,
    Map<String, double> intensity,
  ) {
    if (intensity.isEmpty) {
      return const Center(child: Text("No workout data for this period."));
    }
    // Sort muscles by intensity
    final sortedEntries =
        intensity.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Muscle Breakdown',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...sortedEntries.map((entry) {
          if (entry.value < 0.01)
            return const SizedBox.shrink(); // Hide muscles with negligible intensity
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(entry.key.replaceAll('_', ' '))),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: entry.value,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.lerp(
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        Theme.of(context).colorScheme.primary,
                        entry.value,
                      )!,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWarnings(BuildContext context, List<String> warnings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Balance Insights',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...warnings.map(
          (warning) => Card(
            color: Colors.amber.shade100,
            child: ListTile(
              leading: Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber.shade800,
              ),
              title: Text(warning),
            ),
          ),
        ),
      ],
    );
  }

  void _showMuscleInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About Muscle Analysis'),
            content: const Text(
              'This diagram visualizes your total workout volume for each major muscle group.\n\n- The color intensity is relative to the most-worked muscle group in the selected time period (Week, Month, or All Time), which is shown at 100% intensity.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
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
