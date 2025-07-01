import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/add_habit_screen.dart';
import 'package:habit_tracker_app/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

class HabitCard extends StatefulWidget {
  const HabitCard({super.key, required this.index});

  final int index;

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  final List<String> _motivationalQuotes = [
    'Every small step counts towards your success!',
    'Keep pushing forward, you’ve got this!',
    'Consistency is the key to greatness!',
    'Your effort today builds your future!',
    'Stay focused and keep up the momentum!',
  ];

  bool _showProgressBar = true;

  String _getRandomQuote() {
    return _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
  }

  void showCongratulationCard(String habitTitle, int streak) {
    if (streak > 0) {
      HapticFeedback.vibrate();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.yellow[700]!, Colors.orange[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 60, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  'Congratulations!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: const Duration(milliseconds: 300)).scale(),
                const SizedBox(height: 10),
                Text(
                  'You increased the streak for "$habitTitle" to $streak day${streak > 1 ? 's' : ''}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slide(),
                const SizedBox(height: 10),
                Text(
                  '"${_getRandomQuote()}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white70),
                ).animate().fadeIn(duration: const Duration(milliseconds: 500)).shake(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.vibrate();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('OK'),
                ).animate().fadeIn(duration: const Duration(milliseconds: 600)).scale(),
              ],
            ),
          ).animate(
            effects: const [
              FadeEffect(duration: Duration(milliseconds: 700)),
              ScaleEffect(duration: Duration(milliseconds: 700)),
            ],
          ),
        ),
      );
    }
  }

  void confirmDelete(HabitProvider habitProvider, int habitId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Habit?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete this habit? This action cannot be undone.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.vibrate();
              Navigator.of(context).pop();
            },
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.vibrate();
              habitProvider.deleteHabit(habitId);
              Navigator.of(context).pop();
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Color(habit['color'] as int? ?? Colors.blue.value),
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
                        IconData(habit['icon'] as int? ?? Icons.favorite.codePoint, fontFamily: 'MaterialIcons'),
                        size: 24,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        habit['title'] as String? ?? 'Untitled',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, size: 24, color: Theme.of(context).colorScheme.onSurface),
                        onPressed: () {
                          HapticFeedback.vibrate();
                          GetIt.I<NavigationService>().navigateTo(AddHabitScreen(habitId: habit['id']));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 24, color: Theme.of(context).colorScheme.error),
                        onPressed: () => confirmDelete(habitProvider, habit['id'] as int),
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
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ),
              IconButton(
                icon: Icon(_showProgressBar ? Icons.bar_chart : Icons.list),
                onPressed: () {
                  HapticFeedback.vibrate();
                  setState(() => _showProgressBar = !_showProgressBar);
                },
                color: Theme.of(context).colorScheme.onSurface,
              ),
              if (_showProgressBar)
                SizedBox(
                  height: 100,
                  child: CanvasPanel(
                    child: CustomPaint(
                      painter: StreakChartPainter(completionLog: completionLog),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Previous Streak: ${habit['streak'] ?? 0} days\nLast Updated: ${completionLog.isNotEmpty ? DateFormat('d MMMM').format(completionLog.last) : 'N/A'}',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              const SizedBox(height: 8.0),
              // GitHub-Style Streak Grid
              Text('30-Day Streak', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('d MMM').format(DateTime.now().subtract(const Duration(days: 29))),
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  Text(
                    DateFormat('d MMM').format(DateTime.now()),
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  ),
                ],
              ),
              GridView.count(
                crossAxisCount: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: List.generate(30, (dayIndex) {
                  final date = DateTime.now().subtract(Duration(days: 29 - dayIndex));
                  final isCompleted = completionLog.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
                  return GestureDetector(
                    onTap: () async {
                      HapticFeedback.vibrate();
                      final newStreak = await habitProvider.toggleCompletion(widget.index, date);
                      setState(() {});
                      if (newStreak > 0) {
                        showCongratulationCard(habit['title'] as String? ?? 'Untitled', newStreak);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ).animate().fadeIn(),
                  );
                }),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Streak: ${habit['streak'] ?? 0} days',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  IconButton(
                    icon: Icon(Icons.check, size: 24, color: isTodayCompleted ? Colors.green : Theme.of(context).colorScheme.onSurface),
                    onPressed: () async {
                      HapticFeedback.vibrate();
                      final newStreak = await habitProvider.toggleCompletion(widget.index, today);
                      setState(() {});
                      if (newStreak > 0) {
                        showCongratulationCard(habit['title'] as String? ?? 'Untitled', newStreak);
                      }
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

class StreakChartPainter extends CustomPainter {
  final List<DateTime> completionLog;

  StreakChartPainter({required this.completionLog});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final maxHeight = size.height * 0.8;
    final barWidth = size.width / 7;
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: 6 - i));
      final isCompleted = completionLog.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
      final barHeight = isCompleted ? maxHeight : maxHeight * 0.3;
      final left = i * barWidth;
      final rect = Rect.fromLTWH(left, size.height - barHeight, barWidth - 2, barHeight);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CanvasPanel extends StatelessWidget {
  final Widget child;

  const CanvasPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      child: child,
    );
  }
}