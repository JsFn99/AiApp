import 'dart:convert';
import 'package:http/http.dart' as http;

class SentimentService {
  final String apiUrl = 'http://127.0.0.1:8000/sentiment';

  Future<Map<String, dynamic>> getSentiment(String text) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load sentiment analysis');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }
}
