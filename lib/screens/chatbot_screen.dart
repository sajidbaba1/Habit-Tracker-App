import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String _apiKey = 'AIzaSyAa-BRgGPZMsWaGj1-9j2VicsWjsTOXdoQ'; // Replace with secure method in production
  final String _modelName = 'models/gemini-1.5-flash'; // Updated to a supported model

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
        'title': h['title'],
        'streak': h['streak'],
        'completion_log': jsonDecode(h['completion_log'] as String).length,
      }).toList();

      final prompt = 'Provide tips for a user with the following habit data: $completionData. Suggest goals based on their streaks and completion logs.';
      final response = await _getGeminiResponse(prompt);
      setState(() {
        _messages.add({'role': 'bot', 'content': response});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'content': 'Error fetching tips: $e'});
      });
    }
  }

  Future<String> _getGeminiResponse(String prompt) async {
    try {
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1/$_modelName:generateContent?key=$_apiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {'temperature': 1, 'topP': 0.95, 'topK': 40, 'maxOutputTokens': 8192} // Optional config
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
      _getGeminiResponse(_controller.text).then((response) {
        setState(() {
          _messages.add({'role': 'bot', 'content': response});
        });
      }).catchError((e) {
        setState(() {
          _messages.add({'role': 'bot', 'content': 'Error sending message: $e'});
        });
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message['role'] == 'user' ? 'You: ${message['content']}' : 'Bot: ${message['content']}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
}