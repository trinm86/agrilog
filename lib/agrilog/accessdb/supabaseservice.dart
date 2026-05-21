
import 'dart:async';

import 'package:my_first_app/agrilog/accessdb/access_database.dart';
import 'package:my_first_app/agrilog/accessdb/githubservice.dart';
import 'package:my_first_app/agrilog/model/class.dart';
import 'package:my_first_app/agrilog/util/maintan_database_drive.dart';
import 'package:my_first_app/util/config.dart';
import 'package:my_first_app/util/toast.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
class SupabaseService {
  // 1. Lấy Client của Supabase
  static final  supabase = Supabase.instance.client;

  // Hàm kiểm tra Internet thực tế
  static Future<bool> hasInternet() async {
    try {
      // Thử kết nối tới DNS Google qua cổng 53
      final socket = await Socket.connect('8.8.8.8', 53, 
          timeout: const Duration(milliseconds: 1500));
      socket.destroy(); // Đóng kết nối ngay sau khi thành công
      return true;
    } catch (_) {
      return false;
    }
  }

  // 2. Hàm lấy danh sách dữ liệu (Read)
  static Future<List<String>> getYears() async {
    try {
      if(await hasInternet()){
        final response = await supabase
          .from(ConfigApp.tableNameCloud)
          .select('nam');
        
        if (response.isEmpty) return const [];

        List<String> list = [];
        // Dùng Set để đảm bảo loại bỏ hoàn toàn trùng lặp ở client một lần nữa cho chắc chắn
        // và map thẳng sang List<SelectList>
        final distinctYears = response
            .map((item) => item['nam']?.toString() ?? '')
            .where((nam) => nam.isNotEmpty)
            .toSet(); // Đưa vào Set để tự động loại bỏ năm trùng

        list.addAll(distinctYears
          .map((nam) => nam)
          .toList());

        // Sắp xếp năm tăng dần (hoặc b.key.compareTo(a.key) nếu muốn giảm dần)
        list.sort((a, b) => b.compareTo(a));

        return list;
      }else {
        return const [];
      }
    } catch (e) {
      print("getYears: $e");
      return const []; // Trả về mảng rỗng nếu lỗi
    }    
  }

  // 2. Hàm lấy danh sách dữ liệu (Read)
  static Future<List<CayTrongModel>> getAlls() async {
    try {
      if(await hasInternet()){
        final response = await supabase
          .from(ConfigApp.tableNameCloud)
          .select();
        List<CayTrongModel> list = List<CayTrongModel>.from(response.map((map) => CayTrongModel.fromMap(map)));
        if (list.isNotEmpty) {
          list.sort((a, b) {
            return a.date!.compareTo(b.date!); 
          });
        }
        return list;
      }else {
        return const [];
      }
    } catch (e) {
      print("getAlls: $e");
      return const []; // Trả về mảng rỗng nếu lỗi
    }    
  }

  static Future<List<CayTrongModel>> getNotes(String loaicay, String search) async {
    try {
      if(await hasInternet()){
        final response = await supabase
            .from(ConfigApp.tableNameCloud)
            .select()
            .match({'loai_cay': loaicay})
            //.ilike('nam', '%$search%')
            .or('nam.ilike.%$search%,tieu_de.ilike.%$search%');
        List<CayTrongModel> list = List<CayTrongModel>.from(response.map((map) => CayTrongModel.fromMap(map)));
        if (list.isNotEmpty) {
          list.sort((a, b) {
            return a.date!.compareTo(b.date!); 
          });
        }
        return list;
      }else{
        return const []; 
      }
    } catch (e) {
      print("getNotes: $e");
      return const []; // Trả về mảng rỗng nếu lỗi
    }
  }

  static Future<List<CayTrongModel>> getAllParas(String loaicay, String nam) async {
    try {
      if(await hasInternet()){
        final response = await supabase
            .from(ConfigApp.tableNameCloud)
            .select()
            .match({'loai_cay': loaicay})
            .ilike('nam', '%$nam%');
        List<CayTrongModel> list = List<CayTrongModel>.from(response.map((map) => CayTrongModel.fromMap(map)));
        if (list.isNotEmpty) {
          list.sort((a, b) {
            return a.date!.compareTo(b.date!); 
          });
        }
        return list;
      }else{
        return const []; 
      }
    } catch (e) {
      print("getAllParas: $e");
      return const []; // Trả về mảng rỗng nếu lỗi
    }
  }

  static Future<List<LoiNhuanModel>> loiNhuanParas(String loaicay, String nam) async {
    try{
      if(await hasInternet()){
        // Gọi hàm RPC đã tạo trên Supabase
        final response = await supabase.rpc('get_loi_nhuan', 
          params: {
            'p_loaicay': loaicay, 
            'p_nam': nam
          },
        );

        // response trả về là List<dynamic>, chuyển thành List<LoiNhuanModel>
        final List<dynamic> data = response;
        List<LoiNhuanModel> list = List<LoiNhuanModel>.from(data.map((x) => LoiNhuanModel.fromMap(x)));
        for (var i = 0; i < list.length; i++) {
          if(list[i].thutien<=0) list[i].loinhuan=0;
        }
        return list;
      }else{
        return const [];
      }
    } catch (e) {
      print("loiNhuanParas: $e");
      return const []; // Trả về mảng rỗng nếu lỗi
    }
  }

