// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/workout_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'workout_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We can already connect this to the ViewModel to display the streak
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
            // User Stats Card
            // Showcase(
            //   key: _statsCardKey,
            //   description: l10n.statsCardTooltip,
            //   child:
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.yourProgress,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  l10n.keepProgressing,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            l10n.totalWorkouts,
                            // totalWorkouts.toString(),
                            workoutViewModel.workoutSessions.length.toString(),
                            Icons.list_alt,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            l10n.daysLeft,
                            // daysLeft.toString(),
                            "placeholder",
                            Icons.today,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            l10n.totalCompletions,
                            // totalCompletions.toString(),
                            "placeholder",
                            Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ),
            const SizedBox(height: 24),

            // Quick Actions Section
            // Showcase(
            //   key: _quickActionsKey,
            //   description: l10n.quickActionsTooltip,
            //   child:
            Text(
              l10n.quickActions,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            // ),
            const SizedBox(height: 12),

            _buildActionCard(
              context,
              'Workout History', // You can add this to your l10n file
              'View your completed sessions',
              Icons.history,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
              ),
            ),

            const SizedBox(height: 12),

            _buildActionCard(
              context,
              l10n.settings,
              l10n.customizePreferences,
              Icons.settings,
              Colors.blue,
              () => Navigator.pushNamed(context, '/settings'),
            ),

            const SizedBox(height: 24),

            // Support Section
            Text(
              l10n.supportCreator,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Showcase(
            //   key: _supportCardKey,
            //   description: l10n.supportTheCreatorTooltip,
            //   child:
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      l10n.enjoyingApp,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.supportMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showComingSoonDialog(
                                context,
                                l10n.appStoreRating,
                              );
                            },
                            icon: Icon(Icons.star),
                            label: Text(l10n.rateApp),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showComingSoonDialog(
                                context,
                                l10n.supportOptions,
                              );
                            },
                            icon: Icon(Icons.coffee),
                            label: Text(l10n.buyCoffee),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ),
            const SizedBox(height: 24),

            Row(
              mainAxisSize: MainAxisSize.max, // Row expands fully
              mainAxisAlignment:
                  MainAxisAlignment
                      .center, // Center children within the expanded space
              children: [
                Text(
                  l10n.madeWithLove,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  // textAlign: TextAlign.center, // No longer necessary if Row handles centering
                ),
                SizedBox(width: 4), // Add a small space between text and icon
                Icon(Icons.favorite, color: Colors.grey[600], size: 16),
              ],
            ),

            const SizedBox(height: 24),

            // App Info
            Card(
              elevation: 1,
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${const String.fromEnvironment('NAME', defaultValue: 'Burnout')} v${const String.fromEnvironment('VERSION', defaultValue: '1.0.0')}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            l10n.appDescription,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Coming Soon!'),
            content: Text('$feature will be available in a future update.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }
}
