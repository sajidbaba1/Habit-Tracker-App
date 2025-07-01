import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:habit_tracker_app/services/database_helper.dart';

class HabitProvider with ChangeNotifier {
  List<Map<String, dynamic>> _habits = [];
  final _loadingController = BehaviorSubject<bool>.seeded(false);
  bool _isDarkMode = false;

  List<Map<String, dynamic>> get habits => _habits;
  Stream<bool> get loading => _loadingController.stream;
  bool get isDarkMode => _isDarkMode;

  HabitProvider() {
    loadHabits();
    _loadTheme();
  }

  Future<void> loadHabits() async {
    _loadingController.add(true);
    final db = await DatabaseHelper.instance.database;
    final habitList = await db.query('habits');
    _habits = habitList.map((h) {
      final log = jsonDecode(h['completion_log'] as String? ?? '[]') as List;
      final streak = _calculateStreak(log.map((d) => DateTime.parse(d as String)).toList());
      return {...h, 'streak': streak};
    }).toList();
    _loadingController.add(false);
    notifyListeners();
  }

  Future<void> addHabit({
    required String title,
    required String category,
    required int icon,
    required int color,
    bool checklistEnabled = false,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('habits', {
      'title': title,
      'category': category,
      'icon': icon,
      'color': color,
      'completion_log': jsonEncode([]),
      'checklistEnabled': checklistEnabled ? 1 : 0,
      'notes': '',
    });
    await loadHabits();
  }

  Future<void> updateHabit(int id, {
    String? title,
    String? category,
    int? icon,
    int? color,
    bool? checklistEnabled,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final currentHabit = _habits.firstWhere((h) => h['id'] == id);
    await db.update(
      'habits',
      {
        'title': title ?? currentHabit['title'],
        'category': category ?? currentHabit['category'],
        'icon': icon ?? currentHabit['icon'],
        'color': color ?? currentHabit['color'],
        'completion_log': currentHabit['completion_log'],
        'checklistEnabled': checklistEnabled != null ? (checklistEnabled ? 1 : 0) : currentHabit['checklistEnabled'],
        'notes': currentHabit['notes'] ?? '',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadHabits();
  }

  Future<void> updateHabitNotes(int id, String notes) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'habits',
      {'notes': notes},
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadHabits();
  }

  Future<int> toggleCompletion(int index, DateTime date) async {
    final db = await DatabaseHelper.instance.database;
    final habit = _habits[index];
    List<DateTime> completionLog = (jsonDecode(habit['completion_log'] as String? ?? '[]') as List)
        .map((d) => DateTime.parse(d as String))
        .toList();
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (completionLog.any((d) => d.year == dateOnly.year && d.month == dateOnly.month && d.day == dateOnly.day)) {
      completionLog.removeWhere((d) => d.year == dateOnly.year && d.month == dateOnly.month && d.day == dateOnly.day);
    } else {
      completionLog.add(dateOnly);
    }
    await db.update(
      'habits',
      {'completion_log': jsonEncode(completionLog.map((d) => d.toIso8601String()).toList())},
      where: 'id = ?',
      whereArgs: [habit['id']],
    );
    await loadHabits();
    return _calculateStreak(completionLog);
  }

  Future<void> deleteHabit(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
    await loadHabits();
  }

  int _calculateStreak(List<DateTime> completionLog) {
    if (completionLog.isEmpty) return 0;
    completionLog.sort((a, b) => b.compareTo(a)); // Sort descending
    int streak = 0;
    DateTime current = DateTime.now();
    for (var date in completionLog) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final currentOnly = DateTime(current.year, current.month, current.day);
      if (dateOnly.isAtSameMomentAs(currentOnly) || dateOnly.isAtSameMomentAs(currentOnly.subtract(const Duration(days: 1)))) {
        streak++;
        current = date;
      } else if (dateOnly.isBefore(currentOnly.subtract(const Duration(days: 1)))) {
        break;
      }
    }
    return streak;
  }

  void toggleTheme(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    notifyListeners();
  }

  void _loadTheme() {
    _isDarkMode = false; // Default to light mode, can be persisted if needed
    notifyListeners();
  }

  @override
  void dispose() {
    _loadingController.close();
    super.dispose();
  }
}