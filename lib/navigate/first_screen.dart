import 'package:flutter/material.dart';
import 'package:my_first_app/navigate/second_screen.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('First Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Todo List'),
          onPressed: () {
            // Navigate to second screen when tapped!
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ToDoListScreen()),
            );
          },
        ),
      ),
    );
  }
}
