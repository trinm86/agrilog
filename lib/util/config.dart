
// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class LoaiCay{
  static const String saurieng = "saurieng";
  static const String caphe = "caphe";
  static const String khac = "khac";
  static const String ghichu = "ghichu";
}
class LoaiNhap{
  static const String mua = "mua";
  static const String ban = "ban";
}
class ReportEnum{
  static const thu = 0;
  static const chi = 1;
  static const tongket = 2;
}

class CurrentDate{
  static String year = (DateTime.now()).year.toString();  
  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
}

class ConfigApp{
  static const String tableNameCloud = "caytrong";
  static const String dbName = "MyDB.db";
  static const String dbPathTmp = "database";
  static const String driveFolder = "Flutter";
  static const int versiondb = 2;
  static const String pwd="DeR2W6Vr5Etj7U?";
  static const String prjId="iwajurvzxwcxtcokohfd";
  static const String prjUrl="https://iwajurvzxwcxtcokohfd.supabase.co";
  static const String anonPublic="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml3YWp1cnZ6eHdjeHRjb2tvaGZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2ODk0NjUsImV4cCI6MjA4MzI2NTQ2NX0.egnstSeANJD1_6mVk-TsrHaqXTZQ3Ed5HKZYU6K-83I";
}

class FormatNum{
  static final integer = NumberFormat('#,##0', "en_US");
  static final decimal = NumberFormat('#,##0.##', "en_US");
  static const int trieu = 1000000;
}

class GeminiAI{
  // ignore: constant_identifier_names
  static const String GEMINI_API_KEY = "AIzaSyDteMFf4iw-1L-5E-wxcpKhrKGnBuFTKcM";
  // ignore: constant_identifier_names
  static const String GEMINI_MODEL = "gemini-2.5-flash";
}

class MyColumnConfig<T> {
  final String Function(T) valueGetter; // Hàm để lấy dữ liệu từ item
  final TextAlign align;
  final bool isBold;

  MyColumnConfig({
    required this.valueGetter,
    this.align = TextAlign.left,
    this.isBold = false,
  });
}

class SelectList {
  String key;
  String value;

  SelectList(this.key, this.value);
}