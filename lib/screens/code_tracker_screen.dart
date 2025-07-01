import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';

class CodeTrackerScreen extends StatelessWidget {
  const CodeTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habits = habitProvider.habits;

    return Scaffold(
      appBar: AppBar(title: const Text('Code Tracker')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          final completed = (jsonDecode(habit['completion_log'] as String) as List).length;
          return ListTile(
            title: Text(habit['title'] as String),
            subtitle: Text('Completed: $completed times'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.vibrate();
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}