//Demonstrates LayoutBuilder and adapting the layout to different screen widths.

import 'package:flutter/material.dart';

class ResponsiveDemo extends StatelessWidget {
  const ResponsiveDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Layout')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;

          final cards = [
            _buildCard(
              icon: Icons.phone_android,
              title: 'Mobile',
              color: Colors.blue,
            ),
            _buildCard(
              icon: Icons.tablet,
              title: 'Tablet',
              color: Colors.green,
            ),
            _buildCard(
              icon: Icons.desktop_windows,
              title: 'Desktop',
              color: Colors.orange,
            ),
          ];

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cards
                  .map(
                    (card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: card,
                      ),
                    ),
                  )
                  .toList(),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(height: 150, child: card),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Card(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
