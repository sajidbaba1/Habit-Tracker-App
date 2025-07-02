import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/license_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  void _sendFeedback(BuildContext context) {
    final uri = Uri(
      scheme: 'mailto',
      path: 'thsajid831@gmail.com',
      queryParameters: {
        'subject': 'Feedback for Habit Tracker App',
        'body': 'Hi Sajid Alimahamad Shaikh,\n\nHere is my feedback for the Habit Tracker App:\n',
      },
    );
    _launchURL(context, uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings').animate().fadeIn().slideY(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary).animate().fadeIn(),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            height: 150,
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              image: const DecorationImage(
                image: AssetImage('assets/sajid_placeholder.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ).animate().fadeIn().scale(),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              'Habit Tracker App - Version 1.0',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
            ),
          ).animate().fadeIn().slideY(),
          SwitchListTile(
            title: const Text('Widget Theme'),
            subtitle: const Text('Toggle to enable dark mode'),
            value: habitProvider.isDarkMode,
            onChanged: (value) {
              HapticFeedback.vibrate();
              habitProvider.toggleTheme(value);
            },
          ).animate().fadeIn().slideY(),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share App'),
            onTap: () {
              HapticFeedback.vibrate();
              _shareApp(context);
            },
          ).animate().fadeIn().slideY(),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            onTap: () {
              HapticFeedback.vibrate();
              _sendFeedback(context);
            },
          ).animate().fadeIn().slideY(),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate Us Five Stars'),
            onTap: () {
              HapticFeedback.vibrate();
              _launchURL(context, 'https://play.google.com/store/apps/details?id=com.example.habit_tracker_app');
            },
          ).animate().fadeIn().slideY(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              HapticFeedback.vibrate();
              _launchURL(context, 'https://habittracker.app/privacy');
            },
          ).animate().fadeIn().slideY(),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms and Conditions'),
            onTap: () {
              HapticFeedback.vibrate();
              _launchURL(context, 'https://habittracker.app/terms');
            },
          ).animate().fadeIn().slideY(),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text('Check for Updates'),
            onTap: () {
              HapticFeedback.vibrate();
              _launchURL(context, 'https://habittracker.app/updates');
            },
          ).animate().fadeIn().slideY(),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('License'),
            onTap: () {
              HapticFeedback.vibrate();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LicenseScreen()));
            },
          ).animate().fadeIn().slideY(),
        ],
      ),
    );
  }
}