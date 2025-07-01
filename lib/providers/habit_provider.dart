import 'package:flutter/material.dart';
import 'package:habit_tracker_app/database_helper.dart';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';

class HabitProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _habits = [];
  bool _isDarkMode = true;
  final BehaviorSubject<bool> _loading = BehaviorSubject.seeded(false);

  HabitProvider() {
    _initialize();
  }

  void _initialize() async {
    await loadHabits();
  }

  List<Map<String, dynamic>> get habits => _habits;
  bool get isDarkMode => _isDarkMode;
  Stream<bool> get loading => _loading.stream;

  Future<void> loadHabits() async {
    _loading.add(true);
    try {
      final loadedHabits = await _dbHelper.getHabits();
      _habits = loadedHabits ?? [];
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
      await _dbHelper.insertHabit(habit);
      await loadHabits(); // Single refresh
    } catch (e) {
      rethrow;
    } finally {
      _loading.add(false);
    }
  }

  Future<void> editHabit(int id, Map<String, dynamic> updatedHabit) async {
    _loading.add(true);
    try {
      await _dbHelper.updateHabit(id, updatedHabit);
      final updatedHabits = await _dbHelper.getHabits(); // Fetch updated habits
      _habits = updatedHabits ?? [];
      notifyListeners(); // Notify after updating local state
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
      await loadHabits();
    } catch (e) {
      rethrow;
    } finally {
      _loading.add(false);
    }
  }

  Future<void> toggleCompletion(int index, DateTime date) async {
    final habit = _habits[index];
    List<DateTime> completionLog = (jsonDecode(habit['completion_log'] as String) as List)
        .map((d) => DateTime.parse(d as String))
        .toList();
    final today = DateTime(date.year, date.month, date.day);
    bool wasCompleted = completionLog.contains(today);
    if (wasCompleted) {
      completionLog.remove(today);
    } else {
      completionLog.add(today);
    }
    completionLog.sort((a, b) => a.compareTo(b));

    final encodableLog = completionLog.map((dt) => dt.toIso8601String()).toList();
    final streak = _calculateStreak(completionLog, today);
    await editHabit(habit['id'] as int, {
      'completion_log': jsonEncode(encodableLog),
      'streak': streak,
    });
  }

  int _calculateStreak(List<DateTime> completionLog, DateTime today) {
    if (completionLog.isEmpty) return 0;
    completionLog.sort((a, b) => b.compareTo(a));
    int streak = 1;
    DateTime lastDate = completionLog[0];
    for (int i = 1; i < completionLog.length; i++) {
      if (completionLog[i].difference(lastDate).inDays == -1) {
        streak++;
        lastDate = completionLog[i];
      } else if (completionLog[i].difference(lastDate).inDays < -1) {
        break;
      }
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