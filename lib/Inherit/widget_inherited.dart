import 'package:flutter/material.dart';

class MyInheritedWidget extends InheritedWidget {
  final String content;
  final Color? color;
  final Widget newChild;
  final double? fontSize;

  const MyInheritedWidget({super.key, 
    required this.content,
    required this.color,
    required this.newChild,
    required this.fontSize,
  }) : super(child: newChild);

  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) {
    return content != oldWidget.content;
  }

  static MyInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
  }
}
// widget cần hiện nội dung, là widget con của MyInheritedWidget 
// MyInheritedWidget(content: content, color: color, newChild: const ContentInheritWidget(), fontSize: null,)
// ContentInheritWidget sẽ rebuild lại nếu nội dung thay đổi
class ContentInheritWidget extends StatelessWidget {
  const ContentInheritWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final myInheritedWidget = MyInheritedWidget.of(context);

    if (myInheritedWidget == null) {
      return const Text('MyInheritedWidget was not found');
    }

    return Text(myInheritedWidget.content, style: TextStyle(color: myInheritedWidget.color ?? Colors.black, fontSize: myInheritedWidget.fontSize ?? 15),);
  }
}