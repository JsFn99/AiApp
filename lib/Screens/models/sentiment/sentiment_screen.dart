import 'package:flutter/material.dart';
import 'package:jasser_app/Screens/models/sentiment/sentiment_service.dart';
import 'package:jasser_app/components/sidebar.dart';  // Make sure the Sidebar is properly imported


class SentimentScreen extends StatefulWidget {
  @override
  _SentimentScreenState createState() => _SentimentScreenState();
}

class _SentimentScreenState extends State<SentimentScreen> {
  TextEditingController _controller = TextEditingController();
  String _result = "";
  Color _resultColor = Colors.grey;
  IconData _resultIcon = Icons.error_outline;
  bool _isLoading = false;

  void _analyzeSentiment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sentiment = await SentimentService().getSentiment(_controller.text);

      String label = sentiment['label'];
      double score = sentiment['score'];
      String formattedScore = score.toStringAsFixed(2);

      setState(() {
        _result = 'Sentiment: $label\nScore: $formattedScore';
        _resultColor = label == 'POSITIVE' ? Colors.green : Colors.red;
        _resultIcon = label == 'POSITIVE' ? Icons.thumb_up : Icons.thumb_down;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _resultColor = Colors.grey;
        _resultIcon = Icons.error_outline;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sentiment Analysis",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2661FA),
      ),
      drawer: const Sidebar(email: 'test@gmail.com'),  // Sidebar added here
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter text for sentiment analysis',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _analyzeSentiment,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Analyze Sentiment", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2661FA),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                children: [
                  Icon(
                    _resultIcon,
                    size: 50,
                    color: _resultColor,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _result,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _resultColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
