import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:jasser_app/Screens/models/fruit/prediction_result.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../components/sidebar.dart';

class FruitsPredictPage extends StatefulWidget {
  @override
  _FruitPredictionPageState createState() => _FruitPredictionPageState();
}

class _FruitPredictionPageState extends State<FruitsPredictPage> {
  late Interpreter _interpreter;
  final List<String> classes = ['Apple', 'Banana', 'Orange'];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/Fruits.tflite');
      print("Model loaded successfully!");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  bool allowedFile(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png'].contains(ext);
  }

  Future<List<List<List<List<double>>>>?> _loadImage(File image) async {
    img.Image? imageTemp = img.decodeImage(image.readAsBytesSync());
    if (imageTemp == null) return null;

    imageTemp = img.copyResize(imageTemp, width: 32, height: 32);

    List<List<List<List<double>>>> input = List.generate(
      1,
          (_) => List.generate(
        32,
            (y) => List.generate(
          32,
              (x) {
            final pixel = imageTemp?.getPixel(x, y);
            final r = img.getRed(pixel!) * 1.0;
            final g = img.getGreen(pixel) * 1.0;
            final b = img.getBlue(pixel) * 1.0;
            return [r, g, b];
          },
        ),
      ),
    );

    return input;
  }

  Future<String> _predictFruit(File image) async {
    try {
      if (!allowedFile(image.path)) {
        return "Invalid file format. Only JPG, JPEG, and PNG are allowed.";
      }

      List<List<List<List<double>>>>? inputImage = await _loadImage(image);
      if (inputImage == null) {
        return "Error loading image.";
      }

      var output = List.filled(3, 0.0).reshape([1, 3]);
      _interpreter.run(inputImage, output);

      List<double> probabilities = output[0];
      String predictedLabel = classes[probabilities.indexOf(probabilities.reduce((a, b) => a > b ? a : b))];

      return predictedLabel;
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  Future<File?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  void _onImageSelected(File? image) async {
    if (image != null) {
      String prediction = await _predictFruit(image);

      // Navigate to the PredictionResultPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionResultPage(
            prediction: prediction,
            selectedImage: image,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fruit Prediction"),
        backgroundColor: const Color(0xFF2661FA),
      ),
      drawer: Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Upload or Capture an Image",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "Use the options below to select or capture an image to predict the fruit type.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () async {
                    File? image = await _pickImage(ImageSource.gallery);
                    _onImageSelected(image);
                  },
                  child: Column(
                    children: [
                      Icon(Icons.photo, size: 80, color: Colors.blue),
                      const SizedBox(height: 10),
                      const Text(
                        "Gallery",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    File? image = await _pickImage(ImageSource.camera);
                    _onImageSelected(image);
                  },
                  child: Column(
                    children: [
                      Icon(Icons.camera_alt, size: 80, color: Colors.green),
                      const SizedBox(height: 10),
                      const Text(
                        "Camera",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
