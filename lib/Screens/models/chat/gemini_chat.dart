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

  double temperature = 0.75;
  double topP = 0.9;
  double topK = 40.0; // Changed to double
  int maxOutputTokens = 512;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  Future<void> _initializeGemini() async {
    const apiKey = 'AIzaSyCKpaedXWlht53mo2EHcu-GBWY7Ym9Z1R8';
    try {
      await Gemini.init(apiKey: apiKey);
    } catch (e) {
      print('Failed to initialize Gemini: $e');
    }
  }

  Future<void> _sendMessage(String prompt) async {
    if (prompt.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'content': prompt});
    });

    try {
      final response = await Gemini.instance.chat(
        [
          Content(parts: [Part.text(prompt)], role: 'user'),
        ],
        generationConfig: GenerationConfig(
          temperature: temperature,
          topP: topP,
          topK: topK.toInt(),
          maxOutputTokens: maxOutputTokens,
        ),
      );

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
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Gemini 1.5 Chatbot'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      drawer: const Sidebar(), // Original sidebar remains here
      endDrawer: Drawer( // New right-side drawer for parameters
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // space
            const SizedBox(height: 200),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Temperature', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(temperature.toStringAsFixed(2)),
                  Slider(
                    value: temperature,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: temperature.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        temperature = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top P', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(topP.toStringAsFixed(2)),
                  Slider(
                    value: topP,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: topP.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        topP = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top K', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(topK.toStringAsFixed(2)), // Show as a string with two decimals
                  Slider(
                    value: topK,
                    min: 1.0,
                    max: 100.0,
                    divisions: 10,
                    label: topK.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        topK = value; // No need to cast to int
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Max Output Tokens', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(maxOutputTokens.toString()),
                  Slider(
                    value: maxOutputTokens.toDouble(),
                    min: 1.0,
                    max: 2048.0,
                    divisions: 20,
                    label: maxOutputTokens.toString(),
                    onChanged: (value) {
                      setState(() {
                        maxOutputTokens = value.toInt();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
