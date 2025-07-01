import 'package:flutter/material.dart';
import 'package:habit_tracker_app/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

class DailyMotivationScreen extends StatelessWidget {
  const DailyMotivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = GetIt.I<NavigationService>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Motivation',
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 10,
        shadowColor: Colors.blue.withValues(alpha: 0.3),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => navigationService.goBack(),
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
                    'assets/images/motivation1.jpg',
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.3,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Stay Focused!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Keep your eyes on your goals. Every small step counts towards your success.',
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    'assets/images/motivation2.jpg',
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.3,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'You Are Enough!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Believe in yourself. You have everything you need to achieve greatness.',
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}