import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/add_habit_screen.dart';
import 'package:habit_tracker_app/screens/settings_screen.dart';
import 'package:habit_tracker_app/widgets/habit_card.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good Morning' : now.hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final formattedDate = DateFormat('MMMM dd, yyyy').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 10,
        shadowColor: Colors.blue.withOpacity(0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                Text(formattedDate, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<bool>(
              stream: habitProvider.loading,
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.data ?? false) {
                  return const Center(child: CircularProgressIndicator());
                }
                final habits = habitProvider.habits;
                if (habits.isEmpty) {
                  return const Center(child: Text('No habits yet! Add one to get started.', style: TextStyle(color: Colors.white70)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: habits.length,
                  itemBuilder: (context, index) => HabitCard(index: index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newHabit = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHabitScreen()));
          if (newHabit != null && !habitProvider.habits.any((h) => h['title'] == newHabit['title'])) {
            await habitProvider.addHabit(newHabit);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.black,
      ),
    );
  }
}