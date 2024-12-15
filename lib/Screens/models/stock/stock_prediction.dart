import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' as services;

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
    _startDateController.text = '2020-01-01';
    _endDateController.text = '2024-01-01';
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
      appBar: AppBar(title: Text('Stock Price Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User input fields for stock prediction
            TextField(
              controller: _stockTickerController,
              decoration: InputDecoration(
                labelText: 'Stock Ticker (e.g., AAPL)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _startDateController,
              decoration: InputDecoration(
                labelText: 'Start Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _endDateController,
              decoration: InputDecoration(
                labelText: 'End Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _daysToPredictController,
              decoration: InputDecoration(
                labelText: 'Days to Predict',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),

            // Button to fetch prediction image
            ElevatedButton(
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
              child: Text('Get Prediction'),
            ),

            // Display the prediction image
            imageBytes != null
                ? Image.memory(imageBytes!)
                : Center(child: Text('No image available')),
          ],
        ),
      ),
    );
  }
}