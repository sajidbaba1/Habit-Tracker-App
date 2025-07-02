import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DailyMotivationScreenContent extends StatelessWidget {
  const DailyMotivationScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final quotes = [
      'Small steps every day lead to big results.',
      'Consistency is the key to success.',
      'Your habits shape your future.',
      'Keep going, you’re doing great!',
    ];
    final quote = quotes[DateTime.now().millisecondsSinceEpoch % quotes.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Motivation').animate().fadeIn().slideY(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary).animate().fadeIn(),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  quote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ).animate().fadeIn().slideY(),
                const SizedBox(height: 16),
                Text(
                  'Inspired by Sir Sajid Alimahamad Shaikh and Nasywa’s disciplined habits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ).animate().fadeIn().slideY(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}