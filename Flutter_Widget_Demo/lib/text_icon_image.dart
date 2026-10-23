//Demonstrates Text, Icon, and Image widgets.
import 'package:flutter/material.dart';

class TextIconImageDemo extends StatelessWidget {
  const TextIconImageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text, Icon & Image')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Flutter!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Icon(Icons.flutter_dash, size: 100, color: Colors.blue),
              const SizedBox(height: 20),
              Image.network(
                'https://picsum.photos/300/180',
                width: 300,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 100);
                },
              ),
              const SizedBox(height: 12),
              const Text('Image loaded from the internet'),
            ],
          ),
        ),
      ),
    );
  }
}
