import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch the current user's email
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? 'No email found';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/user.png'),
            ),
            decoration: const BoxDecoration(color: Color(0xFF2661FA)),
            accountName: null,
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/home') {
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Fashion Mnist'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/fashion') {
                Navigator.pushReplacementNamed(context, '/fashion');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.apple_rounded),
            title: const Text('Fruits Classification'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/fruits') {
                Navigator.pushReplacementNamed(context, '/fruits');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_graph),
            title: const Text('Stock Prediction'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/stock') {
                Navigator.pushReplacementNamed(context, '/stock');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.sentiment_satisfied_alt),
            title: const Text('Sentiment Analysis'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/sentiment') {
                Navigator.pushReplacementNamed(context, '/sentiment');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.psychology),
            title: const Text('Psychologist'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/chat') {
                Navigator.pushReplacementNamed(context, '/chat');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.computer),
            title: const Text('Gemini 1.5 Chatbot'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/gemini') {
                Navigator.pushReplacementNamed(context, '/gemini');
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
