import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Card(
            color: Colors.blueGrey[800],
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About'),
              subtitle: Text('version name here'),
            ),
          ),
        ],
      ),
    );
  }
}