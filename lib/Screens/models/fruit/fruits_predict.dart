import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import '../../../components/sidebar.dart';

class FruitsPredictPage extends StatefulWidget {
  @override
  _FruitsPredictPageState createState() => _FruitsPredictPageState();
}

class _FruitsPredictPageState extends State<FruitsPredictPage> {
  late Interpreter _interpreter;
  File? _imageFile;
  String _predictionResult = "No prediction yet";
  final picker = ImagePicker();

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

  Future<void> _pickImage(bool fromCamera) async {
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _predictImage();
    }
  }

  Future<void> _predictImage() async {
    if (_imageFile == null) return;

    try {
      var imageBytes = await _imageFile!.readAsBytes();
      var image = img.decodeImage(Uint8List.fromList(imageBytes))!;
      var resizedImage = img.copyResize(image, width: 224, height: 224);

      var input = List.generate(224, (i) => List.generate(224, (j) {
        var pixel = resizedImage.getPixel(j, i);
        var r = img.getRed(pixel) / 255.0;
        var g = img.getGreen(pixel) / 255.0;
        var b = img.getBlue(pixel) / 255.0;
        return [r, g, b];
      }));

      var inputTensor = [input.expand((i) => i).toList()];
      var output = List.generate(1, (i) => List.filled(3, 0.0));

      _interpreter.run(inputTensor, output);

      setState(() {
        _predictionResult = output[0].toString();
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionResultPage(prediction: _predictionResult),
        ),
      );
    } catch (e) {
      print("Error running inference: $e");
    }
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Fruit Prediction",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2661FA),
      ),
      drawer: Sidebar(email: 'test@gmail.com',), // Add the Sidebar widget here
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.file(
                  _imageFile!,
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                ),
              )
                  : Column(
                children: const [
                  Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No image selected",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(false),
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: const Text("Gallery", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2661FA),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(true),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text("Camera", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2661FA),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

class PredictionResultPage extends StatelessWidget {
  final String prediction;

  const PredictionResultPage({required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction Result"),
        backgroundColor: const Color(0xFF2661FA),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Prediction Result: $prediction",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
