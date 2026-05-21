// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:my_first_app/agrilog/accessdb/access_database.dart';
import 'package:my_first_app/agrilog/accessdb/supabaseservice.dart';
import 'package:my_first_app/util/config.dart';
import 'package:my_first_app/agrilog/model/class.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CayTrongBloc {  
  String loai_nhap = "";
  String nam_nhap = "";
  String loai_cay = "";

  CayTrongBloc(this.loai_cay, [String nam=""]) {
    nam_nhap = nam;
  }

  CayTrongBloc.withParams(this.loai_cay, [String loaiNhap = "", String nam=""]) {
    loai_nhap = loaiNhap;
    nam_nhap = nam;
  }

  Future<List<CayTrongModel>> getNotes([String search=""]) async {
    try{
      await SupabaseService.localToCloud();
      List<CayTrongModel> listLocal = await DBProvider.db.getNotes(loai_cay, search);
      List<CayTrongModel> list= await SupabaseService.getNotes(loai_cay, search);
      list.addAll(listLocal);
      listLocal = const [];
      if(loai_nhap!="") {
        list = List<CayTrongModel>.from(list.where((x)=>x.loainhap == loai_nhap));
      }
      return list;
    }catch(e){
      return const [];
    }
  }

  Future<List<CayTrongModel>> getAlls([String nam=""]) async {
    try{
      await SupabaseService.localToCloud();
      nam_nhap = nam;
      List<CayTrongModel> listLocal = await DBProvider.db.getAllParas(loai_cay, nam_nhap);
      List<CayTrongModel> list= await SupabaseService.getAllParas(loai_cay, nam_nhap);
      list.addAll(listLocal);
      listLocal = const [];
      if(loai_nhap!="") {
        list = List<CayTrongModel>.from(list.where((x)=>x.loainhap == loai_nhap));
      }
      return list;
    }catch(e){
      return const [];
    }
  }

  Future<List<LoiNhuanModel>> getLoiNhuans([String nam=""]) async {
    try{
      await SupabaseService.localToCloud();
      nam_nhap = nam;
      List<LoiNhuanModel> listLocal= await DBProvider.db.loiNhuanParas(loai_cay, nam_nhap);
      List<LoiNhuanModel> list= await SupabaseService.loiNhuanParas(loai_cay, nam_nhap);
      list.addAll(listLocal);
      listLocal = const [];
      return list;
    }catch(e){      
      return const [];   
    }
  }
  
  Future<void> delete(int id) async {
    //await DBProvider.db.delete(id);
    await SupabaseService.delete(id);
  }

  Future<void> insert(CayTrongModel item) async {
    item.thanhtien = item.dongia * item.soluong;
    //await DBProvider.db.insert(item);
    await SupabaseService.insert(item);
  }

  Future<void> update(CayTrongModel item) async {
    item.thanhtien = item.dongia * item.soluong;
    //await DBProvider.db.update(item);
    await SupabaseService.update(item);
  }
  // Hàm "hỏa táng" dữ liệu
  void dispose() {
    loai_nhap = ""; 
    nam_nhap = "";
    loai_cay = "";
  }
}

class ReportBloc {
  String nam_nhap = "";
  ReportBloc([String nam=""]) {
    nam_nhap = nam;
  }
  late ChartReport chart = ChartReport();

  Future<ChartReport> getLoiNhuans([String nam=""]) async {
    try{
      await SupabaseService.localToCloud();
      nam_nhap = nam;
      List<LoiNhuanModel> listCf2= await DBProvider.db.loiNhuanParas(LoaiCay.caphe, nam_nhap);
      List<LoiNhuanModel> listCf= await SupabaseService.loiNhuanParas(LoaiCay.caphe, nam_nhap);
      listCf.addAll(listCf2);
      listCf2 = const [];
      List<ThreeChartData> caphe = List<ThreeChartData>.from(listCf.map((c) => ThreeChartData.fromLoiNhuanModel(c)));
      chart.caphes = (List<ThreeChartData>.from(caphe)..sort((a, b) => b.cycle.compareTo(a.cycle))).take(3).toList()..sort((a, b) => a.cycle.compareTo(b.cycle));
      chart.tonghop = caphe;

      List<LoiNhuanModel> listSr2= await DBProvider.db.loiNhuanParas(LoaiCay.saurieng, nam_nhap);
      List<LoiNhuanModel> listSr= await SupabaseService.loiNhuanParas(LoaiCay.saurieng, nam_nhap);
      listSr.addAll(listSr2);
      listSr2 = const [];
      List<ThreeChartData> saurieng = List<ThreeChartData>.from(listSr.map((c) => ThreeChartData.fromLoiNhuanModel(c)));
      chart.sauriengs = (List<ThreeChartData>.from(saurieng)..sort((a, b) => b.cycle.compareTo(a.cycle))).take(3).toList()..sort((a, b) => a.cycle.compareTo(b.cycle));
      chart.tonghop.addAll(saurieng);

      List<LoiNhuanModel> listK2= await DBProvider.db.loiNhuanParas(LoaiCay.khac, nam_nhap);
      List<LoiNhuanModel> listK= await SupabaseService.loiNhuanParas(LoaiCay.khac, nam_nhap);
      listK.addAll(listK2);
      listK2 = const [];
      List<SaleData> khacs = List<SaleData>.from(listK.map((c) => SaleData.fromLoiNhuanModel(c)));
      chart.chiphis = (List<SaleData>.from(khacs)..sort((a, b) => b.year.compareTo(a.year))).take(3).toList()..sort((a, b) => a.year.compareTo(b.year));

      // Đọc giá trị từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      // Nếu không tìm thấy thì mặc định là 15 phút
      List<String> yrsItems = prefs.getStringList("yrsItem") ?? [];

      List<SelectList> listYear = [SelectList('','3 năm gần nhất')];
      for (var element in yrsItems) {
        listYear.add(SelectList(element,element));
      }
      chart.yrs = listYear;
      return chart;
    }catch(e){
      return ({} as ChartReport);      
    }
  }
    // Hàm "hỏa táng" dữ liệu
  void dispose() {
    nam_nhap = "";
  }
}