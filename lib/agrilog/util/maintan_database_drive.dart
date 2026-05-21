// ignore: file_names
import 'dart:io';
import 'package:my_first_app/agrilog/accessdb/access_database.dart';
import 'package:my_first_app/util/config.dart';
import 'package:my_first_app/agrilog/util/googlesignin.dart';
import 'package:my_first_app/util/toast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:googleapis/drive/v3.dart' as drive;

Future<bool> uploadDatabaseToDrive() async {
  bool res = true;
  final driveApi = await getDriveApiWithGoogleSignIn();
  if (driveApi == null) {
    showToast("Bạn cần đăng nhập để sao lưu.");
    return res;
  }

  const String backupFolderName = ConfigApp.driveFolder;
  const String dbName = ConfigApp.dbName;
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String databasesPath = join(documentsDirectory.path, dbName);

  // 1. Lấy hoặc Tạo ID Thư mục
  final folderId = await getOrCreateFolderId(driveApi, backupFolderName);
  
  if (folderId == null) {
    // Xử lý khi không thể tạo/tìm thấy thư mục
    showToast("Không thể tạo thư mục sao lưu trên Google Drive.");
    return res;
  }

  // 1. Lấy File Database cục bộ
  final databaseFile = File(databasesPath);
  final databaseName = basename(databaseFile.path);

  if (!await databaseFile.exists()) {
    showToast("Không tìm thấy file database cục bộ.");
    return res;
  }

  // 2. Định nghĩa metadata và upload
  final driveFile = drive.File();
  driveFile.name = databaseName;
  driveFile.mimeType = 'application/x-sqlite3';
  driveFile.parents = [folderId];
  
  // (Bạn cần thêm logic kiểm tra file tồn tại để UPDATE thay vì CREATE mới)

  try {
    await driveApi.files.create(
      driveFile,
      uploadMedia: drive.Media(
        databaseFile.openRead(),
        databaseFile.lengthSync(),
      ),
    );
    showToast('Sao lưu thành công lên Google Drive!');
  } catch (e) {
    showToast('Lỗi khi tải file lên Drive: $e');
  }
  return res;
}

