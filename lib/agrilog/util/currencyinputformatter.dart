import 'package:flutter/services.dart';
import 'package:my_first_app/util/config.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final bool allowDecimal; // 👈 Tham số xác định có cho nhập thập phân không

  CurrencyInputFormatter({this.allowDecimal = false});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 1. Lấy vị trí con trỏ hiện tại
    int selectionIndex = newValue.selection.end;

    // 2. Lọc ký tự rác
    String regexSource = allowDecimal ? r'[^0-9.]' : r'[^0-9]';
    String text = newValue.text.replaceAll(RegExp(regexSource), '');
    
    if (allowDecimal && text.contains('.')) {
      List<String> parts = text.split('.');
      text = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // 3. Định dạng phần nghìn
    List<String> split = text.split('.');
    String integerPart = split[0];
    String decimalPart = split.length > 1 ? split[1] : '';

    if (integerPart.isNotEmpty) {
      integerPart = FormatNum.integer.format(double.parse(integerPart));
    }

    String newText = (allowDecimal && split.length > 1) 
        ? '$integerPart.$decimalPart' 
        : integerPart;
    
    // Tính toán lại vị trí dựa trên sự thay đổi của độ dài văn bản thuần số
    // Cách đơn giản nhất và hiệu quả nhất cho Formatter:
    int newSelectionIndex = selectionIndex + (newText.length - newValue.text.length);

    // Đảm bảo chỉ số không vượt quá độ dài chuỗi
    if (newSelectionIndex < 0) newSelectionIndex = 0;
    if (newSelectionIndex > newText.length) newSelectionIndex = newText.length;

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}