import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your System')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text('Open Login'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/report-form'),
            child: const Text('Submit a Report'),
          ),
        ],
      ),
    ),
  );
}
