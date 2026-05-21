import 'package:google_sign_in/google_sign_in.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;

// Phạm vi (Scopes) BẮT BUỘC để truy cập Drive
const List<String> driveScopes = <String>[
  // Cho phép ứng dụng xem và quản lý các file nó đã tạo.
  'https://www.googleapis.com/auth/drive.file', 
];

// Custom Http Client sử dụng Access Token từ Google Sign-In
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

// Hàm lấy Drive API instance bằng Google Sign-In
Future<drive.DriveApi?> getDriveApiWithGoogleSignIn() async {
  // 1. Cấu hình và Đăng nhập Google
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: driveScopes);
  final GoogleSignInAccount? account = await googleSignIn.signIn();

  if (account == null) {
    // Người dùng hủy đăng nhập
    print("Google Sign-In cancelled.");
    return null;
  }
  
  // 2. Lấy thông tin xác thực (chứa Access Token)
  final GoogleSignInAuthentication auth = await account.authentication;
  
  // 3. Tạo Header Authorization
  // Đây là Access Token OAuth 2.0 mà Drive API mong đợi
  final Map<String, String> authHeaders = {
    'Authorization': 'Bearer ${auth.accessToken}', 
    'X-Requested-With': 'XMLHttpRequest', // Thường được yêu cầu
  };

  // 4. Tạo Http Client và Drive API
  try {
    final httpClient = GoogleAuthClient(authHeaders);
    return drive.DriveApi(httpClient);
  } catch (e) {
    print("Lỗi tạo Drive API client: $e");
    return null;
  }
}