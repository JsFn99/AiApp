import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  bool isDetecting = false;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera controller
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller.initialize();
    setState(() {
      isInitialized = true; // Set isInitialized to true when camera is ready
    });
  }

  // Function to detect objects
  Future<void> _detectObject(Uint8List imageBytes) async {
    if (isDetecting) return;
    setState(() {
      isDetecting = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://<your-server-ip>:8000/predict/'));
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes));
      var response = await request.send();

      if (response.statusCode == 200) {
        var result = await http.Response.fromStream(response);
        print('Detection Results: ${result.body}');
      } else {
        print('Failed to detect objects');
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      isDetecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Center(child: CircularProgressIndicator()); // Show loading until camera is initialized
    }

    return Scaffold(
      appBar: AppBar(title: Text("Live Object Detection")),
      body: Column(
        children: [
          CameraPreview(_controller),
          ElevatedButton(
            onPressed: () async {
              // Capture image and detect objects
              final image = await _controller.takePicture();
              final imageBytes = await image.readAsBytes();
              _detectObject(imageBytes);
            },
            child: Text('Capture and Detect'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
