import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_first_app/ChungThuc/successpage.dart';
// Thêm chính xác dòng này để nhận diện class AuthenticationOptions:
import 'package:local_auth_android/local_auth_android.dart';

class BiometricAuthPage extends StatefulWidget {
  const BiometricAuthPage({super.key});

  @override
  _BiometricAuthPageState createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;
  String _message = "Chưa xác thực";

  /// Kiểm tra thiết bị có hỗ trợ sinh trắc học không
  Future<bool> _checkFingerprintSupport() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      print("Thiết bị có hỗ trợ kiểm tra sinh trắc học: $canCheckBiometrics");
      print("Thiết bị có hỗ trợ tổng thể: $isDeviceSupported");

      if (!isDeviceSupported) {
        setState(() {
          _message = "Thiết bị của bạn không hỗ trợ sinh trắc học.";
        });
        return false;
      }

      if (canCheckBiometrics) {
        List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
        print("Các loại sinh trắc học hỗ trợ: $availableBiometrics");
        
        // Nếu phần cứng hỗ trợ nhưng người dùng chưa cài vân tay/khuôn mặt vào máy
        if (availableBiometrics.isEmpty) {
          setState(() {
            _message = "Thiết bị hỗ trợ nhưng bạn chưa thiết lập vân tay/khuôn mặt trong Cài đặt máy.";
          });
          return false;
        }
      }
      return canCheckBiometrics;
    } catch (e) {
      print("Lỗi khi kiểm tra hỗ trợ sinh trắc học: $e");
      return false;
    }
  }

  /// Thực hiện xác thực sinh trắc học
  Future<void> _authenticate() async {
    try {
      // Đổi sang authenticateWithBiometrics để thay thế hoàn toàn cho biometricOnly cũ
      final bool authenticated = await auth.authenticate(
        localizedReason: 'Xác thực để truy cập ứng dụng',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Xác thực sinh trắc học',
            cancelButton: 'Hủy bỏ',
            //biometricOnly: true, // Thao tác ép buộc CHỈ dùng vân tay/khuôn mặt nằm ở ĐÂY!
          ),
        ],
      );

      // Cập nhật trạng thái UI trước
      setState(() {
        _isAuthenticated = authenticated;
        _message = authenticated ? "Xác thực thành công!" : "Xác thực thất bại.";
      });

      // Kiểm tra xem Widget còn gắn trên cây thư mục (mounted) không trước khi dùng Navigator.push
      if (authenticated && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SuccessPage()),
        );
      }
    } catch (e) {
      print("Lỗi khi xác thực: $e");
      setState(() {
        _message = "Đã xảy ra lỗi khi xác thực.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nên bọc Scaffold ở đây để tạo khung màn hình chuẩn nếu widget này làm màn hình độc lập
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isAuthenticated
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 80),
                    const SizedBox(height: 20),
                    const Text(
                      "Chào mừng bạn!",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isAuthenticated = false;
                          _message = "Chưa xác thực";
                        });
                      },
                      child: const Text("Đăng xuất"),
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _message,
                      style: const TextStyle(fontSize: 20, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        bool isSupported = await _checkFingerprintSupport();
                        print("Hỗ trợ: $isSupported");
                        if (isSupported) {
                          await _authenticate();
                        }
                      },
                      child: const Text("Bắt đầu xác thực"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}