import 'dart:async';
import 'dart:io';

import 'package:my_first_app/agrilog/model/class.dart';
import 'package:my_first_app/util/config.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  // Biến để giữ instance Database đã mở
  static Database? _database;
  static final DBProvider db = DBProvider();

  Future<void> get updateDatabase async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/${ConfigApp.dbPathTmp}/${ConfigApp.dbName}';
    final Database dbSql = await openDatabase(path, version: ConfigApp.versiondb, onOpen: (db) {});

    // get all record from database main
    List<CayTrongModel> list = await getAlls();

    // get all record from database temporory
    var res = await dbSql.query(ConfigApp.tableNameCloud);
    List<CayTrongModel> listTmp = res.isNotEmpty ? List<CayTrongModel>.from(res.map((c) => CayTrongModel.fromMap(c))) : [];

    // find record not exists in database main
    List<CayTrongModel> newRecord = List<CayTrongModel>.from(listTmp.where((c) => !list.any((x)=>x.ngaynhap == c.ngaynhap && x.tieude == c.tieude && x.dongia == c.dongia && x.soluong == c.soluong && x.loaicay == c.loaicay && x.loainhap == c.loainhap && x.nam==c.nam)));

    insertMultiple(newRecord);
    
    dbSql.close();
  }

  Future<Database> get database async {
    _database = await initDB(); 
    return _database!;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, ConfigApp.dbName);
    bool exists = await databaseExists(path);
    if(exists) {
      final dbSql = await openDatabase(path, version: ConfigApp.versiondb, onOpen: (db) {});
      // check if table exists
      bool isTable = await isTableExists(ConfigApp.tableNameCloud, dbSql);
      if(!isTable){
        await dbSql.execute(createTable());
      }
      return dbSql;
    }else{
      return await openDatabase(path, version: ConfigApp.versiondb, onOpen: (db) {},
          onCreate: (Database db, int version) async {
            await db.execute(createTable());
          });
    }
  }

  Future<int> insert(CayTrongModel item) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM ${ConfigApp.tableNameCloud}");
    Object? id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into ${ConfigApp.tableNameCloud} (id,ngay_nhap,tieu_de,don_gia,so_luong,thanh_tien,loai_cay,loai_nhap,nam)"
        " VALUES (?,?,?,?,?,?,?,?,?)",
        [id, item.ngaynhap, item.tieude, item.dongia, item.soluong, item.thanhtien, item.loaicay, item.loainhap, item.nam]);
    return raw;
  }

  // Hàm CHÈN NHIỀU DÒNG SỬ DỤNG TRANSACTION
  Future<List<int>> insertMultiple(List<CayTrongModel> items) async {
    final db = await database;
    final List<int> insertedIds = [];

    // Bắt đầu Transaction
    await db.transaction((txn) async {
      // 1. TÌM ID TỐI ĐA HIỆN TẠI (CHỈ MỘT LẦN)
      var table = await txn.rawQuery("SELECT MAX(id) as max_id FROM ${ConfigApp.tableNameCloud}");
      int nextId = (table.first["max_id"] as int? ?? 0) + 1;

      // 2. LẶP VÀ CHÈN TỪNG DÒNG
      for (var item in items) {
        // Sử dụng ID tăng dần từ nextId
        var raw = await txn.rawInsert(
          "INSERT Into ${ConfigApp.tableNameCloud} (id,ngay_nhap,tieu_de,don_gia,so_luong,thanh_tien,loai_cay,loai_nhap,nam)"
          " VALUES (?,?,?,?,?,?,?,?,?)",
          [nextId, item.ngaynhap, item.tieude, item.dongia, item.soluong, item.thanhtien, item.loaicay, item.loainhap, item.nam]
        );
        
        insertedIds.add(raw);
        nextId++; // Tăng ID cho lần chèn tiếp theo
      }
    });

    return insertedIds;
  }

  Future<int> update(CayTrongModel item) async {
    final db = await database;
    var res = await db.update(ConfigApp.tableNameCloud, item.toMap(),
        where: "id = ?", whereArgs: [item.id]);
    return res;
  }

  Future<CayTrongModel?>? get(int id) async {
    final db = await database;
    var res = await db.query(ConfigApp.tableNameCloud, where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? CayTrongModel.fromMap(res.first) : null;
  }

  Future<List<CayTrongModel>> getAlls() async {
    final db = await database;
    var res = await db.query(ConfigApp.tableNameCloud);
    List<CayTrongModel> list =
        res.isNotEmpty ? List<CayTrongModel>.from(res.map((c) => CayTrongModel.fromMap(c))) : [];
    return list;
  }

  Future<List<CayTrongModel>> getAllParas(String loaicay, String nam) async {
    final db = await database;
    var res = await db.query(ConfigApp.tableNameCloud, where: "loai_cay = ? AND nam like '%$nam%'", whereArgs: [loaicay], orderBy: "ngay_nhap");
    List<CayTrongModel> list =
        res.isNotEmpty ? List<CayTrongModel>.from(res.map((c) => CayTrongModel.fromMap(c))) : [];
    if (list.isNotEmpty) {
      list.sort((a, b) {
        // Giả sử 'date' là trường DateTime hoặc String có thể so sánh được
        // Nếu 'date' là String (ví dụ: 'YYYY-MM-DD'), compareTo() vẫn hoạt động tốt.
        // Nếu 'date' là DateTime, sử dụng: a.date.compareTo(b.date)
        return a.date!.compareTo(b.date!); 
      });
    }
    return list;
  }

  Future<List<CayTrongModel>> getNotes(String loaicay, String search) async {
    final db = await database;
    var res = await db.query(ConfigApp.tableNameCloud, where: "loai_cay = ? AND (nam like '%$search%' OR tieu_de like '%$search%')", whereArgs: [loaicay], orderBy: "ngay_nhap");
    List<CayTrongModel> list =
        res.isNotEmpty ? List<CayTrongModel>.from(res.map((c) => CayTrongModel.fromMap(c))) : [];
    if (list.isNotEmpty) {
      list.sort((a, b) {
        // Giả sử 'date' là trường DateTime hoặc String có thể so sánh được
        // Nếu 'date' là String (ví dụ: 'YYYY-MM-DD'), compareTo() vẫn hoạt động tốt.
        // Nếu 'date' là DateTime, sử dụng: a.date.compareTo(b.date)
        return a.date!.compareTo(b.date!); 
      });
    }
    return list;
  }

  Future<List<LoiNhuanModel>> loiNhuanParas(String loaicay, String nam) async {
    final db = await database;
    var table = await db.rawQuery("""
        SELECT 
            nam AS nam,
            CAST(SUM(CASE WHEN loai_nhap = '${LoaiNhap.mua}' THEN thanh_tien ELSE 0 END) AS REAL) AS chi_tien,
            CAST(SUM(CASE WHEN loai_nhap = '${LoaiNhap.ban}' THEN thanh_tien ELSE 0 END) AS REAL) AS thu_tien,
            CAST((SUM(CASE WHEN loai_nhap = '${LoaiNhap.ban}' THEN thanh_tien ELSE 0 END) - SUM(CASE WHEN loai_nhap = '${LoaiNhap.mua}' THEN thanh_tien ELSE 0 END)) AS REAL) AS loi_nhuan,
            loai_cay
        FROM 
            ${ConfigApp.tableNameCloud}
        WHERE loai_cay = '$loaicay' AND nam like '%$nam%'
        GROUP BY nam, loai_cay
        ORDER BY nam
        """);
    
    List<LoiNhuanModel> list = List<LoiNhuanModel>.from(table.map((x) => LoiNhuanModel.fromMap(x)));
    for (var i = 0; i < list.length; i++) {
      if(list[i].thutien<=0) list[i].loinhuan=0;
    }
    return list;
  }

  Future<dynamic> delete(int id) async {
    final db = await database;
    return db.delete(ConfigApp.tableNameCloud, where: "id = ?", whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await database;
    db.rawDelete("delete from ${ConfigApp.tableNameCloud}");
  }

  Future<void> deleteAllParas(String loaicay) async {
    final db = await database;
    db.rawDelete("delete from ${ConfigApp.tableNameCloud} WHERE loai_cay= '$loaicay'");
  }

  Future<Object> count() async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT count(1) as id FROM ${ConfigApp.tableNameCloud}");
    Object? id = table.first["id"];
    return id!;
  }

  Future<Object> countParas(String loaicay) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT count(1) as id FROM ${ConfigApp.tableNameCloud} WHERE loai_cay= '$loaicay'");
    Object? id = table.first["id"];
    return id!;
  }

  // how to check table exists or not in sqlite
  Future<bool> isTableExists(String tableName, Database db) async {
    var res = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");
    if(res.isNotEmpty){
      // add field nam
      updateField(tableName,db,'nam');
    }
    return res.isNotEmpty;
  }

  // how to delete table in sqlite
  Future<void> deleteTable(String tableName, Database db) async {
    await db.rawQuery("DROP TABLE IF EXISTS $tableName");
  }
  String createTable(){
    return "CREATE TABLE ${ConfigApp.tableNameCloud} ("
        "id INTEGER PRIMARY KEY,"
        "ngay_nhap TEXT,"
        "tieu_de TEXT,"
        "don_gia REAL,"
        "so_luong REAL,"
        "thanh_tien REAL,"
        "loai_cay TEXT,"
        "loai_nhap TEXT,"
        "nam TEXT"
        ")";
  }

  // --- HÀM ĐÓNG DATABASE (CẦN THIẾT CHO VIỆC GHI ĐÈ) ---
  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null; // Đặt lại về null để biết nó đã đóng
      print("Database connection closed.");
    }
  }

  Future<File> getDatabaseFile() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, ConfigApp.dbName);
    return File(path);
  }

  Future<void> updateField(String tableName, Database db, String field) async {
    if(!(await checkField(tableName,db,'nam'))){
      await db.transaction((txn) async {
        // 1. Thêm cột mới (nếu chưa tồn tại)
        await txn.execute("ALTER TABLE ${ConfigApp.tableNameCloud} ADD COLUMN $field TEXT DEFAULT ''");

        // 2. Cập nhật dữ liệu cho cột vừa thêm
        await db.execute("""
          UPDATE ${ConfigApp.tableNameCloud} 
          SET nam = CASE WHEN nam IS NULL OR nam = '' THEN '' ELSE SUBSTR(ngay_nhap, 7, 4) END
        """, []);
      });
    }
  }

  Future<bool> checkField(String tableName, Database db, String field) async {
    // 1. Kiểm tra danh sách các cột hiện có trong bảng
    List<Map> columns = await db.rawQuery("PRAGMA table_info($tableName)");
    
    // Kiểm tra xem cột 'nam' đã tồn tại trong danh sách hay chưa
    bool columnExists = columns.any((column) => column['name'] == field);
    return columnExists;
  }
}