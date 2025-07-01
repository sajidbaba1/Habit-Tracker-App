import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/license_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchURL(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch URL')));
    }
  }

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
            title: const Text('Explore Other Apps'),
            onTap: () {
              HapticFeedback.vibrate();
              _launchURL(context, 'https://moodapps.netlify.app');
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