import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker_app/screens/add_habit_screen.dart';
import 'package:habit_tracker_app/screens/settings_screen.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/widgets/habit_card.dart';
import 'package:animations/animations.dart'; // For page transitions

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              _getGreeting(),
              textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              speed: const Duration(milliseconds: 100),
            ),
          ],
          totalRepeatCount: 1,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 30),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
        backgroundColor: const Color(0xFF000080), // Navy blue
        elevation: 10,
        shadowColor: Colors.blue.withOpacity(0.3),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                DateFormat('d MMMM yyyy').format(DateTime.now()),
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ),
            Expanded(
              child: StreamBuilder<bool>(
                stream: habitProvider.loading,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == true) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (habitProvider.habits.isEmpty) {
                    return const Center(child: Text('No habits yet. Add a new one!', style: TextStyle(fontSize: 18, color: Colors.white70)));
                  }
                  return RefreshIndicator(
                    onRefresh: () => habitProvider.loadHabits(),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 8.0),
                      itemCount: habitProvider.habits.length,
                      itemBuilder: (context, index) => AnimatedBuilder(
                        animation: Listenable.merge([habitProvider]), // Correct animation reference
                        builder: (context, child) => HabitCard(index: index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHabitScreen()));
        },
        child: const Icon(Icons.add, size: 30),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 10,
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}