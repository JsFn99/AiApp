import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionResponse {
  final String stockTicker;
  final List<String> predictionDates;
  final List<double> predictedPrices;
  final String imagePath;

  PredictionResponse({
    required this.stockTicker,
    required this.predictionDates,
    required this.predictedPrices,
    required this.imagePath,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      stockTicker: json['stock_ticker'],
      predictionDates: List<String>.from(json['prediction_dates']),
      predictedPrices: List<double>.from(json['predicted_prices']),
      imagePath: json['image_path'],
    );
  }
}

Future<PredictionResponse> fetchStockPrediction(
    String ticker, String startDate, String endDate, int daysToPredict) async {
  const String apiUrl = 'http://0.0.0.0:8080/predict/';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'stock_ticker': ticker,
        'start_date': startDate,
        'end_date': endDate,
        'days_to_predict': daysToPredict,
      }),
    );

  if (response.statusCode == 200) {
    return PredictionResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load stock prediction');
  }
}
