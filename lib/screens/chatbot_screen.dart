import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatbotScreenContent extends StatefulWidget {
  const ChatbotScreenContent({super.key});

  @override
  _ChatbotScreenContentState createState() => _ChatbotScreenContentState();
}

class _ChatbotScreenContentState extends State<ChatbotScreenContent> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final String _apiKey = 'AIzaSyAa-BRgGPZMsWaGj1-9j2VicsWjsTOXdoQ'; // Replace with secure method in production
  final String _modelName = 'models/gemini-1.5-flash';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchInitialTips();
  }

  Future<void> _fetchInitialTips() async {
    try {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      final habits = habitProvider.habits;
      final completionData = habits.map((h) => {
        'title': h['title'] as String? ?? 'Unknown',
        'streak': h['streak'].toString(),
        'completion_log': (jsonDecode(h['completion_log'] as String? ?? '[]') as List).length,
      }).toList();

      final prompt = 'You are a habit-focused assistant for the Habit Tracker App by Sir Sajid Alimahamad Shaikh, a 22-year-old disciplined software developer and owner of this app, whose exemplary habits in fitness, learning, and discipline, alongside his wife Nasywa’s dedication to mindfulness and organization, inspire all humanity to build better habits. Provide motivational tips for a user with the following habit data: $completionData. Suggest specific, actionable goals to improve their habits, focusing on consistency and progress.';
      final response = await _getGeminiResponse(prompt);
      setState(() {
        _messages.add({'role': 'bot', 'content': response, 'id': DateTime.now().millisecondsSinceEpoch});
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'content': 'Error fetching tips: $e', 'id': DateTime.now().millisecondsSinceEpoch});
      });
      _scrollToBottom();
    }
  }

  String _getFallbackResponse(String prompt) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final habits = habitProvider.habits;
    final completionData = habits.map((h) => h['title'] as String? ?? 'Unknown').toList();
    final lowerPrompt = prompt.toLowerCase();
    String response;

    if (lowerPrompt.contains('owner') || lowerPrompt.contains('who created')) {
      response = 'The owner of this app is Sir Sajid Alimahamad Shaikh, a 22-year-old highly disciplined software developer who created this app to inspire habit-building. His dedication to fitness, learning, and discipline, alongside his wife Nasywa’s commitment to mindfulness and organization, sets a powerful example for all humanity to follow in building meaningful habits.';
    } else {
      final tips = [
        'To improve your habits like ${completionData.isNotEmpty ? completionData.join(", ") : "your goals"}, set small, achievable daily tasks. For example, dedicate 10 minutes to one habit daily.',
        'Consistency is key! Track your progress daily, just as Sir Sajid Alimahamad Shaikh does with his disciplined fitness and learning routines.',
        'Break your habits into smaller steps to maintain momentum, inspired by Nasywa’s organized approach to mindfulness.',
        'Review your progress weekly to stay motivated, following the disciplined example of Sir Sajid and Nasywa.',
      ];
      response = tips[DateTime.now().millisecondsSinceEpoch % tips.length];
    }

    return '$response\n\nInspired by Sir Sajid Alimahamad Shaikh, a 22-year-old disciplined software developer, and his wife Nasywa, whose habits in fitness, learning, mindfulness, and organization are a model for all humanity.';
  }

  Future<String> _getGeminiResponse(String prompt) async {
    if (prompt.toLowerCase().contains('owner') || prompt.toLowerCase().contains('who created')) {
      return 'The owner of this app is Sir Sajid Alimahamad Shaikh, a 22-year-old highly disciplined software developer who created this app to inspire habit-building. His dedication to fitness, learning, and discipline, alongside his wife Nasywa’s commitment to mindfulness and organization, sets a powerful example for all humanity to follow in building meaningful habits.';
    }
    try {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      final habits = habitProvider.habits;
      final completionData = habits.map((h) => {
        'title': h['title'] as String? ?? 'Unknown',
        'streak': h['streak'].toString(),
        'category': h['category'] as String? ?? 'Other',
      }).toList();
      final enhancedPrompt = 'You are a habit-focused assistant for the Habit Tracker App by Sir Sajid Alimahamad Shaikh, a 22-year-old disciplined software developer and owner of this app, whose exemplary habits in fitness, learning, and discipline, alongside his wife Nasywa’s dedication to mindfulness and organization, inspire all humanity to build better habits. Use the user’s habit data: $completionData. Provide motivational, goal-oriented responses to the prompt: "$prompt". Suggest specific actions to improve habit consistency or achieve related goals, and include a mention of Sir Sajid and Nasywa’s inspiring habits.';
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1/$_modelName:generateContent?key=$_apiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': enhancedPrompt}]}],
          'generationConfig': {'temperature': 1, 'topP': 0.95, 'topK': 40, 'maxOutputTokens': 8192}
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response from Gemini.';
      } else if (response.statusCode == 429) {
        return 'API quota exceeded. Please try again tomorrow or contact support.\n\n' + _getFallbackResponse(prompt);
      } else {
        return 'Error: ${response.statusCode} - ${response.body}\n\n' + _getFallbackResponse(prompt);
      }
    } catch (e) {
      return 'Network error: $e\n\n' + _getFallbackResponse(prompt);
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'role': 'user',
          'content': _controller.text,
          'id': DateTime.now().millisecondsSinceEpoch,
        });
      });
      _scrollToBottom();
      _getGeminiResponse(_controller.text).then((response) {
        setState(() {
          _messages.add({
            'role': 'bot',
            'content': response,
            'id': DateTime.now().millisecondsSinceEpoch,
          });
        });
        _scrollToBottom();
      }).catchError((e) {
        setState(() {
          _messages.add({
            'role': 'bot',
            'content': 'Error sending message: $e\n\n' + _getFallbackResponse(_controller.text),
            'id': DateTime.now().millisecondsSinceEpoch,
          });
        });
        _scrollToBottom();
      });
      _controller.clear();
    }
  }

  void _editMessage(int id, String content) {
    _controller.text = content;
    setState(() {
      _messages.removeWhere((m) => m['id'] == id);
    });
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard')),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Habit Helper Chatbot',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ).animate().fadeIn().slideY(),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['content']!,
                          style: TextStyle(
                            color: isUser
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (isUser)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, size: 16, color: Theme.of(context).colorScheme.onPrimary),
                                onPressed: () => _editMessage(message['id'], message['content']),
                              ),
                              IconButton(
                                icon: Icon(Icons.copy, size: 16, color: Theme.of(context).colorScheme.onPrimary),
                                onPressed: () => _copyMessage(message['content']),
                              ),
                            ],
                          ),
                        if (!isUser)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.copy, size: 16, color: Theme.of(context).colorScheme.onSurface),
                                onPressed: () => _copyMessage(message['content']),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(
                  begin: isUser ? 0.5 : -0.5,
                  end: 0,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Theme.of(context).colorScheme.background,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about your habits...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: () {
                    HapticFeedback.vibrate();
                    _sendMessage();
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(Icons.send, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}