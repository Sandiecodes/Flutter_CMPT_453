import 'package:flutter/material.dart';

import 'reusable_widgets_demo.dart';

// Demonstrates ListView.builder using a reusable custom widget.
class ListViewDemo extends StatelessWidget {
  const ListViewDemo({super.key});

  final List<String> _items = const [
    'Learn Flutter',
    'Understand Widgets',
    'Practice Row and Column',
    'Build a User Interface',
    'Learn StatefulWidget',
    'Explore Navigation',
    'Create a Mini Project',
    'Test the Application',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ListView & Reusable Widgets')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InfoCard(
              title: _items[index],
              description: 'Flutter learning task',
              icon: Icons.star,
              color: Colors.indigo,
            ),
          );
        },
      ),
    );
  }
}
