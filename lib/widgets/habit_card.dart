import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/add_habit_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';

class HabitCard extends StatelessWidget {
  final int index;

  const HabitCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habit = habitProvider.habits[index];
    final completionLog = (jsonDecode(habit['completion_log'] as String? ?? '[]') as List)
        .map((d) => DateTime.parse(d as String))
        .toList();
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 34)); // 35 days total
    final dates = List.generate(35, (i) => startDate.add(Duration(days: i)));

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(habit['color'] as int? ?? Colors.blue.value),
                      child: Icon(
                        IconData(habit['icon'] as int? ?? Icons.favorite.codePoint, fontFamily: 'MaterialIcons'),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      habit['title'] as String? ?? 'Untitled',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Streak: ${habit['streak'] ?? 0}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddHabitScreen(
                              habit: habit,
                              habitId: habit['id'] as int,
                            ),
                          ),
                        );
                      },
                    ).animate().fadeIn(),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      color: Theme.of(context).colorScheme.error,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Habit').animate().fadeIn(),
                            content: Text('Are you sure you want to delete "${habit['title']}"?').animate().fadeIn(),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel').animate().fadeIn(),
                              ),
                              TextButton(
                                onPressed: () {
                                  habitProvider.deleteHabit(habit['id'] as int);
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)).animate().fadeIn(),
                              ),
                            ],
                          ),
                        );
                      },
                    ).animate().fadeIn(),
                  ],
                ),
              ],
            ).animate().fadeIn().slideY(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start: ${DateFormat('d MMM').format(startDate)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                ),
                Text(
                  'End: ${DateFormat('d MMM').format(today)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                ),
              ],
            ).animate().fadeIn().slideY(),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: dates.length,
              itemBuilder: (context, i) {
                final date = dates[i];
                final isCompleted = completionLog.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
                return GestureDetector(
                  onTap: () async {
                    final newStreak = await habitProvider.toggleCompletion(index, date);
                    if (newStreak > (habit['streak'] ?? 0)) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Great Job, ${habit['title']}'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Your streak is now $newStreak days!'),
                              const SizedBox(height: 8),
                              Text(
                                _getRandomQuote(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ).animate().fadeIn().scale(delay: Duration(milliseconds: i * 50));
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getRandomQuote() {
    final quotes = [
      'Small steps every day lead to big results.',
      'Consistency is the key to success.',
      'Your habits shape your future.',
      'Keep going, you’re doing great!',
    ];
    return quotes[DateTime.now().millisecondsSinceEpoch % quotes.length];
  }
}