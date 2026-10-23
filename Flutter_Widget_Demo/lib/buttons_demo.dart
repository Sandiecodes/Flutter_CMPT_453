//Demonstrates ElevatedButton, TextButton, OutlinedButton, and IconButton.

import 'package:flutter/material.dart';

class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buttons')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ElevatedButton pressed!')),
                  );
                },
                child: const Text('Elevated Button'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('TextButton pressed!')),
                  );
                },
                child: const Text('Text Button'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OutlinedButton pressed!')),
                  );
                },
                child: const Text('Outlined Button'),
              ),
              const SizedBox(height: 12),
              IconButton(
                icon: const Icon(Icons.favorite),
                color: Colors.red,
                iconSize: 36,
                tooltip: 'Favorite',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to favorites!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
