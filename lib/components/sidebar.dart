import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String email;

  const Sidebar({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("User Name"),
            accountEmail: Text(email),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFF2661FA)),
            ),
            decoration: const BoxDecoration(color: Color(0xFF2661FA)),
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
              if (ModalRoute.of(context)?.settings.name != '/register') {
                Navigator.pushReplacementNamed(context, '/register');
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
            leading: const Icon(Icons.camera_alt),
            title: const Text('Object Detection'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/camera') {
                Navigator.pushReplacementNamed(context, '/camera');
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
