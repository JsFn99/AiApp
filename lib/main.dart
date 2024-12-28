import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:jasser_app/Screens/home/home.dart';
import 'package:jasser_app/Screens/login/login.dart';
import 'package:jasser_app/Screens/register/register.dart';

import 'Screens/models/chat/chat.dart';
import 'Screens/models/chat/gemini_chat.dart';
import 'Screens/models/fashion/fashion_predict.dart';
import 'Screens/models/fruit/fruits_predict.dart';
import 'Screens/models/sentiment/sentiment_screen.dart';
import 'Screens/models/stock/stock_prediction.dart';
import 'Screens/models/yolo/camera_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI App',
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/fashion': (context) => FashionPredict(),
        '/fruits': (context) => FruitsPredictPage(),
        '/sentiment': (context) => SentimentScreen(),
        '/chat': (context) => ChatPage(),
        '/camera': (context) => CameraScreen(),
        '/stock': (context) => StockPredictionScreen(),
        '/gemini': (context) => GeminiChat(),
      },
    );
  }
}
