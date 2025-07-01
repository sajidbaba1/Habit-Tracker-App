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
      _habits = loadedHabits;
      for (var habit in _habits) {
        final completionLog = (jsonDecode(habit['completion_log'] as String) as List)
            .map((d) => DateTime.parse(d as String)).toList();
        final streak = _calculateStreak(completionLog, DateTime.now());
        if (streak != (habit['streak'] as int)) {
          await updateHabit(habit['id'] as int, {'streak': streak});
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
      final id = await _dbHelper.insertHabit(habit);
      await loadHabits();
    } catch (e) {
      rethrow;
    } finally {
      _loading.add(false);
    }
  }

  Future<void> updateHabit(int id, Map<String, dynamic> updates) async {
    _loading.add(true);
    try {
      await _dbHelper.updateHabit(id, updates);
      await loadHabits();
    } catch (e) {
      rethrow;
    } finally {
      _loading.add(false);
    }
  }

  void toggleCompletion(int index, BuildContext context, DateTime date) async {
    final habit = _habits[index];
    List<DateTime> completionLog = (jsonDecode(habit['completion_log'] as String) as List)
        .map((d) => DateTime.parse(d as String)).toList();
    final today = DateTime(date.year, date.month, date.day);
    final isCompleted = completionLog.any((d) => d.year == today.year && d.month == today.month && d.day == today.day);
    if (isCompleted) {
      completionLog.removeWhere((d) => d.year == today.year && d.month == today.month && d.day == today.day);
    } else {
      completionLog.add(today);
    }
    completionLog.sort((a, b) => a.compareTo(b));
    final streak = _calculateStreak(completionLog, today);
    final oldStreak = habit['streak'] as int;
    await updateHabit(habit['id'] as int, {
      'completion_log': jsonEncode(completionLog.map((d) => d.toIso8601String()).toList()),
      'streak': streak,
    });
    if (!isCompleted && streak > oldStreak) {
      _showCongratulation(context, streak - oldStreak); // Show congrats if streak increased
    }
    notifyListeners();
  }

  int _calculateStreak(List<DateTime> completionLog, DateTime today) {
    if (completionLog.isEmpty) return 0;
    completionLog.sort((a, b) => b.compareTo(a)); // Sort descending
    final todayStart = DateTime(today.year, today.month, today.day);
    int streak = 0;
    DateTime? lastDate;

    for (var date in completionLog) {
      final dateStart = DateTime(date.year, date.month, date.day);
      if (lastDate == null) {
        streak = 1;
        lastDate = dateStart;
        continue;
      }
      if (dateStart.difference(lastDate).inDays == -1) {
        streak++;
        lastDate = dateStart;
      } else if (dateStart.difference(lastDate).inDays < -1) {
        break;
      }
    }

    // Ensure streak includes today if completed
    if (completionLog.contains(todayStart)) {
      final lastCompleted = completionLog[0];
      if (todayStart.difference(lastCompleted).inDays <= 0) {
        streak = completionLog.length;
      }
    } else if (lastDate != null && todayStart.difference(lastDate).inDays > 1) {
      return 0; // Reset if gap is more than 1 day
    }
    return streak;
  }

  Future<void> editHabit(int id, Map<String, dynamic> updatedHabit) async {
    _loading.add(true);
    try {
      await _dbHelper.updateHabit(id, {
        'title': updatedHabit['title'],
        'description': updatedHabit['description'],
        'color': updatedHabit['color'],
        'icon': updatedHabit['icon'],
        'frequency': updatedHabit['frequency'],
        'checklistEnabled': updatedHabit['checklistEnabled'] ? 1 : 0,
      });
      await loadHabits();
    } catch (e) {
      rethrow;
    } finally {
      _loading.add(false);
    }
  }

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void _showCongratulation(BuildContext context, int streakIncrease) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!', style: TextStyle(color: Colors.green)),
        content: Text('Your streak increased by $streakIncrease day${streakIncrease > 1 ? 's' : ''}! Keep it up!'),
        actions: [
          TextButton(
            child: const Text('OK', style: TextStyle(color: Colors.blueAccent)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _loading.close();
    super.dispose();
  }
}