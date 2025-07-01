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
  final List<Map<String, String>> _messages = [];
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

      final prompt = 'Provide tips for a user with the following habit data: $completionData. Suggest goals based on their streaks and completion logs.';
      final response = await _getGeminiResponse(prompt);
      setState(() {
        _messages.add({'role': 'bot', 'content': response});
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'content': 'Error fetching tips: $e'});
      });
      _scrollToBottom();
    }
  }

  Future<String> _getGeminiResponse(String prompt) async {
    if (prompt.toLowerCase().contains('owner') || prompt.toLowerCase().contains('who created')) {
      return 'The owner of this app is Sajid Ali Mohammed Sheikh.';
    }
    try {
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1/$_modelName:generateContent?key=$_apiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {'temperature': 1, 'topP': 0.95, 'topK': 40, 'maxOutputTokens': 8192}
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response from Gemini.';
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({'role': 'user', 'content': _controller.text});
      });
      _scrollToBottom();
      _getGeminiResponse(_controller.text).then((response) {
        setState(() {
          _messages.add({'role': 'bot', 'content': response});
        });
        _scrollToBottom();
      }).catchError((e) {
        setState(() {
          _messages.add({'role': 'bot', 'content': 'Error sending message: $e'});
        });
        _scrollToBottom();
      });
      _controller.clear();
    }
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
            ),
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
                    child: Text(
                      message['content']!,
                      style: TextStyle(
                        color: isUser
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
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
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.background,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    HapticFeedback.vibrate();
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
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