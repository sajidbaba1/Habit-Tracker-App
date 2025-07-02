import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DailyQuotesScreen extends StatelessWidget {
  const DailyQuotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quotes = [
      'The best way to predict the future is to create it. - Peter Drucker',
      'Success is the sum of small efforts repeated day in and day out. - Robert Collier',
      'You are never too old to set another goal or to dream a new dream. - C.S. Lewis',
      'The secret of getting ahead is getting started. - Mark Twain',
    ];
    final quote = quotes[DateTime.now().millisecondsSinceEpoch % quotes.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quotes').animate().fadeIn().slideY(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}