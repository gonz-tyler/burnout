import 'package:flutter/material.dart';
import 'package:burnout/widgets/metric_card.dart';

class BodyMetricsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Body Metrics',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.settings, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Core',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child: ListView(
                          children: [
                            MetricCard(
                              icon: Icons.monitor_weight,
                              label: 'Weight',
                              value: '118.2 kg',
                              date: '26.09.2022',
                            ),
                            MetricCard(
                              icon: Icons.percent,
                              label: 'Bodyfat',
                              value: '30.7 %',
                              date: '28.09.2022',
                            ),
                            MetricCard(
                              icon: Icons.straighten,
                              label: 'Height',
                              value: '193 cm',
                              date: '28.09.2022',
                            ),
                            MetricCard(
                              icon: Icons.local_fire_department,
                              label: 'Calories',
                              value: '2458 kcal',
                              date: '28.09.2022',
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Measurements',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                            SizedBox(height: 12),
                            MetricCard(
                              icon: Icons.straighten,
                              label: 'Neck',
                              value: '38.1 cm',
                              date: '28.09.2022',
                            ),
                            MetricCard(
                              icon: Icons.accessibility,
                              label: 'Shoulders',
                              value: '118.8 cm',
                              date: '28.09.2022',
                            ),
                            MetricCard(
                              icon: Icons.favorite,
                              label: 'Chest',
                              value: '107.2 cm',
                              date: '28.09.2022',
                            ),
                            MetricCard(
                              icon: Icons.fitness_center,
                              label: 'Left Biceps',
                              value: '35.8 cm',
                              date: '28.09.2022',
                            ),
                            MetricCard(
                              icon: Icons.fitness_center,
                              label: 'Right Biceps',
                              value: '35.8 cm',
                              date: '28.09.2022',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}