Future<bool> restoreDatabaseFromDrive() async {
  bool res = true;
  final driveApi = await getDriveApiWithGoogleSignIn();
  if (driveApi == null) {
    showToast("Bạn cần đăng nhập để phục hồi.");
    return res;
  }
  const String backupFolderName = ConfigApp.driveFolder;
  const String dbName = ConfigApp.dbName;

  // 2. Lấy ID Thư mục Sao lưu
  // Hàm này sẽ tìm ID nếu đã tồn tại hoặc tạo mới nếu chưa có.
  final folderId = await getOrCreateFolderId(driveApi, backupFolderName);
  
  if (folderId == null) {
    showToast("Không tìm thấy hoặc không thể tạo thư mục sao lưu.");
    return res;
  }
  
  //const String databaseName = '$dbName.db';
  // 1. Đóng kết nối hiện tại (RẤT QUAN TRỌNG)
  //await DBProvider().closeDatabase();
  
  // 1. Lấy đường dẫn cục bộ để ghi file
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String localFilePath = join(documentsDirectory.path, dbName);
  
  try {
    // 2. Tìm file trên Drive
    // Tìm kiếm file theo tên và loại bỏ các file đã xóa (trashed = false)
    final searchQuery = "name = '$dbName' and '$folderId' in parents and trashed = false";
    final fileList = await driveApi.files.list(
      q: searchQuery,
      $fields: 'files(id, name, modifiedTime)', // Chỉ yêu cầu các trường cần thiết
    );

    // Lấy file gần nhất (nếu có nhiều file trùng tên)
    final driveFile = fileList.files?.firstWhere(
      (f) => f.name == dbName,
      orElse: () => throw Exception('Không tìm thấy file sao lưu trên Drive.'),
    );

    if (driveFile != null && driveFile.id != null) {
      // 3. Tải nội dung file
      // Yêu cầu download dưới dạng 'fullMedia' để lấy nội dung file
      final media = await driveApi.files.get(
        driveFile.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // 4. Ghi đè file cục bộ
      final file = File(localFilePath);
      final sink = file.openWrite(mode: FileMode.write); // Mở để ghi đè
      
      await media.stream.pipe(sink);
      await sink.close();
      
      //showToast('Phục hồi database thành công!');
      
      // 💡 Lưu ý quan trọng: Sau khi phục hồi, bạn có thể cần 
      // đóng và mở lại database SQLite trong ứng dụng để tải dữ liệu mới.
      // (Ví dụ: await closeDatabase(); await initDatabase();)
      // Mở lại database để ứng dụng sử dụng dữ liệu mới
      // await DBProvider().database;
    } else {
      showToast('Không tìm thấy file sao lưu có tên $dbName.');
    }
  } catch (e) {
    showToast('Lỗi khi phục hồi database từ Drive: $e');
  }
  return res;
}

Future<bool> updateDatabaseFromDrive() async {
  bool res = true;
  final driveApi = await getDriveApiWithGoogleSignIn();
  if (driveApi == null) {
    showToast("Bạn cần đăng nhập để phục hồi.");
    return res;
  }
  const String backupFolderName = ConfigApp.driveFolder;
  const String dbName = ConfigApp.dbName;

  // 2. Lấy ID Thư mục Sao lưu
  // Hàm này sẽ tìm ID nếu đã tồn tại hoặc tạo mới nếu chưa có.
  final folderId = await getOrCreateFolderId(driveApi, backupFolderName);
  
  if (folderId == null) {
    showToast("Không tìm thấy hoặc không thể tạo thư mục sao lưu.");
    return res;
  }
  
  //const String databaseName = '$dbName.db';
  // 1. Đóng kết nối hiện tại (RẤT QUAN TRỌNG)
  await DBProvider().closeDatabase();
  
  // 1. Lấy đường dẫn cục bộ để ghi file
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  final String dbFolderPath = '${documentsDirectory.path}/${ConfigApp.dbPathTmp}';
  final Directory dbFolder = Directory(dbFolderPath);

  // Kiểm tra và tạo thư mục nếu chưa tồn tại
  if (!await dbFolder.exists()) {
    await dbFolder.create(recursive: true);
    print('Đã tạo thư mục: $dbFolderPath');
  }
    
  try {
    // 2. Tìm file trên Drive
    // Tìm kiếm file theo tên và loại bỏ các file đã xóa (trashed = false)
    final searchQuery = "name = '$dbName' and '$folderId' in parents and trashed = false";
    final fileList = await driveApi.files.list(
      q: searchQuery,
      $fields: 'files(id, name, modifiedTime)', // Chỉ yêu cầu các trường cần thiết
    );

    // Lấy file gần nhất (nếu có nhiều file trùng tên)
    final driveFile = fileList.files?.firstWhere(
      (f) => f.name == dbName,
      orElse: () => throw Exception('Không tìm thấy file sao lưu trên Drive.'),
    );

    if (driveFile != null && driveFile.id != null) {
      // 3. Tải nội dung file
      // Yêu cầu download dưới dạng 'fullMedia' để lấy nội dung file
      final media = await driveApi.files.get(
        driveFile.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // 4. Ghi đè file cục bộ của database tạm
      final String targetFilePath = '$dbFolderPath/$dbName';

      final file = File(targetFilePath);
      final sink = file.openWrite(mode: FileMode.write); // Mở để ghi đè
      
      await media.stream.pipe(sink);
      await sink.close();
      
      showToast('Cập nhật dữ liệu mới thành công!');
      
      // 💡 Lưu ý quan trọng: Sau khi phục hồi, bạn có thể cần 
      // đóng và mở lại database SQLite trong ứng dụng để tải dữ liệu mới.
      // (Ví dụ: await closeDatabase(); await initDatabase();)
      // Mở lại database để ứng dụng sử dụng dữ liệu mới
      // await DBProvider().updateDatabase;
    } else {
      showToast('Không tìm thấy file sao lưu có tên $dbName.');
    }
  } catch (e) {
    showToast('Lỗi khi cập nhật dữ liệu mới từ Drive: $e');
  }
  return res;
}

// Thêm hàm này vào file dịch vụ Drive của bạn
Future<String?> getOrCreateFolderId(drive.DriveApi driveApi, String folderName) async {
  // MIME type cho thư mục trên Google Drive
  const mimeTypeFolder = 'application/vnd.google-apps.folder'; 
  
  // 1. TÌM KIẾM: Xem thư mục đã tồn tại chưa
  try {
    final fileList = await driveApi.files.list(
      q: "name = '$folderName' and mimeType = '$mimeTypeFolder' and trashed = false",
      $fields: 'files(id)',
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      // Thư mục đã tồn tại, trả về ID của thư mục đầu tiên tìm thấy
      print("Thư mục đã tồn tại: ${fileList.files!.first.id}");
      return fileList.files!.first.id;
    }
  } catch (e) {
    print("Lỗi khi tìm kiếm thư mục Drive: $e");
    // Tiếp tục sang bước tạo mới nếu lỗi tìm kiếm (trừ lỗi xác thực)
  }

  // 2. TẠO MỚI: Nếu thư mục chưa tồn tại
  try {
    final driveFile = drive.File();
    driveFile.name = folderName;
    driveFile.mimeType = mimeTypeFolder;
    
    // Tạo thư mục (mặc định trong My Drive)
    final folder = await driveApi.files.create(driveFile);
    
    print("Thư mục mới được tạo: ${folder.id}");
    return folder.id;

  } catch (e) {
    print("Lỗi khi tạo thư mục Drive: $e");
    return null; // Không thể tạo thư mục
  }
}

