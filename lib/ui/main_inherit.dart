import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  final bool isLoading;
  final int counter;
  final Widget child;

  const MyHomePage({super.key, 
    required this.isLoading,
    required this.counter,
    required this.child,
  });

  @override
  State<MyHomePage> createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  late bool _isLoading;
  late int _counter;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
    _counter = widget.counter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Inherit"),
      ),
      body: MyInheritedWidget(
        isLoading: _isLoading,
        counter: _counter,
        newChild: widget.child,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onFloatingButtonClicked,
        child: const Text("+", style: TextStyle(fontSize: 30),),
      ),
    );
  }

  void onFloatingButtonClicked() {
    setState(() {
      _counter++;
      if (_counter % 2 == 0) {
        _isLoading = false;
      } else {
        _isLoading = true;
      }
    });
  }
}

class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final myInheritedWidget = MyInheritedWidget.of(context);

    if (myInheritedWidget == null) {
      return const Text('MyInheritedWidget was not found');
    }

    return myInheritedWidget.isLoading
        ? const CircularProgressIndicator()
        : Text('${myInheritedWidget.counter}', style: const TextStyle(fontSize: 30),);
  }
}

class MyCenterWidget extends StatelessWidget {
  const MyCenterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CounterWidget(),
    );
  }
}

class MyInheritedWidget extends InheritedWidget {
  final int counter;
  final bool isLoading;
  final Widget newChild;

  const MyInheritedWidget({super.key, 
    required this.isLoading,
    required this.counter,
    required this.newChild,
  }) : super(child: newChild);

  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) {
    return true;
  }

  static MyInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
  }
}
