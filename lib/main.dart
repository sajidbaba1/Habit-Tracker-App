import 'package:flutter/material.dart';
import 'package:habit_tracker_app/screens/add_habit_screen.dart';
import 'package:habit_tracker_app/screens/analytics_screen.dart';
import 'package:habit_tracker_app/screens/chatbot_screen.dart';
import 'package:habit_tracker_app/screens/daily_motivation_screen.dart';
import 'package:habit_tracker_app/screens/habit_tracker_screen.dart';
import 'package:habit_tracker_app/screens/license_screen.dart';
import 'package:habit_tracker_app/screens/settings_screen.dart';
import 'package:habit_tracker_app/screens/sjd_coins_screen.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/home_screen.dart';
import 'package:habit_tracker_app/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

void main() {
  setupGetIt();
  runApp(const MyApp());
}

void setupGetIt() {
  GetIt.instance.registerLazySingleton(() => NavigationService());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HabitProvider(),
      child: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          return MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            title: 'Habit Tracker App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: habitProvider.isDarkMode ? Brightness.dark : Brightness.light,
              useMaterial3: true,
            ),
            home: const HomeScreen(),
            routes: {
              '/add_habit': (context) => const AddHabitScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/sjd_coins': (context) => const SJDCoinsScreen(),
              '/analytics': (context) => const AnalyticsScreenContent(),
              '/motivation': (context) => const DailyMotivationScreenContent(),
              '/chatbot': (context) => const ChatbotScreenContent(),
              '/tracker': (context) => const HabitTrackerScreen(),
              '/license': (context) => const LicenseScreen(),
            },
          );
        },
      ),
    );
  }
}