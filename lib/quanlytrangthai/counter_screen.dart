import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'counter.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Số lần nhấn nút:',
            ),
            Consumer<Counter>(
              builder: (context, counter, child) => Text(
                '${counter.count}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Consumer<Counter2>(
              builder: (context, counter, child) => Text(
                '${counter.count}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<Counter>().increment(); // Cập nhật trạng thái
          context.read<Counter2>().increment(context.read<Counter>().count); // Cập nhật trạng thái
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
