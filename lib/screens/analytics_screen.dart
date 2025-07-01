import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habits = habitProvider.habits;

    final pieData = habits.map((h) {
      final completed = (jsonDecode(h['completion_log'] as String) as List).length;
      final totalDays = 7; // Assuming a 7-day window
      final percentage = (completed / totalDays) * 100;
      return PieChartSectionData(
        value: percentage,
        title: '${h['title']}\n${percentage.toStringAsFixed(1)}%',
        color: Colors.primaries[habits.indexOf(h) % Colors.primaries.length],
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: pieData,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.vibrate();
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}