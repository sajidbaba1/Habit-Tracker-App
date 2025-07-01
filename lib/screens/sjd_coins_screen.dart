import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';

class SJDCoinsScreen extends StatelessWidget {
  const SJDCoinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final totalCoins = habitProvider.habits.fold(0, (sum, habit) => sum + (habit['streak'] as int? ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('SJD Coins'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.yellow[700]!, Colors.orange[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, size: 40, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Your SJD Coins: $totalCoins',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(),
            const SizedBox(height: 24),
            Text(
              'About SJD Coins',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: const Text('How to Earn Coins'),
                subtitle: const Text('Earn 1 SJD Coin for each day you maintain a habit streak. The longer your streak, the more coins you collect!'),
              ),
            ).animate().fadeIn().slideY(),
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.yellow),
                title: const Text('Coin Benefits'),
                subtitle: const Text('Use SJD Coins to unlock premium features, discounts, or special rewards in the app.'),
              ),
            ).animate().fadeIn().slideY(),
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.rule, color: Colors.green),
                title: const Text('Rules'),
                subtitle: const Text('Coins are non-transferable and reset if habits are deleted. Keep building your streaks to earn more!'),
              ),
            ).animate().fadeIn().slideY(),
            const SizedBox(height: 24),
            Text(
              'Subscription Discount',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.discount, color: Colors.purple),
                title: const Text('Premium Subscription'),
                subtitle: const Text('Use 100 SJD Coins to get 20% off a premium subscription! Unlock advanced analytics and exclusive challenges.'),
                trailing: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.vibrate();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Subscribe Now'),
                        content: const Text('Redeem 100 SJD Coins for a 20% discount on your premium subscription?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Placeholder for subscription logic
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Subscription processing... (Coming soon)')),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Redeem'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Subscribe'),
                ),
              ),
            ).animate().fadeIn().slideY(),
          ],
        ),
      ),
    );
  }
}