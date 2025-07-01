import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/screens/home_screen.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()),
      ],
      child: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          return MaterialApp(
            title: 'Habit Tracker',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
                primary: Colors.blueAccent,
                onPrimary: Colors.white,
                secondary: Colors.tealAccent,
                onSecondary: Colors.black,
                surface: Colors.grey[900],
                onSurface: Colors.white,
              ),
              useMaterial3: true,
              textTheme: const TextTheme(
                headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                bodyLarge: TextStyle(color: Colors.white70),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  elevation: 8,
                  shadowColor: Colors.blue.withOpacity(0.5),
                ),
              ),
            ),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: habitProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}