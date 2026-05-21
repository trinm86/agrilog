// api_service.dart

// ignore: depend_on_referenced_packages
import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:my_first_app/giahanghoa/coffeeprice.dart';
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' show parse;
// ignore: depend_on_referenced_packages
import 'package:html/dom.dart';

class ApiPriceService {
  static const String apiUrlCoffee = "https://nhabeagri.com/gia-nong-san/gia-ca-phe/";
  static const String apiUrlTieu = "https://giacaphe.com/gia-tieu-hom-nay/";
  //static const String apiUrlDurian = "https://giacaphe.com/gia-sau-rieng-hom-nay/";
  static const String apiUrlDurian = "https://nhabeagri.com/gia-nong-san/gia-sau-rieng-cap-nhat/";
  static const String apiUrlPetro = "https://giacaphe.com/gia-xang-dau/";
  static const String apiUrlRate = "https://giacaphe.com/ty-gia-ngoai-te/";
  static const String apiUrlAvgPrice = "https://giacaphe.com/gia-ca-phe-noi-dia/";

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

  Future<List<CoffeePrice>> fetchDataCoffee() async {
    
    List<CoffeePrice> prices = [];

    final dataCf = await fetch(apiUrlCoffee, "table.gia-ca-phe");

    // Lấy table đầu tiên
    final firstTable = dataCf.isNotEmpty ? dataCf.first : null;

    if (firstTable != null) {
      final th = firstTable.querySelectorAll('thead tr th');

      if (th.isNotEmpty && th[0].text.trim() == "Khu vực") {
        final rows = firstTable.querySelectorAll('tbody tr');

        for (var row in rows) {
          final columns = row.querySelectorAll('td');

          if (columns.length >= 3 && columns[0].text.trim().toLowerCase() != "tây nguyên" && columns[0].text.trim().toLowerCase() != "hồ tiêu") {
            prices.add(CoffeePrice(
              location: columns[0].text.trim(),
              price: columns[1].text.trim().replaceAll("đ", ""),
              change: columns[2].text.trim().replaceAll("đ", ""),
            ));
          }
        }
      }
    }
    if(prices.isNotEmpty){
      final results = await Future.wait([fetch(apiUrlAvgPrice, ".content-area").then((rows) {
          AveragePrice data = AveragePrice(date: '', price: '');      
          if (rows.isNotEmpty) {
            late List<String> titles = rows[0].querySelector(".page-title")!.text.split(' ');
            data.date = "Giá cà phê ngày ${titles[titles.length - 1]}:";
            data.price = rows[0].querySelector('._trung-binh-gia')?.text.replaceAll("đ/kg", " đ/kg") ?? '';
          }
          return "  ${data.date} ${data.price}";
        })
      ]);
      prices[0].ngay = results[0];
    }
    return prices;
  }

  // Future<List<CoffeePrice>> fetchDataDurian() async {
  //   List<CoffeePrice> prices = [];
  //   final rows = await fetch(apiUrlDurian,"#gia-sau-rieng-hom-nay table tbody tr");
  //   if(rows.isNotEmpty){
  //     for (var row in rows) {
  //       final columns = row.querySelectorAll('td');
  //       prices.add(CoffeePrice(
  //         location: columns[0].text.trim(),
  //         price: columns[1].text.trim(),
  //         change: columns[2].text,
  //       ));
  //     }
  //   }
  //   return prices;
  // }

  Future<List<CoffeePrice>> fetchDataDurian() async {
    List<CoffeePrice> prices = [];
    final rows = await fetch(apiUrlDurian, "table.gia-sau-rieng tbody tr");
    if(rows.isNotEmpty){
      for (var row in rows) {
        final columns = row.querySelectorAll('td');
        if (columns.isNotEmpty && columns[0].text.trim().isNotEmpty) {
          prices.add(CoffeePrice(
            location: columns[0].text.trim(),
            price: columns[1].text.trim(),
            change: columns[3].text,
            ngay: columns[5].text,
          ));
        }
      }
    }

    return prices;
  }

  Future<List<CoffeePrice>> fetchDataPetro() async {
    List<CoffeePrice> prices = [];
    final body = await fetch(apiUrlPetro,".content-area");
    if (body.isNotEmpty) {
      final Element? element = body[0].querySelector(".updated strong");
      late String titles = element != null ? element.text : '' ;
      final ngay = "  Lần điều chỉnh: $titles";

      final rows = body[0].querySelectorAll(".table-xangdau tbody tr");
      if(rows.isNotEmpty){
        for (var row in rows) {
          final columns = row.querySelectorAll('td');
          prices.add(CoffeePrice(
            location: columns[0].text.trim(),
            price: columns[1].text.trim(),
            change: columns[2].text.trim(),
            ngay: ngay
          ));
        }
      }
    }
    return prices;
  }

  Future<List<CoffeePrice>> fetchDataTieu() async {
    List<CoffeePrice> prices = [];
    final body = await fetch(apiUrlTieu,".content-area");
    if (body.isNotEmpty) {
        late List<String> titles = body[0].querySelector(".page-title")!.text.split(' ');
        final ngay = "  Giá tiêu ngày ${titles[titles.length - 1]}";

        final rows = body[0].querySelectorAll("#gia-tieu-hom-nay-body table tbody tr");
        if(rows.isNotEmpty){
          for (var row in rows) {
            final columns = row.querySelectorAll('td');
            prices.add(CoffeePrice(
              location: columns[0].text.trim(),
              price: columns[1].text.trim(),
              change: columns[2].text,
              ngay: ngay
            ));
          }
        }
    }
    return prices;
  }

  Future<List<CoffeePrice>> fetchDataRate() async {
    List<CoffeePrice> prices = [];
    final body = await fetch(apiUrlRate,".content-area");
    if (body.isNotEmpty) {
        late List<String> titles = body[0].querySelector("h1")!.text.split(' ');
        final ngay = "  Tỷ giá ngoại tệ ngày ${titles[titles.length - 1]}";

        final rows = body[0].querySelectorAll("table.tygia-table tbody tr");
        if(rows.isNotEmpty){
          for (var row in rows) {
            final columns = row.querySelectorAll('td');
            prices.add(CoffeePrice(
              location: "${columns[0].querySelector('.CurrencyCode')!.text}\n${columns[0].querySelector('.CurrencyName')!.text}",
              price: columns[1].text.trim(),
              change: columns[2].text,
              text: columns[3].text,
              ngay: ngay
            ));
          }
        }
    }
    return prices;
  }

  Future<List<CoffeePrice>> fetchDataTrangTrang(String soDienThoai) async {
    List<CoffeePrice> prices = [];
    if(soDienThoai.isEmpty) {
      return prices;
    }
    final rows = await fetch('https://www.trangtrang.com/$soDienThoai.html',"article .stat");
    if(rows.isNotEmpty){
      for (var row in rows) {
        final columns = row.querySelectorAll('span');
        prices.add(CoffeePrice(
          location: columns[0].text.trim(),
          price: columns[1].text.trim(),
          change: "",
        ));
      }
    }
    return prices;
  }
}
