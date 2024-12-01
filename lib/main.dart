import 'package:flutter/material.dart';
import 'package:jasser_app/Screens/home/home.dart';
import 'package:jasser_app/Screens/login/login.dart';
import 'package:jasser_app/Screens/register/register.dart';



void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ai App',
      home: const HomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },

    );
  }
}
