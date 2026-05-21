import 'package:flutter/material.dart';
import 'package:my_first_app/navigate/todo.dart';

class DetailScreen extends StatelessWidget {
  // Declare a field that holds the Todo
  final Todo todo;

  // In the constructor, require a Todo
  const DetailScreen({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    var richText = RichText(
      text: TextSpan(
          children: <TextSpan>[
            const TextSpan(text: "G", style: TextStyle(color: Colors.blue, fontSize: 60, fontWeight: FontWeight.bold,)),
            const TextSpan(text: "o", style: TextStyle(color: Colors.red, fontSize: 60, fontWeight: FontWeight.bold, fontFamily: "DancingScript")),
            const TextSpan(text: "o", style: TextStyle(color: Colors.yellow, fontSize: 60, fontWeight: FontWeight.bold, fontFamily: "DancingScript")),
            const TextSpan(text: "g", style: TextStyle(color: Colors.blue, fontSize: 60, fontWeight: FontWeight.bold,)),
            const TextSpan(text: "l", style: TextStyle(color: Colors.green, fontSize: 60, fontWeight: FontWeight.bold)),
            const TextSpan(text: "e", style: TextStyle(color: Colors.red, fontSize: 60, fontWeight: FontWeight.bold)),
            const TextSpan(text: "\n\n"),
            TextSpan(text: todo.description, style: const TextStyle(color: Colors.black, fontSize: 15)),
          ]
      ));
    // Use the Todo to create our UI
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(todo.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: richText,
          ),
          ElevatedButton(onPressed: (){
            Navigator.pop(context);
          }, child: const Text("Go back!")),
        ],
      )       
    );
  }
}