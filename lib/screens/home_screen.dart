import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker_app/screens/add_habit_screen.dart';
import 'package:habit_tracker_app/screens/settings_screen.dart';
import 'package:habit_tracker_app/screens/daily_motivation_screen.dart';
import 'package:habit_tracker_app/screens/daily_quotes_screen.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/widgets/habit_card.dart';
import 'package:habit_tracker_app/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final navigationService = GetIt.I<NavigationService>();
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
            onPressed: () => navigationService.navigateTo(const SettingsScreen()),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 10,
        shadowColor: Colors.blue.withValues(alpha: 0.3),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: Text('Menu', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb),
              title: const Text('Daily Motivation'),
              onTap: () => navigationService.navigateTo(const DailyMotivationScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.format_quote),
              title: const Text('Daily Quotes'),
              onTap: () => navigationService.navigateTo(const DailyQuotesScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => navigationService.navigateTo(const SettingsScreen()),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                DateFormat('d MMMM yyyy').format(DateTime.now()),
                style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
            ),
            Expanded(
              child: StreamBuilder<bool>(
                stream: habitProvider.loading,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == true) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (habitProvider.habits.isEmpty) {
                    return Center(child: Text('No habits yet. Add a new one!', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))));
                  }
                  return RefreshIndicator(
                    onRefresh: () => habitProvider.loadHabits(),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 8.0),
                      itemCount: habitProvider.habits.length,
                      itemBuilder: (context, index) => AnimatedBuilder(
                        animation: habitProvider,
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: 'add_habit_button',
            onPressed: () => navigationService.navigateTo(const AddHabitScreen()),
            label: const Text('Add Habit'),
            icon: const Icon(Icons.add, size: 30),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            elevation: 10,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            heroTag: 'motivation_button',
            onPressed: () => navigationService.navigateTo(const DailyMotivationScreen()),
            label: const Text('Motivation'),
            icon: const Icon(Icons.lightbulb, size: 30),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            elevation: 10,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
          ),
        ],
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