import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

class AnalyticsScreenContent extends StatefulWidget {
  const AnalyticsScreenContent({super.key});

  @override
  State<AnalyticsScreenContent> createState() => _AnalyticsScreenContentState();
}

class _AnalyticsScreenContentState extends State<AnalyticsScreenContent> {
  String _selectedCategory = 'All';
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, String> _dateLabels = {};

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habits = habitProvider.habits;
    final categories = ['All', 'Health', 'Productivity', 'Leisure', 'Learning'];

    final filteredHabits = _selectedCategory == 'All'
        ? habits
        : habits.where((h) => (h['category'] as String? ?? 'Other') == _selectedCategory).toList();

    final pieData = filteredHabits.map((h) {
      final completed = (jsonDecode(h['completion_log'] as String? ?? '[]') as List).length;
      final totalDays = 30; // 30-day window
      final percentage = (completed / totalDays) * 100;
      return PieChartSectionData(
        value: percentage,
        title: '${h['title']}\n${percentage.toStringAsFixed(1)}%',
        color: Color(h['color'] as int? ?? Colors.blue.value),
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
      );
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            // Category Filter
            DropdownButton<String>(
              value: _selectedCategory,
              items: categories
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            // Pie Chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: pieData,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Calendar View
            Text('Habit Calendar', style: Theme.of(context).textTheme.headlineSmall),
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showLabelDialog(selectedDay);
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final completedHabits = habits.where((h) {
                    final log = (jsonDecode(h['completion_log'] as String? ?? '[]') as List)
                        .map((d) => DateTime.parse(d as String))
                        .toList();
                    return log.any((d) => isSameDay(d, date));
                  }).toList();
                  final isBookmarked = _dateLabels.containsKey(date);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (completedHabits.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          width: 6,
                          height: 6,
                        ),
                      if (isBookmarked)
                        Container(
                          margin: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.yellow,
                          ),
                          width: 6,
                          height: 6,
                        ),
                    ],
                  );
                },
              ),
            ),
            if (_selectedDay != null && _dateLabels[_selectedDay] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Label for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}: ${_dateLabels[_selectedDay]!}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            const SizedBox(height: 16),
            // Habit Completion Notes
            Text('Completion Notes', style: Theme.of(context).textTheme.headlineSmall),
            ...filteredHabits.map((h) {
              final log = (jsonDecode(h['completion_log'] as String? ?? '[]') as List)
                  .map((d) => DateTime.parse(d as String))
                  .toList();
              final completedDays = log.length;
              final successRate = (completedDays / 30) * 100;
              final notes = h['notes'] as String? ?? '';
              return Card(
                child: ListTile(
                  title: Text(h['title'] as String? ?? 'Untitled'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category: ${h['category'] ?? 'Other'}\n'
                            'Success Rate: ${successRate.toStringAsFixed(1)}%\n'
                            'Completed: $completedDays/30 days',
                      ),
                      if (notes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Notes: $notes',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                          ),
                        ),
                    ],
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Color(h['color'] as int? ?? Colors.blue.value),
                    child: Icon(
                      IconData(h['icon'] as int? ?? Icons.favorite.codePoint, fontFamily: 'MaterialIcons'),
                      color: Colors.white,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit_note, color: Theme.of(context).colorScheme.primary),
                    onPressed: () => _showNotesDialog(context, habitProvider, h['id'] as int, notes),
                  ),
                ),
              ).animate().fadeIn().slideY();
            }),
            const SizedBox(height: 16),
            // Habit Challenges
            Text('Habit Challenges', style: Theme.of(context).textTheme.headlineSmall),
            Card(
              child: ListTile(
                title: const Text('30-Day Challenge'),
                subtitle: const Text('Complete any habit daily for 30 days to earn a badge!'),
                trailing: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.vibrate();
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 60, color: Colors.yellow),
                              const Text('Challenge Accepted!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              const Text('Start your 30-day streak today!'),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ),
                      ).animate().scale().fadeIn(),
                    );
                  },
                  child: const Text('Join'),
                ),
              ),
            ),
            // Milestone Celebration
            ...filteredHabits.where((h) => (h['streak'] as int? ?? 0) >= 30).map((h) {
              return Card(
                child: ListTile(
                  title: Text('Milestone: ${h['title']}'),
                  subtitle: const Text('Congratulations on reaching a 30-day streak!'),
                  leading: const Icon(Icons.emoji_events, color: Colors.yellow),
                ).animate().shake().fadeIn(),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showLabelDialog(DateTime date) {
    final controller = TextEditingController(text: _dateLabels[date]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Label for ${date.day}/${date.month}/${date.year}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter label (e.g., Milestone, Event)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (controller.text.isEmpty) {
                  _dateLabels.remove(date);
                } else {
                  _dateLabels[date] = controller.text;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(BuildContext context, HabitProvider habitProvider, int habitId, String currentNotes) {
    final controller = TextEditingController(text: currentNotes);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Completion Notes'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter notes for this habit'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              habitProvider.updateHabitNotes(habitId, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}