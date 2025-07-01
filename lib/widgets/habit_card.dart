import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/add_habit_screen.dart';
import 'package:animations/animations.dart';

class HabitCard extends StatelessWidget {
  final int index;

  const HabitCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habit = habitProvider.habits[index];
    if (habit == null) return const SizedBox.shrink();
    final completionLog = (jsonDecode(habit['completion_log'] as String) as List)
        .map((d) => DateTime.parse(d as String)).toList();
    final today = DateTime.now();
    final isTodayCompleted = completionLog.any((d) => d.year == today.year && d.month == today.month && d.day == today.day);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..setEntry(3, 2, 0.001),
        transformAlignment: Alignment.center,
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
                      Icon(IconData(habit['icon'] as int), size: 24, color: Colors.white),
                      const SizedBox(width: 8.0),
                      Text(habit['title'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 24, color: Colors.white),
                        onPressed: () async {
                          final updatedHabit = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddHabitScreen(),
                              settings: RouteSettings(arguments: habit),
                            ),
                          );
                          if (updatedHabit != null) {
                            await habitProvider.editHabit(habit['id'] as int, updatedHabit);
                          }
                        },
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
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
                    onTap: () => habitProvider.toggleCompletion(index, context, date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: isCompleted
                            ? [
                          BoxShadow(color: Colors.green[900]!.withOpacity(0.3), spreadRadius: 1, blurRadius: 3),
                        ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: isCompleted ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
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
                  Text('Streak: ${habit['streak'] as int} days', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                  IconButton(
                    icon: Icon(Icons.check, size: 24, color: isTodayCompleted ? Colors.green : Colors.white),
                    onPressed: () => habitProvider.toggleCompletion(index, context, today),
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