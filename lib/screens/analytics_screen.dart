import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';

class AnalyticsScreenContent extends StatefulWidget {
  const AnalyticsScreenContent({super.key});

  @override
  _AnalyticsScreenContentState createState() => _AnalyticsScreenContentState();
}

class _AnalyticsScreenContentState extends State<AnalyticsScreenContent> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};
  String _notes = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  void _loadEvents() {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final events = <DateTime, List<dynamic>>{};
    for (var habit in habitProvider.habits) {
      final completionLog = (jsonDecode(habit['completion_log'] as String? ?? '[]') as List)
          .map((d) => DateTime.parse(d as String))
          .toList();
      for (var date in completionLog) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        events[normalizedDate] = events[normalizedDate] ?? [];
        events[normalizedDate]!.add(habit);
      }
    }
    setState(() {
      _events = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Habit Analytics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ).animate().fadeIn().slideY(),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _notes = _getNotesForDay(selectedDay);
                  });
                },
                calendarFormat: CalendarFormat.month,
                eventLoader: (day) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  return _events[normalizedDay] ?? [];
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ).animate().fadeIn().scale(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completion Stats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ).animate().fadeIn().slideY(),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: _buildBarGroups(habitProvider.habits),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < habitProvider.habits.length) {
                                    return Text(
                                      habitProvider.habits[index]['title'].substring(0, 3),
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: 12,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 16),
                    Text(
                      'Notes for ${_selectedDay != null ? DateFormat('d MMM yyyy').format(_selectedDay!) : "Selected Date"}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ).animate().fadeIn().slideY(),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Add completion notes...',
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        _notes = value;
                      },
                      controller: TextEditingController(text: _notes),
                    ).animate().fadeIn().slideY(),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedDay != null && _notes.isNotEmpty) {
                          final habitsOnDay = _events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [];
                          for (var habit in habitsOnDay) {
                            habitProvider.updateHabitNotes(habit['id'], _notes);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notes saved')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: const Text('Save Notes'),
                    ).animate().fadeIn().scale(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<Map<String, dynamic>> habits) {
    return habits.asMap().entries.map((entry) {
      final index = entry.key;
      final habit = entry.value;
      final completionLog = (jsonDecode(habit['completion_log'] as String? ?? '[]') as List).length;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: completionLog.toDouble(),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      );
    }).toList();
  }

  String _getNotesForDay(DateTime day) {
    final habitsOnDay = _events[DateTime(day.year, day.month, day.day)] ?? [];
    if (habitsOnDay.isNotEmpty) {
      return habitsOnDay.first['notes'] ?? '';
    }
    return '';
  }
}