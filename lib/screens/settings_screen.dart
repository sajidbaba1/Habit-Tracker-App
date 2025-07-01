import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/license_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: habitProvider.isDarkMode,
            onChanged: (value) {
              HapticFeedback.vibrate();
              habitProvider.toggleTheme(value);
            },
          ),
          ListTile(
            title: const Text('Navigate to Other Apps'),
            onTap: () {
              HapticFeedback.vibrate();
              // Add navigation logic to other apps (e.g., URL launch or app switch)
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigate to other apps (placeholder)')));
            },
          ),
          ListTile(
            title: const Text('License'),
            onTap: () {
              HapticFeedback.vibrate();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LicenseScreen()));
            },
          ),
        ],
      ),
    );
  }
}