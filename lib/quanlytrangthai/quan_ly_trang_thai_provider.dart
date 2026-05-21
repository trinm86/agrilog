import 'package:flutter/material.dart';
import 'package:my_first_app/quanlytrangthai/counter_screen.dart';

class MyStateApp extends StatelessWidget {
  const MyStateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CounterScreen(),
    );
  }
}