import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../components/sidebar.dart';

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatPage> {
  List<Map<String, String>> messages = [];
  TextEditingController queryController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String? errorMessage;
  bool isTyping = false;
  bool isLoadingInitial = true;

  @override
  void initState() {
    super.initState();
    _sendInitialMessage();
  }

  Future<void> _sendInitialMessage() async {
    setState(() {
      isTyping = true;
      isLoadingInitial = true;
    });

    String initialPrompt =
        "You are a compassionate and insightful psychologist. Greet the user warmly and ask them how you can help them today. "
        "Encourage them to share their thoughts and feelings in a safe and understanding space."
        "Keep your responses brief and to the point, and encourage the user to elaborate on their thoughts and feelings."
        "Make sure your responses are psychologically accurate and offer support and guidance when appropriate.";

    try {
      var response = await http.post(
        Uri.parse('http://localhost:11434/api/generate'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"model": "llama3", "prompt": initialPrompt}),
      );

      if (response.statusCode == 200) {
        String responseContent = '';
        for (var line in response.body.split('\n')) {
          if (line.trim().isNotEmpty) {
            try {
              var parsedLine = json.decode(line) as Map<String, dynamic>;
              responseContent += parsedLine['response'];
              if (parsedLine['done'] == true) break;
            } catch (_) {}
          }
        }
        setState(() {
          messages.add({"message": responseContent, "type": "assistant"});
          isTyping = false;
          isLoadingInitial = false;
          _scrollToBottom();
        });
      } else {
        setState(() {
          errorMessage = "API Error: ${response.statusCode}";
          isTyping = false;
          isLoadingInitial = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Connection Error: $e";
        isTyping = false;
        isLoadingInitial = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Psychologist",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 4.0,
        centerTitle: true,
      ),
      drawer: Sidebar(
        email: 'test@gmail.com',
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (isLoadingInitial)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.teal),
                      SizedBox(height: 20),
                      Text(
                        "Loading your psychologist...",
                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && isTyping) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircularProgressIndicator(
                              color: Colors.teal,
                              strokeWidth: 2.0,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Typing...",
                              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      );
                    }

                    bool isUser = messages[index]['type'] == "user";
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.teal[100] : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft: isUser ? Radius.circular(12) : Radius.zero,
                            bottomRight: isUser ? Radius.zero : Radius.circular(12),
                          ),
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: isUser
                            ? Text(
                          messages[index]['message']!,
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                        )
                            : MarkdownBody(
                          data: messages[index]['message']!,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(fontSize: 16, color: Colors.black87),
                            code: TextStyle(
                              color: Colors.teal,
                              fontFamily: 'monospace',
                              fontSize: 14,
                              backgroundColor: Colors.grey[200],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: queryController,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.teal,
                    child: IconButton(
                      onPressed: _handleSendMessage,
                      icon: Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSendMessage() async {
    String query = queryController.text;
    if (query.isNotEmpty) {
      setState(() {
        messages.add({"message": query, "type": "user"});
        errorMessage = null;
        isTyping = true;
      });

      queryController.clear();

      try {
        var response = await http.post(
          //Uri.parse('http://10.0.2.2:11434/api/generate'),
        Uri.parse('http://localhost:11434/api/generate'),
          headers: {"Content-Type": "application/json"},
          body: json.encode({"model": "llama3", "prompt": query}),
        );

        if (response.statusCode == 200) {
          String responseContent = '';
          for (var line in response.body.split('\n')) {
            if (line.trim().isNotEmpty) {
              try {
                var parsedLine = json.decode(line) as Map<String, dynamic>;
                responseContent += parsedLine['response'];
                if (parsedLine['done'] == true) break;
              } catch (_) {}
            }
          }
          setState(() {
            messages.add({"message": responseContent, "type": "assistant"});
            isTyping = false;
            _scrollToBottom();
          });
        } else {
          setState(() {
            errorMessage = "API Error: ${response.statusCode}";
            isTyping = false;
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = "Connection Error: $e";
          isTyping = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent + 100);
      }
    });
  }

}

