import 'package:flutter/material.dart';
import 'package:habit_tracker_app/services/navigation_service.dart';
import 'package:get_it/get_it.dart';
import 'package:habit_tracker_app/extensions/date_time_extension.dart';

class DailyQuotesScreen extends StatelessWidget {
  const DailyQuotesScreen({super.key});

  List<Map<String, String>> get _quoteContent => [
    {'image': 'assets/images/quote1.jpg', 'quote': '"The only way to do great work is to love what you do."', 'author': '- Steve Jobs'},
    {'image': 'assets/images/quote2.jpg', 'quote': '"Success is not final, failure is not fatal: It is the courage to continue that counts."', 'author': '- Winston Churchill'},
    {'image': 'assets/images/quote3.jpg', 'quote': '"Believe you can and you\'re halfway there."', 'author': '- Theodore Roosevelt'},
  ];

  Map<String, String> _getDailyQuote() {
    final now = DateTime.now();
    final dayOfYear = now.dayOfYear;
    final index = dayOfYear % _quoteContent.length;
    return _quoteContent[index];
  }

  @override
  Widget build(BuildContext context) {
    final navigationService = GetIt.I<NavigationService>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final content = _getDailyQuote();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Quotes',
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 10,
        shadowColor: Colors.blue.withValues(alpha: 0.3),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                content['quote']!,
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                content['author']!,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}