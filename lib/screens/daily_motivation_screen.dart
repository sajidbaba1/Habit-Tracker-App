import 'package:flutter/material.dart';
import 'package:habit_tracker_app/extensions/date_time_extension.dart';

class DailyMotivationScreenContent extends StatelessWidget {
  const DailyMotivationScreenContent({super.key});

  List<Map<String, String>> get _motivationContent => [
    {'image': 'assets/images/motivation1.jpg', 'title': 'Stay Focused!', 'message': 'Keep your eyes on your goals. Every small step counts towards your success.'},
    {'image': 'assets/images/motivation2.jpg', 'title': 'You Are Enough!', 'message': 'Believe in yourself. You have everything you need to achieve greatness.'},
    {'image': 'assets/images/motivation3.jpg', 'title': 'Keep Going!', 'message': 'Progress, not perfection, is the key to lasting change.'},
  ];

  Map<String, String> _getDailyContent() {
    final now = DateTime.now();
    final dayOfYear = now.dayOfYear;
    final index = dayOfYear % _motivationContent.length;
    return _motivationContent[index];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final content = _getDailyContent();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Motivation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  content['image']!,
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.3,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              content['title']!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 8.0),
            Text(
              content['message']!,
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}