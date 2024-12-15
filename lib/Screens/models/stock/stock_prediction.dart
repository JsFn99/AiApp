import 'package:flutter/material.dart';
import 'package:jasser_app/Screens/models/stock/prediction.dart';

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

  late Future<PredictionResponse> futurePrediction;

  @override
  void initState() {
    super.initState();
    // Initialize futurePrediction with a default value (empty response or loading)
    futurePrediction = Future.value(PredictionResponse(
      stockTicker: '',
      predictionDates: [],
      predictedPrices: [],
      imagePath: '',
    ));

    // Set initial text field values
    _stockTickerController.text = 'AAPL';
    _startDateController.text = '2020-01-01';
    _endDateController.text = '2024-01-01';
    _daysToPredictController.text = '30';
  }

  // Method to fetch stock prediction with user input
  Future<void> _fetchPrediction() async {
    final stockTicker = _stockTickerController.text;
    final startDate = _startDateController.text;
    final endDate = _endDateController.text;
    final daysToPredict = int.parse(_daysToPredictController.text);

    setState(() {
      futurePrediction = fetchStockPrediction(stockTicker, startDate, endDate, daysToPredict);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Price Prediction')),
      drawer: Sidebar(),
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

            // Button to fetch prediction
            ElevatedButton(
              onPressed: _fetchPrediction,
              child: Text('Predict Stock Price'),
            ),

            // Display prediction results
            Expanded(
              child: FutureBuilder<PredictionResponse>(
                future: futurePrediction,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final prediction = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Predictions for ${prediction.stockTicker}',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text('Prediction Dates: ${prediction.predictionDates.join(', ')}'),
                        Text('Predicted Prices: ${prediction.predictedPrices.join(', ')}'),
                        Image.network(prediction.imagePath), // Display the saved plot image
                      ],
                    );
                  } else {
                    return Center(child: Text('No data available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
