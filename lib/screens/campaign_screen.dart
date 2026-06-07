// lib/screens/campaign_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/workout_view_model.dart';
import '../services/labors_service.dart';
import '../services/quests_service.dart'; // 🟢 Import the new service

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 Use DefaultTabController for the 2 tabs
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text(
            "CAMPAIGN MODE",
            style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "THE 12 LABORS"), // Long term
              Tab(text: "WEEKLY TRIALS"), // Short term
            ],
          ),
        ),
        body: const TabBarView(children: [_LaborsView(), _QuestsView()]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// VIEW 1: THE 12 LABORS (Your existing grid logic, moved here)
// ---------------------------------------------------------------------------
class _LaborsView extends StatelessWidget {
  const _LaborsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkoutViewModel>();
    final labors = LaborsService.checkLabors(vm);
    final completedCount = labors.where((l) => l.isCompleted).length;

    return Column(
      children: [
        // Status Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "$completedCount / ${labors.length} LEGENDS FORGED",
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: completedCount / labors.length,
                color: Colors.amber.shade700,
                backgroundColor: Colors.grey.shade900,
                minHeight: 4,
              ),
            ],
          ),
        ),
        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: labors.length,
            itemBuilder:
                (context, index) => _LaborMedallion(labor: labors[index]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// VIEW 2: WEEKLY TRIALS (The new short-term goals)
// ---------------------------------------------------------------------------
class _QuestsView extends StatelessWidget {
  const _QuestsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkoutViewModel>();
    final quests = QuestsService.checkWeeklyQuests(vm);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quests.length,
      itemBuilder: (context, index) {
        return _QuestCard(quest: quests[index]);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGETS
// ---------------------------------------------------------------------------

class _QuestCard extends StatelessWidget {
  final Quest quest;

  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: quest.isCompleted ? quest.themeColor : Colors.white10,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Reward Icon
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color:
                  quest.isCompleted
                      ? quest.themeColor.withOpacity(0.2)
                      : Colors.black26,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    quest.isCompleted ? quest.themeColor : Colors.transparent,
              ),
            ),
            child: Center(
              child: Image.asset(
                quest.rewardAsset,
                width: 32,
                color:
                    quest.isCompleted
                        ? null
                        : Colors.white24, // Silhouette if not done
                errorBuilder:
                    (c, o, s) => Icon(
                      Icons.emoji_events,
                      color: quest.isCompleted ? quest.themeColor : Colors.grey,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 2. Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title.toUpperCase(),
                  style: TextStyle(
                    color: quest.isCompleted ? quest.themeColor : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quest.description,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 8),

                // Progress Bar
                if (!quest.isCompleted)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: quest.progress,
                          backgroundColor: Colors.black,
                          color: quest.themeColor,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quest.requirement, // "Complete 3 Workouts..."
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                else
                  // Completion Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: quest.themeColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "COMPLETED",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LaborMedallion extends StatelessWidget {
  final Labor labor;

  const _LaborMedallion({required this.labor});

  @override
  Widget build(BuildContext context) {
    final color =
        labor.isCompleted ? Colors.amber.shade700 : Colors.grey.shade800;
    final textColor = labor.isCompleted ? Colors.black : Colors.white54;

    return GestureDetector(
      onTap: () {
        // Optional: Show detail dialog on tap
        _showDetailDialog(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color:
              labor.isCompleted
                  ? Colors.amber.shade100
                  : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          // Add a subtle gradient "Stone" texture effect
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                labor.isCompleted
                    ? [const Color(0xFFFFD700), const Color(0xFFDAA520)] // Gold
                    : [
                      const Color(0xFF2C2C2C),
                      const Color(0xFF1A1A1A),
                    ], // Stone
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Medallion
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: labor.isCompleted ? Colors.black26 : Colors.white10,
                  width: 2,
                ),
                color: Colors.black12,
              ),
              child: Image.asset(
                labor.medalAsset,
                width: 32,
                height: 32,
                color: labor.isCompleted ? Colors.black87 : Colors.white24,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                labor.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: labor.isCompleted ? Colors.black87 : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Requirement (Small text)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                labor.requirement,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: labor.isCompleted ? Colors.black54 : Colors.white30,
                  fontSize: 10,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Progress Bar (if incomplete)
            if (!labor.isCompleted)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: labor.progress,
                    minHeight: 4,
                    backgroundColor: Colors.black26,
                    color: Colors.white24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _stringToIconData(String iconName) {
    // Map string names to IconData
    // Add more mappings as needed based on your Labor icon names
    final iconMap = {
      'lion': Icons.local_fire_department,
      'hydra': Icons.water_drop,
      'boar': Icons.pets,
      'deer': Icons.nature,
      'birds': Icons.flight,
      'bull': Icons.agriculture,
      'amazon': Icons.shield,
      'girdle': Icons.checkroom,
      'apples': Icons.apple,
      'cerberus': Icons.security,
      'horses': Icons.directions_run,
      'cattle': Icons.grass,
    };
    return iconMap[iconName.toLowerCase()] ?? Icons.star;
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              labor.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  labor.description,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                Text(
                  "REQUIREMENT:",
                  style: TextStyle(
                    color: Colors.amber.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  labor.requirement,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CLOSE"),
              ),
            ],
          ),
    );
  }
}
