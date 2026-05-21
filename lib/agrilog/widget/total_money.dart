// ignore: file_names
import 'package:flutter/material.dart';

class TotalMoneyWidget extends StatefulWidget {
  // Hàm refresh được truyền từ bên ngoài để thực thi logic tìm kiếm
  final String content;
  final double? fontSize;
  final TextAlign? align;
  final Alignment? alignMent;
  const TotalMoneyWidget({
    super.key, required this.content, this.fontSize, this.align, this.alignMent
  });

  @override
  State<TotalMoneyWidget> createState() => _TotalMoneyWidgetState();
}

class _TotalMoneyWidgetState extends State<TotalMoneyWidget> {

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: widget.alignMent ?? Alignment.centerRight, // 💡 Căn trái
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0,0,4.0,4),
          child: Text(widget.content!='0' ? widget.content : '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: widget.fontSize ?? 14), textAlign: widget.align ?? TextAlign.right, ),
        ),
      );
  }
}