import 'package:flutter/material.dart';
import 'package:my_first_app/navigate/detail_screen.dart';
import 'package:my_first_app/navigate/todo.dart';

class ToDoListScreen extends StatelessWidget {
  const ToDoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Todo List Screen"),
      ),
      body: Center(
        child:   ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(todos[index].title),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(todo: todos[index]),
                  ),
                );
              },
            );
          },
        )
      ),
    );
  }
}
