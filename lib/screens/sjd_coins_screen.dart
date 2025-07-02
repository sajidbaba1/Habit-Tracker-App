import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SJDCoinsScreen extends StatelessWidget {
  const SJDCoinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final totalCoins = habitProvider.habits.fold(0, (sum, habit) => sum + (habit['streak'] as int? ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('SJD Coins').animate().fadeIn().slideY(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary).animate().fadeIn(),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on, size: 100, color: Colors.yellow).animate().fadeIn().scale(),
              const SizedBox(height: 16),
              Text(
                'Your SJD Coins: $totalCoins',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ).animate().fadeIn().slideY(),
              const SizedBox(height: 16),
              Text(
                'Earn more coins by maintaining your habit streaks!',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Placeholder for subscription logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subscription feature coming soon!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Unlock Premium Features'),
              ).animate().fadeIn().scale(),
            ],
          ),
        ),
      ),
    );
  }
}