import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/license_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching URL: $e')),
      );
    }
  }

  void _shareApp(BuildContext context) {
    Share.share(
      'Check out the Habit Tracker App by Sajid Alimahamad Shaikh! Build better habits today: https://habittracker.app',
      subject: 'Try Habit Tracker App!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
            title: const Text('Share App'),
            onTap: () {
              HapticFeedback.vibrate();
              _shareApp(context);
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