import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyMotivationScreen extends StatelessWidget {
  const DailyMotivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final motivations = [
      {
        'title': 'Stay Focused',
        'content': 'Keep pushing forward every day. Consistency is key to success.',
        'image': 'assets/images/motivation1.jpg'
      },
      {
        'title': 'Embrace Challenges',
        'content': 'Growth comes from overcoming obstacles. Face them with courage.',
        'image': 'assets/images/motivation2.jpg'
      },
    ];
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final motivation = motivations[DateTime.now().day % motivations.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Motivation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 10,
        shadowColor: Colors.blue.withOpacity(0.3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(motivation['image']!, fit: BoxFit.cover, height: 200, width: double.infinity),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      motivation['title']!,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      motivation['content']!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    Text('Date: $today', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}