import 'dart:convert';
import 'dart:io';

import 'package:my_first_app/giahanghoa/api_service_cf.dart';
import 'package:my_first_app/giahanghoa/coffeeprice.dart';
import 'package:my_first_app/util/config.dart';

CayTrongModel cayTrongFromJson(String str) {
  final jsonData = json.decode(str);
  return CayTrongModel.fromMap(jsonData);
}

String cayTrongToJson(CayTrongModel data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class CayTrongModel {
  int? id;
  String ngaynhap;
  String tieude;
  double dongia;
  double soluong;
  double thanhtien;
  String loaicay;
  String loainhap;
  String nam;
  DateTime? date;

  CayTrongModel({
    this.id,
    required this.ngaynhap,
    required this.tieude,
    required this.dongia,
    required this.soluong,
    required this.thanhtien,
    required this.loaicay,
    required this.loainhap,
    required this.nam,
    this.date
  });

  factory CayTrongModel.fromMap(Map<String, dynamic> json) => CayTrongModel(
        id: json["id"],
        ngaynhap: json["ngay_nhap"],
        tieude: json["tieu_de"],
        dongia: json["don_gia"],
        soluong: json["so_luong"],
        thanhtien: json["thanh_tien"],
        loaicay: json["loai_cay"],
        loainhap: json["loai_nhap"],
        nam: json["nam"],
        date: DateTime(int.parse(json["ngay_nhap"].toString().split('/')[2]),int.parse(json["ngay_nhap"].toString().split('/')[1]),int.parse(json["ngay_nhap"].toString().split('/')[0]))
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "ngay_nhap": ngaynhap,
        "tieu_de": tieude,
        "don_gia": dongia,
        "so_luong": soluong,
        "thanh_tien": thanhtien,
        "loai_cay": loaicay,
        "loai_nhap": loainhap,
        "nam": nam,
      };
}

LoiNhuanModel loiNhuanFromJson(String str) {
  final jsonData = json.decode(str);
  return LoiNhuanModel.fromMap(jsonData);
}

String loiNhuanToJson(LoiNhuanModel data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class LoiNhuanModel {
  String nam;
  double chitien;
  double thutien;
  double loinhuan;
  String loaicay;

  LoiNhuanModel({
    required this.nam,
    required this.chitien,
    required this.thutien,
    required this.loinhuan,
    required this.loaicay,
  });

  factory LoiNhuanModel.fromMap(Map<String, dynamic> json) => LoiNhuanModel(
        nam: json["nam"],
        chitien: (json["chi_tien"] ?? 0).toDouble(),
        thutien: (json["thu_tien"] ?? 0).toDouble(),
        loinhuan: (json["loi_nhuan"] ?? 0).toDouble(),
        loaicay: json["loai_cay"],
      );

  Map<String, dynamic> toMap() => {
        "nam": nam,
        "chi_tien": chitien,
        "thu_tien": thutien,
        "loi_nhuan": loinhuan,
        "loai_cay": loaicay,
      };
}

class ThreeChartData {
  final String cycle;
  final String loaicay;
  final String? tencay;
  final double costThu;
  final double costChi;
  final double costLoiNhuan;
  ThreeChartData({required this.cycle, required this.costThu, required this.costChi, required this.costLoiNhuan, required this.loaicay, this.tencay});


  factory ThreeChartData.fromLoiNhuanModel(LoiNhuanModel model) {
    // Ép kiểu 'nam' thành String, 'loi_nhuan' thành double
    // Lưu ý: Đảm bảo LoiNhuanModel.loiNhuan là số (int/double)
    return ThreeChartData(
      cycle: model.nam.toString(), 
      costThu: model.thutien, 
      costChi: model.chitien,
      costLoiNhuan: model.loinhuan,
      loaicay: model.loaicay,
      tencay: model.loaicay == "caphe" ? "Cà phê" : (model.loaicay == "saurieng" ? "Sầu riêng" : "")
    );
  }
}

class SaleData {
  final String year;
  final double sales;
  SaleData({required this.year, required this.sales});

  factory SaleData.fromLoiNhuanModel(LoiNhuanModel model) {
    // Ép kiểu 'nam' thành String, 'loi_nhuan' thành double
    // Lưu ý: Đảm bảo LoiNhuanModel.loiNhuan là số (int/double)
    return SaleData(
      year: model.nam.toString(), 
      sales: model.chitien
    );
  }
}

class ChartReport {
  late List<ThreeChartData> caphes;
  late List<ThreeChartData> sauriengs;
  late List<ThreeChartData> tonghop;
  late List<SaleData> chiphis;
  late List<SelectList> yrs;
  ChartReport();
}

enum MessageSender { user, ai }

class Message {
  final String content;
  final MessageSender sender;
  final bool isTyping;
  final File? imageFile; // Thêm dòng này để lưu file ảnh

  Message({required this.content, required this.sender, required this.isTyping, this.imageFile});
}

class AllMarketData {
  final List<CoffeePrice> durian;
  final List<CoffeePrice> petro;
  final List<CoffeePrice> tieu;
  final List<CoffeePrice> rate;
  final List<CoffeePrice> cafe;

  AllMarketData({required this.durian, required this.petro, required this.tieu, required this.rate, required this.cafe});

  // Hàm này phải nằm ngoài class hoặc là static
  static Future<AllMarketData> loadAllDataWorker(ApiPriceService apiService) async {
    // Gọi tất cả API song song
    final results = await Future.wait([
      apiService.fetchDataDurian(),
      apiService.fetchDataPetro(),
      apiService.fetchDataTieu(),
      apiService.fetchDataRate(),
      apiService.fetchDataCoffee(),
    ]);

    return AllMarketData(
      durian: results[0],
      petro: results[1],
      tieu: results[2],
      rate: results[3],
      cafe: results[4],
    );
  }
}

