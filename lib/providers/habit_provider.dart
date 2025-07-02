import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:habit_tracker_app/services/database_helper.dart';
import 'dart:convert';

class HabitProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _habits = [];
  final BehaviorSubject<bool> _loading = BehaviorSubject<bool>.seeded(false);
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> get habits => _habits;
  Stream<bool> get loading => _loading.stream;

  HabitProvider() {
    loadHabits();
  }

  Future<void> loadHabits() async {
    _loading.add(true);
    _habits = await _dbHelper.getHabits();
    _loading.add(false);
    notifyListeners();
  }

  Future<void> addHabit({
    required String title,
    required String category,
    required int icon,
    required int color,
    required bool checklistEnabled,
  }) async {
    _loading.add(true);
    await _dbHelper.insertHabit({
      'title': title,
      'category': category,
      'icon': icon,
      'color': color,
      'checklist_enabled': checklistEnabled ? 1 : 0,
      'streak': 0,
      'completion_log': jsonEncode([]),
      'notes': '',
    });
    await loadHabits();
  }

  Future<void> updateHabit(
      int id, {
        required String title,
        required String category,
        required int icon,
        required int color,
        required bool checklistEnabled,
      }) async {
    _loading.add(true);
    final habit = _habits.firstWhere((h) => h['id'] == id);
    await _dbHelper.updateHabit({
      'id': id,
      'title': title,
      'category': category,
      'icon': icon,
      'color': color,
      'checklist_enabled': checklistEnabled ? 1 : 0,
      'streak': habit['streak'],
      'completion_log': habit['completion_log'],
      'notes': habit['notes'] ?? '',
    });
    await loadHabits();
  }

  Future<void> deleteHabit(int id) async {
    _loading.add(true);
    await _dbHelper.deleteHabit(id);
    await loadHabits();
  }

  Future<void> updateHabitNotes(int id, String notes) async {
    _loading.add(true);
    final habit = _habits.firstWhere((h) => h['id'] == id);
    await _dbHelper.updateHabit({
      'id': id,
      'title': habit['title'],
      'category': habit['category'],
      'icon': habit['icon'],
      'color': habit['color'],
      'checklist_enabled': habit['checklist_enabled'],
      'streak': habit['streak'],
      'completion_log': habit['completion_log'],
      'notes': notes,
    });
    await loadHabits();
  }

  Future<int> toggleCompletion(int index, DateTime date) async {
    final habit = _habits[index];
    final completionLog = (jsonDecode(habit['completion_log'] as String? ?? '[]') as List)
        .map((d) => DateTime.parse(d as String))
        .toList();
    final isCompleted = completionLog.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
    if (isCompleted) {
      completionLog.removeWhere((d) => d.year == date.year && d.month == date.month && d.day == date.day);
    } else {
      completionLog.add(date);
    }
    final newStreak = _calculateStreak(completionLog);
    await _dbHelper.updateHabit({
      'id': habit['id'],
      'title': habit['title'],
      'category': habit['category'],
      'icon': habit['icon'],
      'color': habit['color'],
      'checklist_enabled': habit['checklist_enabled'],
      'streak': newStreak,
      'completion_log': jsonEncode(completionLog.map((d) => d.toIso8601String()).toList()),
      'notes': habit['notes'] ?? '',
    });
    await loadHabits();
    return newStreak;
  }

  int _calculateStreak(List<DateTime> log) {
    if (log.isEmpty) return 0;
    log.sort((a, b) => b.compareTo(a));
    int streak = 1;
    DateTime current = log.first;
    for (var date in log.skip(1)) {
      if (current.difference(date).inDays == 1) {
        streak++;
        current = date;
      } else {
        break;
      }
    }
    return streak;
  }

  bool get isDarkMode => _isDarkMode;
  bool _isDarkMode = false;

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  @override
  void dispose() {
    _loading.close();
    super.dispose();
  }
}