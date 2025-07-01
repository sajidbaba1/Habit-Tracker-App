import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:habit_tracker_app/database_helper.dart';
import 'package:rxdart/rxdart.dart';

class HabitProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _habits = [];
  bool _isDarkMode = true;
  final BehaviorSubject<bool> _loading = BehaviorSubject.seeded(false);

  HabitProvider();

  void _initialize() async {
    await loadHabits();
  }

  List<Map<String, dynamic>> get habits => List.unmodifiable(_habits);
  bool get isDarkMode => _isDarkMode;
  Stream<bool> get loading => _loading.stream;

  Future<void> loadHabits() async {
    _loading.add(true);
    try {
      _habits = await _dbHelper.getHabits();
      for (var habit in _habits) {
        final completionLog = (jsonDecode(habit['completion_log'] as String? ?? '[]') as List)
            .map((d) => DateTime.parse(d as String))
            .toList();
        final streak = _calculateStreak(completionLog, DateTime.now());
        if (streak != (habit['streak'] as int)) {
          await editHabit(habit['id'], {'streak': streak});
        }
      }
    } catch (e) {
      _habits = [];
    } finally {
      _loading.add(false);
      notifyListeners();
    }
  }

  Future<void> addHabit(Map<String, dynamic> habit) async {
    _loading.add(true);
    try {
      final habitWithDefaults = {
        ...habit,
        'streak': habit['streak'] ?? 0,
        'completion_log': habit['completion_log'] ?? '[]',
        'checklistEnabled': habit['checklistEnabled'] ?? false,
      };
      final id = await _dbHelper.insertHabit(habitWithDefaults);
      habitWithDefaults['id'] = id;
      _habits.add(habitWithDefaults);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _loading.add(false);
    }
  }

  Future<void> editHabit(int id, Map<String, dynamic> updates) async {
    _loading.add(true);
    try {
      await _dbHelper.updateHabit(id, updates);
      final index = _habits.indexWhere((h) => h['id'] == id);
      if (index != -1) {
        _habits[index] = {..._habits[index], ...updates};
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _loading.add(false);
    }
  }

  Future<void> deleteHabit(int id) async {
    _loading.add(true);
    try {
      await _dbHelper.deleteHabit(id);
      _habits.removeWhere((h) => h['id'] == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _loading.add(false);
    }
  }

  Future<void> toggleCompletion(int index, DateTime date) async {
    if (index >= 0 && index < _habits.length) {
      final habit = _habits[index];
      List<DateTime> completionLog = (jsonDecode(habit['completion_log'] as String? ?? '[]') as List)
          .map((d) => DateTime.parse(d as String))
          .toList();
      final today = DateTime(date.year, date.month, date.day);
      if (completionLog.any((d) => d.year == today.year && d.month == today.month && d.day == today.day)) {
        completionLog.removeWhere((d) => d.year == today.year && d.month == today.month && d.day == today.day);
      } else {
        completionLog.add(today);
      }
      completionLog.sort((a, b) => a.compareTo(b));
      final streak = _calculateStreak(completionLog, today);
      await editHabit(habit['id'], {
        'completion_log': jsonEncode(completionLog.map((d) => d.toIso8601String()).toList()),
        'streak': streak,
      });
    }
  }

  int _calculateStreak(List<DateTime> completionLog, DateTime today) {
    if (completionLog.isEmpty) return 0;
    completionLog.sort((a, b) => b.compareTo(a));
    final todayStart = DateTime(today.year, today.month, today.day);
    int streak = 0;
    DateTime? lastDate;

    for (var date in completionLog) {
      final dateStart = DateTime(date.year, date.month, date.day);
      if (lastDate == null) {
        if (dateStart.isBefore(todayStart) || dateStart.isAtSameMomentAs(todayStart)) {
          streak = 1;
          lastDate = dateStart;
        }
        continue;
      }
      if (dateStart.difference(lastDate).inDays == -1) {
        streak++;
        lastDate = dateStart;
      } else if (dateStart.difference(lastDate).inDays < -1) {
        break;
      }
    }

    if (lastDate != null && todayStart.difference(lastDate).inDays > 1) {
      return 0;
    }
    return streak;
  }

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _loading.close();
    super.dispose();
  }
}