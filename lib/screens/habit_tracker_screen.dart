import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/widgets/habit_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HabitTrackerScreen extends StatelessWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker').animate().fadeIn().slideY(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary).animate().fadeIn(),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<bool>(
          stream: habitProvider.loading,
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return const Center(child: CircularProgressIndicator()).animate().fadeIn();
            }
            if (habitProvider.habits.isEmpty) {
              return const Center(child: Text('No habits yet. Add a new one!', style: TextStyle(fontSize: 18)))
                  .animate().fadeIn().scale();
            }
            return RefreshIndicator(
              onRefresh: () => habitProvider.loadHabits(),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 8.0),
                itemCount: habitProvider.habits.length,
                itemBuilder: (context, index) => AnimatedBuilder(
                  animation: habitProvider,
                  builder: (context, child) => HabitCard(index: index).animate().fadeIn().slideY(delay: Duration(milliseconds: index * 100)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}