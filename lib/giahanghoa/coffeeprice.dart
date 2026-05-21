
class CoffeePrice  {
  late String location;
  late String price;
  late String change;
  late String? text;
  late String? ngay;

  CoffeePrice({required this.location, required this.price, required this.change, this.text, this.ngay});

  // Tạo một User từ JSON
  factory CoffeePrice.fromJson(Map<String, dynamic> json) {
    return CoffeePrice(
      location: json['location'],
      price: json['price'],
      change: json['change'],
      text: json['text'],
      ngay: json['ngay'],
    );
  }
}

class AveragePrice  {
  late String date;
  late String price;

  AveragePrice({required this.date, required this.price});

  // Tạo một User từ JSON
  factory AveragePrice.fromJson(Map<String, dynamic> json) {
    return AveragePrice(
      date: json['date'],
      price: json['price'],
    );
  }
}

class CupDienModel  {
  late String tieude;
  late String khuvuc;
  late String thoigian;
  late String lydo;

  CupDienModel({required this.tieude, required this.khuvuc, required this.thoigian, required this.lydo});

  // Tạo một User từ JSON
  factory CupDienModel.fromJson(Map<String, dynamic> json) {
    return CupDienModel(
      tieude: json['tieude'],
      khuvuc: json['khuvuc'],
      thoigian: json['thoigian'],
      lydo: json['lydo'],
    );
  }
}