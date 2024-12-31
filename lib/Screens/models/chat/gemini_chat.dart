import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../components/sidebar.dart';

class GeminiChat extends StatefulWidget {
  const GeminiChat({Key? key}) : super(key: key);

  @override
  _GeminiChatState createState() => _GeminiChatState();
}

class _GeminiChatState extends State<GeminiChat> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [];

  double temperature = 0.25;
  double topP = 0.9;
  double topK = 40.0;
  int maxOutputTokens = 512;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  Future<void> _initializeGemini() async {
    // var apiKey = environment.get('GEMINI_API_KEY');
    var apiKey = 'AIzaSyCKpaedXWlht53mo2EHcu-GBWY7Ym9Z1R8';
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
    _scrollToBottom();

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
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
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
      drawer: const Sidebar(),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF2661FA),
              ),
              child: Text(
                'Parameters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            _buildSlider('Temperature', temperature, 0.0, 1.0, 10, (value) {
              setState(() => temperature = value);
            }),
            _buildSlider('Top P', topP, 0.0, 1.0, 10, (value) {
              setState(() => topP = value);
            }),
            _buildSlider('Top K', topK, 1.0, 100.0, 10, (value) {
              setState(() => topK = value);
            }),
            _buildSlider('Max Output Tokens', maxOutputTokens.toDouble(), 1.0, 2048.0, 20, (value) {
              setState(() => maxOutputTokens = value.toInt());
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message['role'] == 'user' ? Colors.blue : Colors.black12,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: message['role'] == 'user' ? const Radius.circular(12) : Radius.zero,
                        bottomRight: message['role'] == 'user' ? Radius.zero : const Radius.circular(12),
                      ),
                    ),
                    child: message['role'] == 'user'
                        ? Text(
                      message['content']!,
                      style: const TextStyle(color: Colors.white),
                    )
                        : MarkdownBody(
                      data: message['content']!,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(color: Colors.black),
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
                    decoration: InputDecoration(
                      hintText: 'Ask something...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (value) {
                      _sendMessage(value);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
                  },
                  child: const Icon(Icons.send, color: Colors.white),
                  backgroundColor: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String title, double value, double min, double max, int divisions, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value.toStringAsFixed(2)),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
