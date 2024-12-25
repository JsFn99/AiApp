import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import '../../../components/sidebar.dart';

class GeminiChat extends StatefulWidget {
  const GeminiChat({Key? key}) : super(key: key);

  @override
  _GeminiChatState createState() => _GeminiChatState();
}

class _GeminiChatState extends State<GeminiChat> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  // Initialize Gemini API with the provided API key
  Future<void> _initializeGemini() async {
    const apiKey = 'AIzaSyCKpaedXWlht53mo2EHcu-GBWY7Ym9Z1R8';
    try {
      await Gemini.init(apiKey: apiKey);
    } catch (e) {
      print('Failed to initialize Gemini: $e');
    }
  }

  // Method to send a prompt to Gemini and get a response
  Future<void> _sendMessage(String prompt) async {
    if (prompt.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'content': prompt});
    });

    try {
      final response = await Gemini.instance.chat([
        Content(parts: [Part.text(prompt)], role: 'user'),
      ]);

      setState(() {
        messages.add({'role': 'assistant', 'content': response?.output ?? 'No response'});
      });
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        messages.add({'role': 'assistant', 'content': 'An error occurred while generating a response.'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini 1.5 Chatbot'),
        centerTitle: true,
      ),
      drawer: const Sidebar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Align(
                    alignment: message['role'] == 'user'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message['role'] == 'user' ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message['content']!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
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
                    decoration: const InputDecoration(
                      hintText: 'Ask something...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
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
