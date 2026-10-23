import 'package:flutter/material.dart';

import 'text_icon_image.dart';

import 'row_column_demo.dart';

import 'container_padding_demo.dart';

import 'buttons_demo.dart';

import 'textfield_demo.dart';

import 'listview_demo.dart';

import 'stack_demo.dart';

import 'stateful_counter.dart';

import 'responsive_demo.dart';

import 'navigation_demo.dart';

import 'reusable_widgets_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Widgets Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DemoMenu(),
    );
  }
}

class DemoMenu extends StatelessWidget {
  const DemoMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = [
      ('Text, Icon & Image', const TextIconImageDemo()),
      ('Reusable Widgets', const ReusableWidgetsDemo()),
      ('Row & Column', const RowColumnDemo()),
      ('Container & Padding', const ContainerPaddingDemo()),
      ('Buttons', const ButtonsDemo()),
      ('TextField', const TextFieldDemo()),
      ('ListView', const ListViewDemo()),
      ('Stack & Positioned', const StackDemo()),
      ('Stateful Counter', const CounterDemo()),
      ('Responsive Layout', const ResponsiveDemo()),
      ('Navigation', const NavigationDemo()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Widgets Lab')),
      body: ListView.builder(
        itemCount: demos.length,
        itemBuilder: (context, index) {
          final demo = demos[index];

          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(demo.$1),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => demo.$2));
            },
          );
        },
      ),
    );
  }
}
