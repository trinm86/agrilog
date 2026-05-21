import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class GitHubService {
  // Sử dụng Getter như đã bàn để luôn có timestamp mới nhất
  static String get _rawUrl => 
      "https://raw.githubusercontent.com/trinm86/agrilog/refs/heads/main/caytrong.json?t=${DateTime.now().millisecondsSinceEpoch}";

  static Future<List<dynamic>> fetchCayTrong() async {
    try {
      final response = await http.get(Uri.parse(_rawUrl));

      if (response.statusCode == 200) {
        // Giải mã JSON thành List
        return jsonDecode(response.body.replaceAll(RegExp(r'\\n|\n|\r'), '').trim());
      } else {
        throw Exception('Không thể tải dữ liệu: ${response.statusCode}');
      }
    } catch (e) {
      print("Lỗi khi fetch dữ liệu: $e");
      return const [];
    }
  }
}