import 'package:flutter/material.dart';

// Demo screen showing how to build reusable widgets.
class ReusableWidgetsDemo extends StatelessWidget {
  const ReusableWidgetsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reusable Widgets')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'Reusable Widget Examples',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // Reuse the same custom widget with different values.
          InfoCard(
            title: 'Text Widget',
            description: 'Displays text on the screen.',
            icon: Icons.text_fields,
            color: Colors.blue,
          ),
          SizedBox(height: 12),

          InfoCard(
            title: 'Icon Widget',
            description: 'Displays a built-in Material icon.',
            icon: Icons.star,
            color: Colors.orange,
          ),
          SizedBox(height: 12),

          InfoCard(
            title: 'Image Widget',
            description: 'Displays images in your application.',
            icon: Icons.image,
            color: Colors.green,
          ),
          SizedBox(height: 24),

          Text(
            'Reusable Button',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          ReusableButton(label: 'Click Me', icon: Icons.touch_app),
          SizedBox(height: 12),

          ReusableButton(label: 'Learn More', icon: Icons.school),
        ],
      ),
    );
  }
}

// A reusable card widget.
//
// Pass different titles, descriptions, icons, and colors
// to customize each card.
class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A reusable button widget.
class ReusableButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const ReusableButton({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$label button pressed!')));
      },
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
