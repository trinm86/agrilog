import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocalKey Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LocalKeyExample(),
    );
  }
}

class LocalKeyExample extends StatefulWidget {
  const LocalKeyExample({super.key});

  @override
  State<LocalKeyExample> createState() => _LocalKeyExampleState();
}

class _LocalKeyExampleState extends State<LocalKeyExample> {
  final List<String> items = ['Item 1', 'Item 2', 'Item 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LocalKey Example'), backgroundColor: Colors.orange,),
      body: ListView(
        children: items.map((item) {
          return ListTile(
            key: ValueKey(item), // Sử dụng ValueKey để định danh mỗi phần tử
            title: Text(item),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            items.shuffle(); // Đảo thứ tự các phần tử trong danh sách
          });
        },
        child: const Icon(Icons.shuffle),
      ),
    );
  }
}
