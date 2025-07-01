import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/add_habit_screen.dart';
import 'package:habit_tracker_app/services/navigation_service.dart';
import 'package:get_it/get_it.dart';
import 'package:animations/animations.dart';

class HabitCard extends StatefulWidget {
  final int index;

  const HabitCard({super.key, required this.index});

  @override
  _HabitCardState createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habit = habitProvider.habits[widget.index];

    List<DateTime> completionLog;
    try {
      completionLog = (jsonDecode(habit['completion_log'] as String? ?? '[]') as List)
          .map((d) => DateTime.parse(d as String))
          .toList();
    } catch (e) {
      completionLog = [];
    }
    final today = DateTime.now();
    final isTodayCompleted = completionLog.any((d) =>
    d.year == today.year && d.month == today.month && d.day == today.day);

    void _showCongratulationCard() {
      if (habit['streak'] == 7) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Congratulations!', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text("You've reached a 7-day streak! Keep it up!"),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }

    void _confirmDelete() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Habit?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to delete this habit? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                habitProvider.deleteHabit(habit['id'] as int);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Color(habit['color'] as int),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        IconData(habit['icon'] as int, fontFamily: 'MaterialIcons'),
                        size: 24,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        habit['title'] as String,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, size: 24, color: Theme.of(context).colorScheme.onSurface),
                        onPressed: () {
                          GetIt.I<NavigationService>().navigateTo(AddHabitScreen(habitId: habit['id']));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 24, color: Theme.of(context).colorScheme.error),
                        onPressed: _confirmDelete,
                      ),
                    ],
                  ),
                ],
              ),
              if (habit['checklistEnabled'] == true)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text(
                    'Checklist enabled',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ),
              const SizedBox(height: 8.0),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(7, (dayIndex) {
                  final date = DateTime.now().subtract(Duration(days: 6 - dayIndex));
                  final isCompleted = completionLog.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
                  return GestureDetector(
                    onTap: () {
                      habitProvider.toggleCompletion(widget.index, date);
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: isCompleted
                            ? [
                          BoxShadow(
                            color: Colors.green[900]!.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isCompleted ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Streak: ${habit['streak']} days',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  IconButton(
                    icon: Icon(Icons.check, size: 24, color: isTodayCompleted ? Colors.green : Theme.of(context).colorScheme.onSurface),
                    onPressed: () {
                      habitProvider.toggleCompletion(widget.index, today);
                      setState(() {});
                      _showCongratulationCard();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}