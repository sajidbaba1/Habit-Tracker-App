import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/widgets/habit_card.dart';

class HabitTrackerScreenContent extends StatelessWidget {
  const HabitTrackerScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Track Your Habits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<bool>(
              stream: habitProvider.loading,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (habitProvider.habits.isEmpty) {
                  return const Center(child: Text('No habits to track. Add a new one!', style: TextStyle(fontSize: 18)));
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 8.0),
                  itemCount: habitProvider.habits.length,
                  itemBuilder: (context, index) => AnimatedBuilder(
                    animation: habitProvider,
                    builder: (context, child) => HabitCard(index: index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}