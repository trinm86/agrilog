import 'package:flutter/material.dart';

class StringInheritedWidget extends InheritedWidget {
  final String content;
  @override
  // ignore: overridden_fields
  final Widget child;
  final Color? color;
  final double? fontSize;
  final bool? fontWeight;

  const StringInheritedWidget({super.key, 
    required this.content,
    required this.child,
    this.color,
    this.fontSize,
    this.fontWeight,
  }):super(child: child);

  @override
  bool updateShouldNotify(StringInheritedWidget oldWidget) {
    return content != oldWidget.content;
  }

  static StringInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StringInheritedWidget>();
  }
}

class TextInheritWidget extends StatelessWidget {
  const TextInheritWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final myInheritedWidget = StringInheritedWidget.of(context);

    if (myInheritedWidget == null) {
      return const Text('MyInheritedWidget was not found');
    }
    final bold = myInheritedWidget.fontWeight ?? false;
    TextStyle style = myInheritedWidget.fontSize == null ? 
      TextStyle(color: myInheritedWidget.color ?? Colors.black, fontWeight: bold ? FontWeight.bold : FontWeight.normal ) : 
      TextStyle(color: myInheritedWidget.color ?? Colors.black, fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: myInheritedWidget.fontSize);
    return Text(myInheritedWidget.content, style: style);
  }
}