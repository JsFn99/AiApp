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
            //clothes icon
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Fashion Mnist'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.apple_rounded),
            title: const Text('Fruits Classification'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/fruit') {
                Navigator.pushReplacementNamed(context, '/fruit');
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
            leading: const Icon(Icons.smart_toy_outlined),
            title: const Text('Models'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/models') {
                Navigator.pushReplacementNamed(context, '/models');
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
