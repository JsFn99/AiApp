import 'package:flutter/material.dart';
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class PredictionResult extends StatelessWidget {
  final File imageFile;

  PredictionResult({required this.imageFile});

  Future<String> _predictImage(File image) async {
    // List of class names
    const classNames = [
      'T-shirt/top', 'Trouser', 'Pullover', 'Dress', 'Coat',
      'Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle boot'
    ];

    // Load the TFLite model
    final interpreter = await Interpreter.fromAsset('assets/models/model.tflite');

    // Preprocess the image
    final inputImage = await _preprocessImage(image);

    // Prepare output
    var output = List<double>.filled(10, 0.0).reshape([1, 10]);

    // Run model
    interpreter.run(inputImage, output);

    // Get the predicted class
    List<double> probabilities = output[0].cast<double>(); // Ensure it's List<double>
    int predictedClass = probabilities.indexOf(probabilities.reduce((a, b) => a > b ? a : b));

    // Map the predicted class index to its name
    return "Predicted Class: ${classNames[predictedClass]}";
  }



  Future<List<List<List<List<double>>>>> _preprocessImage(File imageFile) async {
    // Load the image and resize to 28x28
    final bytes = await imageFile.readAsBytes();
    img.Image image = img.decodeImage(bytes)!;
    img.Image resizedImage = img.copyResize(image, width: 28, height: 28);

    // Convert to grayscale and prepare input as 4D list [1, 28, 28, 1]
    List<List<List<List<double>>>> input = List.generate(1, (_) =>
        List.generate(
            28, (_) => List.generate(28, (_) => List.generate(1, (_) => 0.0))));

    for (int y = 0; y < 28; y++) {
      for (int x = 0; x < 28; x++) {
        final pixel = resizedImage.getPixel(x, y);
        final grayscaleValue = img.getLuminance(
            pixel); // Extract grayscale value
        input[0][y][x][0] =
            grayscaleValue.toDouble(); // Keep as raw 0-255 values
      }
    }

    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prediction Result"),
      ),
      body: FutureBuilder(
        future: _predictImage(imageFile),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return Center(child: Text(snapshot.data as String));
          }
        },
      ),
    );
  }
}
