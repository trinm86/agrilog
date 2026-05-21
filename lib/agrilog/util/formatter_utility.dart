// ignore: file_names
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class FormatterUtility {
  // 💡 Phương thức tĩnh (static) để tái sử dụng
  static void handleFocusChange(FocusNode focusNode, TextEditingController controller, NumberFormat numberFormat) {
    if (!focusNode.hasFocus) {
      // Lost Focus: Định dạng lại
      final rawValue = controller.text.replaceAll(RegExp(r'[,]'), '');
      if (rawValue.isNotEmpty) {
        final number = double.tryParse(rawValue);
        if (number != null) {
          controller.text = numberFormat.format(number);      
          controller.selection = TextSelection(
            baseOffset: 0, // Bắt đầu từ đầu
            extentOffset: controller.text.length, // Kết thúc ở cuối
          );     
        }
      }
    } else {
      // Has Focus: Xóa định dạng
      final formattedText = controller.text;
      final rawValue = controller.text;//formattedText.replaceAll(RegExp(r'[,]'), '');
      if (rawValue != formattedText) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.text = rawValue;
          controller.selection = TextSelection(
            baseOffset: 0, // Bắt đầu từ đầu
            extentOffset: controller.text.length, // Kết thúc ở cuối
          );
        });
      }else{
      controller.selection = TextSelection(
        baseOffset: 0, // Bắt đầu từ đầu
        extentOffset: controller.text.length, // Kết thúc ở cuối
      );
      }
    }
    
  }
  static Future<void> selectDate(BuildContext context, TextEditingController dateController, DateFormat dateFormat) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dateController.text.isNotEmpty ? DateTime(int.parse(dateController.text.split('/')[2]),int.parse(dateController.text.split('/')[1]),int.parse(dateController.text.split('/')[0])) : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale("vi","VN"),
    );

    if (pickedDate != null) {
      // Cập nhật giá trị trong TextFormField
      dateController.text = dateFormat.format(pickedDate.toLocal());
    }
  }
}