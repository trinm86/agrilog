import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' show parse;
// ignore: depend_on_referenced_packages
import 'package:html/dom.dart';
import 'package:my_first_app/agrilog/util/stringext.dart';
import 'package:my_first_app/giahanghoa/coffeeprice.dart';

class LichCupDienService {
  static String get _tuNgay => DateFormat('dd-MM-yyyy').format(DateTime.now());
  static String get _denNgay => DateFormat('dd-MM-yyyy').format(DateTime.now().add(const Duration(days: 7)));

  // Sử dụng Getter như đã bàn để luôn có timestamp mới nhất
  static String get _urlKh => 
      "https://www.cskh.evnspc.vn/TraCuu/GetThongTinLichNgungGiamCungCapDien?tuNgay=$_tuNgay&denNgay=$_denNgay&maKH=PB03020045525&ChucNang=MaKhachHang";
  static String get _urlDonVi => "https://www.cskh.evnspc.vn/TraCuu/GetThongTinLichNgungGiamCungCapDien?madvi=PB0302&tuNgay=$_tuNgay&denNgay=$_denNgay&ChucNang=MaDonVi";

  static String where = "span.where";
  static String time = "span.time span";
  static String cause = "span.cause span";

  // ma khach hang
  static String code = "span.code";

  Future<List<Element>> fetch(String url, String selector) async {
    late List<Element> result= List.empty();
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Phân tích cú pháp HTML
      // **Bước mới:** Giải mã bodyBytes thành chuỗi UTF-8
      String utf8Body = utf8.decode(response.bodyBytes);
      result = parse(utf8Body).querySelectorAll(selector);
    }
    return result;
  }

  Future<List<CupDienModel>> fetchData(String url, String type) async {
    List<CupDienModel> obj = [];
    final data = await fetch(url,".notification");
    if(data.isNotEmpty){
      final title = data[0].querySelectorAll('.red')[0].text.trim();
      final rows = data[0].querySelectorAll('.entry');
      for (var row in rows) {        
        final arrTmp = row.querySelector(time)!.text.removeNewLine().split(' ');
        String result = arrTmp.joinNonEmpty(' ');
        obj.add(CupDienModel(
          tieude: "",
          khuvuc: row.querySelector(type)!.text.trim().replaceAll("KHU VỰC:", ""),
          thoigian: result,
          lydo: row.querySelector(cause)!.text.trim(),
        ));
      }
      
      if(obj.isEmpty){
        obj.add(CupDienModel(
          tieude: title,
          khuvuc: "",
          thoigian: "",
          lydo: "",
        ));
      }
    }
    return obj;
  }

  Future<List<CupDienModel>> fetchKhachHang() async {
    return fetchData(_urlKh, code);
  }
  Future<List<CupDienModel>> fetchDonVi() async {
    return fetchData(_urlDonVi, where);
  }
}