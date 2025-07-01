import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/home_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:habit_tracker_app/services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.I.registerSingleton<NavigationService>(NavigationService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()..loadHabits()),
      ],
      child: Builder(
        builder: (context) {
          final habitProvider = Provider.of<HabitProvider?>(context);
          return MaterialApp(
            navigatorKey: GetIt.I<NavigationService>().navigatorKey,
            title: 'Habit Tracker',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
                primary: Colors.blueAccent,
                onPrimary: Colors.black,
                secondary: Colors.tealAccent,
                onSecondary: Colors.black,
                surface: Colors.white,
                onSurface: Colors.black87,
              ),
              useMaterial3: true,
              textTheme: const TextTheme(
                headlineLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                bodyLarge: TextStyle(color: Colors.black54),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.blueAccent,
                  elevation: 8,
                  shadowColor: Colors.blue.withOpacity(0.5),
                ),
              ),
            ),
            darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
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
              textTheme: const TextTheme(
                headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                bodyLarge: TextStyle(color: Colors.white70),
              ),
            ),
            themeMode: habitProvider != null && habitProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}