  // 3. Hàm thêm mới (Create)
  static Future<void> insert(CayTrongModel item) async {
    try {
      if(await hasInternet()){
        await supabase.from(ConfigApp.tableNameCloud).insert({
          'ngay_nhap': item.ngaynhap,
          'tieu_de': item.tieude,
          'don_gia': item.dongia,
          'so_luong': item.soluong,
          'thanh_tien': item.thanhtien,
          'loai_cay': item.loaicay,
          'loai_nhap': item.loainhap,
          'nam': item.nam,
        });   
      }else{
        await DBProvider.db.insert(item);
      }   
    } catch (e) {
      await DBProvider.db.insert(item);
      print("Lỗi insert: $e");
    }
  }

  static Future<void> insertCloud(CayTrongModel item) async {
    try {
      if(await hasInternet()){
        await supabase.from(ConfigApp.tableNameCloud).insert({
          'ngay_nhap': item.ngaynhap,
          'tieu_de': item.tieude,
          'don_gia': item.dongia,
          'so_luong': item.soluong,
          'thanh_tien': item.thanhtien,
          'loai_cay': item.loaicay,
          'loai_nhap': item.loainhap,
          'nam': item.nam,
        });      
        await DBProvider.db.delete(item.id!);
      }
    } catch (e) {
      print("Lỗi insertCloud: $e");
    }
  }

  // 4. Hàm cập nhật (Update)
  static Future<void> update(CayTrongModel item) async {
    try {
      if(await hasInternet()){
        await supabase
          .from(ConfigApp.tableNameCloud)
          .update({
            'ngay_nhap': item.ngaynhap,
            'tieu_de': item.tieude,
            'don_gia': item.dongia,
            'so_luong': item.soluong,
            'thanh_tien': item.thanhtien,
            'loai_cay': item.loaicay,
            'loai_nhap': item.loainhap,
            'nam': item.nam,
          })
          .match({'id': item.id!}); 
      }else{
        await DBProvider.db.update(item);        
      }
    } catch (e) {
      await DBProvider.db.update(item);
      print("Lỗi update: $e");
    }
  }

  // 5. Hàm xóa (Delete)
  static Future<void> delete(int id) async {
    try {
      if(await hasInternet()){
        await supabase.from(ConfigApp.tableNameCloud).delete().match({'id': id});   
      }else{
        await DBProvider.db.delete(id);        
      }   
    } catch (e) {
      await DBProvider.db.delete(id);
      print("Lỗi delete: $e");
    }
  }

  // 6. Hàm select (Select)
  static Future<CayTrongModel?> get(int id) async {
    try{
      if(await hasInternet()){
        final response = await supabase
          .from(ConfigApp.tableNameCloud)
          .select()
          .match({'id': id})
          .single();
        return CayTrongModel.fromMap(response);
      }else{
        return await DBProvider.db.get(id);        
      }
    }catch(e){
      return await DBProvider.db.get(id);
    }
  }

  // Insert Data From Local To Clound
  static Future<void> localToCloud() async {    
    final result = await DBProvider.db.getAlls();
    if(result.isNotEmpty){
      for(var item in result){
        await insertCloud(item);
      }
    }
  }

  static Future<bool> backupDataToLocal() async {
    bool res = false;
    try {
      // 1. Lấy toàn bộ dữ liệu từ Supabase
      final data = await supabase.from(ConfigApp.tableNameCloud).select();

      // 2. Chuyển thành chuỗi JSON
      String jsonContent = jsonEncode(data);

      // 3. Lưu thành file trong bộ nhớ máy
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String databasesPath = join(documentsDirectory.path, ConfigApp.dbName);
      final file = File(databasesPath);
      await file.writeAsString(jsonContent);
      
      print("Đã sao lưu tại: ${file.path}");

      // upload file lên drive
      res = await uploadDatabaseToDrive();
    } catch (e) {
      res = false;
      print("Lỗi restoreDataFromLocal: $e");
    }
    return res;
  }

  static Future<bool> restoreDataFromLocal() async {
    bool res = false;
    try {
      // download file from drive
      await restoreDatabaseFromDrive();

      // restore to cloud
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String databasesPath = join(documentsDirectory.path, ConfigApp.dbName);
      final file = File(databasesPath);

      if (await file.exists()) {
        String content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        if (jsonList.isEmpty) return false;

        // Xóa dữ liệu cũ (Cẩn thận!)
        await supabase.from(ConfigApp.tableNameCloud).delete().neq('id', 0);

        // Đẩy dữ liệu từ file lên lại Supabase
        await supabase.from(ConfigApp.tableNameCloud).insert(jsonList);

        showToast('Phục hồi database thành công!');
        res = true;
      }
    } catch (e) {
      res = false;
      print("Lỗi restoreDataFromLocal: $e");
    }
    return res;
  }

  static Future<bool> restoreDataFromGitHub() async {
    bool res = false;
    try {
      final List<dynamic> jsonList = await GitHubService.fetchCayTrong();
      if (jsonList.isEmpty) return true;

      // Xóa dữ liệu cũ (Cẩn thận!)
      await supabase.from(ConfigApp.tableNameCloud).delete().neq('id', 0);

      // Đẩy dữ liệu từ file lên lại Supabase
      await supabase.from(ConfigApp.tableNameCloud).insert(jsonList);

      showToast('Phục hồi database thành công!');
      res = true;
    } catch (e) {
      res = false;
      print("Lỗi restoreDataFromGitHub: $e");
    }
    return res;
  }
}