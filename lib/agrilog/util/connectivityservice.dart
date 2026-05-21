import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_first_app/agrilog/accessdb/supabaseservice.dart';

class ConnectivityService {
  // Biến lưu trạng thái internet để UI lắng nghe
  static ValueNotifier<bool> isOnline = ValueNotifier(true);
  
  static Timer? _timer;

  // Bắt đầu kiểm tra định kỳ
  static void startChecking(int seconds) {
    // Hủy timer cũ nếu có
    _timer?.cancel();

    // Tạo timer mới chạy lặp lại
    _timer = Timer.periodic(Duration(seconds: seconds), (timer) async {
      bool currentStatus = await SupabaseService.hasInternet();
      
      // Chỉ cập nhật nếu trạng thái thay đổi để tiết kiệm hiệu năng
      print("Trạng thái mạng thay đổi: ${currentStatus ? 'Online' : 'Offline'}");
      if (isOnline.value != currentStatus) {
        isOnline.value = currentStatus;
        print("Trạng thái mạng thay đổi: ${currentStatus ? 'Online' : 'Offline'}");
      }
    });
  }

  // Dừng kiểm tra khi không cần thiết (để tránh tốn pin)
  static void stopChecking() {
    _timer?.cancel();
  }
}