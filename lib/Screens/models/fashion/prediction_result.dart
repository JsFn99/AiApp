import 'package:flutter/material.dart';
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class PredictionResult extends StatelessWidget {
  final File imageFile;

  PredictionResult({required this.imageFile});

  Future<String> _predictImage(File image) async {
    // Load the TFLite model
    final interpreter = await Interpreter.fromAsset('assets/models/model.tflite');

    // Preprocess the image
    final inputImage = await _preprocessImage(image);

    // Prepare output
    var output = List.filled(10, 0.0).reshape([1, 10]);

    // Run model
    interpreter.run(inputImage, output);

    // Get the predicted class
    int predictedClass = output[0].indexWhere((value) => value == output[0].reduce((a, b) => a > b ? a : b));
    return "Predicted Class: $predictedClass";
  }

  Future<Uint8List> _preprocessImage(File imageFile) async {
    // Load the image as grayscale and resize to 28x28
    final bytes = await imageFile.readAsBytes();
    img.Image image = img.decodeImage(bytes)!;
    img.Image resizedImage = img.copyResize(image, width: 28, height: 28);

    // Convert to grayscale and normalize
    Uint8List grayscale = Uint8List(28 * 28);
    for (int i = 0; i < resizedImage.data.length; i++) {
      grayscale[i] = resizedImage[i] & 0xFF; // Extract grayscale
    }
    return grayscale.buffer.asUint8List();
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
