import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker_app/screens/add_habit_screen.dart';
import 'package:habit_tracker_app/screens/settings_screen.dart';
import 'package:habit_tracker_app/screens/daily_motivation_screen.dart';
import 'package:habit_tracker_app/screens/chatbot_screen.dart';
import 'package:habit_tracker_app/screens/analytics_screen.dart';
import 'package:habit_tracker_app/screens/habit_tracker_screen.dart';
import 'package:habit_tracker_app/screens/sjd_coins_screen.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/widgets/habit_card.dart';
import 'package:habit_tracker_app/services/navigation_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(hours: 24),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _updateDayProgress();
  }

  void _updateDayProgress() {
    final now = DateTime.now();
    final secondsInDay = 24 * 60 * 60;
    final elapsedSeconds = now.hour * 3600 + now.minute * 60 + now.second;
    _controller.value = elapsedSeconds / secondsInDay;
    _controller.forward();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  int _calculateSJDCoin(HabitProvider habitProvider) {
    return habitProvider.habits.fold(0, (sum, habit) => sum + (habit['streak'] as int? ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
        title: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              _getGreeting(),
              textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              speed: const Duration(milliseconds: 100),
            ),
          ],
          totalRepeatCount: 1,
        ).animate().fadeIn().slideY(),
        actions: [
          GestureDetector(
            onTap: () {
              HapticFeedback.vibrate();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SJDCoinsScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.yellow, size: 24).animate().fadeIn(),
                  const SizedBox(width: 4),
                  Consumer<HabitProvider>(
                    builder: (context, provider, child) => Text(
                      'SJD: ${_calculateSJDCoin(provider)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 30).animate().fadeIn(),
            onPressed: () {
              HapticFeedback.vibrate();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 10,
        shadowColor: Colors.blue.withValues(alpha: 0.3),
      )
          : null,
      drawer: _selectedIndex == 0
          ? Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: Text(
                'Menu',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb),
              title: const Text('Daily Motivation'),
              onTap: () {
                HapticFeedback.vibrate();
                setState(() => _selectedIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_quote),
              title: const Text('Daily Quotes'),
              onTap: () {
                HapticFeedback.vibrate();
                setState(() => _selectedIndex = 3); // Use Motivation screen for now
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                HapticFeedback.vibrate();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ).animate().fadeIn().slideX()
          : null,
      body: _screens[_selectedIndex].animate().fadeIn().scale(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Tracker'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Motivation'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
        ],
        currentIndex: _selectedIndex == 2 ? 2 : _selectedIndex > 2 ? _selectedIndex - 1 : _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ).animate().fadeIn().slideY(begin: 0.5),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> get progressAnimation => _progressAnimation;

  final List<Widget> _screens = [
    const HomeContent(),
    const AnalyticsScreenContent(),
    const AddHabitScreen(),
    const DailyMotivationScreenContent(),
    const ChatbotScreenContent(),
    const HabitTrackerScreen(),
  ];
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final today = DateTime.now();
    final weekday = today.weekday;
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final day = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
                    final isToday = index + 1 == weekday;
                    return AnimatedBuilder(
                      animation: homeState!.progressAnimation,
                      builder: (context, _) => Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isToday
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                                  : Colors.transparent,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: isToday ? 2 : 1,
                              ),
                            ),
                          ),
                          if (isToday)
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                value: homeState.progressAnimation.value,
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(delay: Duration(milliseconds: index * 100));
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('d MMMM yyyy').format(today),
                  style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                ).animate().fadeIn().slideY(),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<bool>(
              stream: habitProvider.loading,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return const Center(child: CircularProgressIndicator()).animate().fadeIn();
                }
                if (habitProvider.habits.isEmpty) {
                  return const Center(child: Text('No habits yet. Add a new one!', style: TextStyle(fontSize: 18)))
                      .animate().fadeIn().scale();
                }
                return RefreshIndicator(
                  onRefresh: () => habitProvider.loadHabits(),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 8.0),
                    itemCount: habitProvider.habits.length,
                    itemBuilder: (context, index) => AnimatedBuilder(
                      animation: habitProvider,
                      builder: (context, child) => HabitCard(index: index).animate().fadeIn().slideY(delay: Duration(milliseconds: index * 100)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}