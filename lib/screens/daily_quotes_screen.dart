import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class DailyQuotesScreen extends StatefulWidget {
  const DailyQuotesScreen({super.key});

  @override
  _DailyQuotesScreenState createState() => _DailyQuotesScreenState();
}

class _DailyQuotesScreenState extends State<DailyQuotesScreen> {
  final List<Map<String, String>> quotes = [
    {'text': 'The best way to predict the future is to create it.', 'image': 'assets/images/quote1.jpg'},
    {'text': 'Success is not final, failure is not fatal.', 'image': 'assets/images/quote2.jpg'},
    {'text': 'Believe you can and you\'re halfway there.', 'image': 'assets/images/quote3.jpg'},
  ];
  int _currentIndex = 0;

  void _nextQuote() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % quotes.length;
    });
  }

  void _previousQuote() {
    setState(() {
      _currentIndex = (_currentIndex - 1) % quotes.length;
      if (_currentIndex < 0) _currentIndex = quotes.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Quotes')),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: Card(
          key: ValueKey(_currentIndex),
          elevation: 4,
          margin: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Image.asset(quotes[_currentIndex]['image']!, fit: BoxFit.cover, height: 200),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  quotes[_currentIndex]['text']!,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _previousQuote,
            child: const Icon(Icons.arrow_back),
            heroTag: 'prevQuote',
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _nextQuote,
            child: const Icon(Icons.arrow_forward),
            heroTag: 'nextQuote',
          ),
        ],
      ),
    );
  }
}