import 'dart:async';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/Inherit/widget_inherited.dart';
import 'package:my_first_app/util/app_localizations.dart';
import 'package:my_first_app/util/lang_key_word.dart';
import 'package:my_first_app/util/string_inherit.dart';

class ColumnWidget extends StatefulWidget {
  const ColumnWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ColumnWidgetState createState() => _ColumnWidgetState();
}

class _ColumnWidgetState extends State<ColumnWidget> {
  late Timer timer;
  late String text = "Pinging...";
  late String content = "Pinging...";
  late Color color = Colors.white;

  Future<void> pingHost(String host) async {
    try {
      final result = await InternetAddress.lookup(host);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          text = 'Ping successful: $host \nDay: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}';   
        });
      }
    } on SocketException catch (_) {
      setState(() {
        text = 'Ping failed: $host';          
      });
    }
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      pingHost('8.8.8.8');
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Dừng Timer sau 5 giây
    Future.delayed(const Duration(seconds: 0), () {
      timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Center(child: Text(AppLocalizations.of(context).translate(LangKeyWord.hello), style: const TextStyle(fontSize: 25))),
        Center(child: Text(AppLocalizations.of(context).translate(LangKeyWord.welcome), style: const TextStyle(fontSize: 25))),
        const SizedBox(height: 10),
        Center(
          child: MyInheritedWidget(content: content, color: color, newChild: const ContentInheritWidget(), fontSize: 25,)
        ),
        Center(
          child: StringInheritedWidget(content: content, child: const TextInheritWidget())
        ),
        const SizedBox(height: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 17),)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            btnClick("red", Colors.red, 25, Colors.white),
            const SizedBox(width: 5),
            btnClick("yellow", const Color.fromARGB(255, 141, 141, 8), 25, Colors.white),
            const SizedBox(width: 5),
            btnClick("green", Colors.green, 25, Colors.white)
          ],
        ),
      ],
    ); 
  }

  ElevatedButton btnClick(String title, Color bgColor, double fontSize, Color fontColor) {
    return ElevatedButton(
        onPressed: (){ 
          print("test console: $title");
          setState(() {
            content = "$title - ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}";
            color = bgColor;
          });
        }, 
        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(bgColor)), 
        child: Text(title, style: TextStyle(color: fontColor, fontSize: fontSize),)
      );
  }
}