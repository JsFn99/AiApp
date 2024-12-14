import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:jasser_app/Screens/models/fashion/prediction_result.dart';
import 'package:jasser_app/components/sidebar.dart';

class FashionPredict extends StatefulWidget {
  @override
  _FashionPredictState createState() => _FashionPredictState();
}

class _FashionPredictState extends State<FashionPredict> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage(bool fromCamera) async {
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Navigate to PredictionResult after selecting the image
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionResult(imageFile: _image!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fashion MNIST Prediction", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: const Color(0xFF2661FA),
      ),
      drawer: const Sidebar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display selected image or placeholder
              _image != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.file(
                  _image!,
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                ),
              )
                  : Column(
                children: [
                  Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "No image selected",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Buttons
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
                          horizontal: 20, vertical: 15),
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
                          horizontal: 20, vertical: 15),
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
