import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../components/sidebar.dart';

class StockPredictionScreen extends StatefulWidget {
  @override
  _StockPredictionScreenState createState() => _StockPredictionScreenState();
}

class _StockPredictionScreenState extends State<StockPredictionScreen> {
  final TextEditingController _stockTickerController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _daysToPredictController = TextEditingController();

  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    _stockTickerController.text = 'AAPL';
    _startDateController.text = '2024-01-01';
    _endDateController.text = DateTime.now().toIso8601String().split('T').first;
    _daysToPredictController.text = '30';
  }

  Future<Uint8List> fetchPredictionImage() async {
    final stockTicker = _stockTickerController.text;
    final startDate = _startDateController.text;
    final endDate = _endDateController.text;
    final daysToPredict = int.parse(_daysToPredictController.text);

    final response = await http.post(
      Uri.parse('http://localhost:8000/predict/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'stock_ticker': stockTicker,
        'start_date': startDate,
        'end_date': endDate,
        'days_to_predict': daysToPredict,
      }),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes; // Returning the image bytes
    } else {
      throw Exception('Failed to fetch prediction');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stock Price Prediction",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2661FA),
        elevation: 3,
      ),
      drawer: Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Stock Information',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Stock Ticker Input
              _buildTextField(_stockTickerController, 'Stock Ticker (e.g., AAPL)', TextInputType.text),
              const SizedBox(height: 10),

              // Start Date Input
              _buildTextField(_startDateController, 'Start Date (YYYY-MM-DD)', TextInputType.datetime),
              const SizedBox(height: 10),

              // End Date Input
              _buildTextField(_endDateController, 'End Date (YYYY-MM-DD)', TextInputType.datetime),
              const SizedBox(height: 10),

              // Days to Predict Input
              _buildTextField(_daysToPredictController, 'Days to Predict', TextInputType.number),
              const SizedBox(height: 20),

              // Fetch Prediction Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final imageData = await fetchPredictionImage();
                      setState(() {
                        imageBytes = imageData;
                      });
                    } catch (e) {
                      print('Error: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Get Prediction',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Display Prediction Image
              imageBytes != null
                  ? Card(
                elevation: 8,
                shadowColor: Colors.grey.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(
                    imageBytes!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : Center(child: Text('No image', style: TextStyle(fontSize: 18, color: Colors.grey[600]))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, TextInputType inputType) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      ),
      keyboardType: inputType,
    );
  }
}
