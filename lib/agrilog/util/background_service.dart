import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_first_app/agrilog/accessdb/lichcupdienservice.dart';
import 'package:my_first_app/giahanghoa/coffeeprice.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 2. Hàm xử lý chạy ngầm (Nằm ngoài class)
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  late Future<List<CupDienModel>> _itemsKh=Future.value([]);

  String notifyTitle = "Chi tiết lịch cúp điện";
  String notifyBody = "";

  // Lắng nghe lệnh dừng service
  service.on("stop_service").listen((event) {
    service.stopSelf();
  });

  // Đọc giá trị từ SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  // Nếu không tìm thấy thì mặc định là 15 phút
  int minutesConfig = prefs.getInt("backgroundTimerMinutes") ?? 1;
  int fromHrs = prefs.getInt("fromHrs") ?? 8;
  int toHrs = prefs.getInt("toHrs") ?? 10;

  // Chạy định kỳ (Ví dụ: 15 phút một lần)
  Timer.periodic(Duration(minutes: minutesConfig), (timer) async {
    notifyBody = "";
    final now = DateTime.now();
  
    // Chỉ thực hiện logic nặng khi đúng 8:00 sáng 
    print("config ${now.hour}");
    if (now.hour >= fromHrs && now.hour <= toHrs) {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

      _itemsKh = LichCupDienService().fetchKhachHang();
      // "Mở hộp" Future để lấy List thật sự
      List<CupDienModel> danhSach = await _itemsKh;
      if(danhSach.isNotEmpty && danhSach[0].khuvuc.isNotEmpty){
        for(int i=0;i<danhSach.length;i++)
        {
          notifyBody += "${danhSach[i].thoigian} \n\r";
        }
      }

      // 1. Tạo BigTextStyleInformation để chứa nội dung dài
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        notifyBody, // Nội dung đầy đủ khi mở rộng
        htmlFormatBigText: true,
        contentTitle: notifyTitle, // Tiêu đề khi mở rộng
        htmlFormatContentTitle: true,
        summaryText: 'Lịch cúp điện', // Dòng tóm tắt nhỏ phía dưới
        htmlFormatSummaryText: true,
      );

      if(notifyBody.isNotEmpty)
      {
        await flutterLocalNotificationsPlugin.show(
          id: 1001,
          title: notifyTitle,
          body: "",
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'agri_log_service_channel',
              'Agri Log Service',
              icon: '@mipmap/ic_launcher',
              ongoing: false,
              importance: Importance.max,
              priority: Priority.high,        
              playSound: true,    
              // 2. Thêm dòng này vào để kích hoạt hiển thị đầy đủ
              styleInformation: bigTextStyleInformation, 
            ),
          ),
          payload: ""
        );
      }
    }
    
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

class MyBackgroundService {
  // 1. Hàm khởi tạo dịch vụ chạy ngầm
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Cấu hình thông báo cho Foreground Service (Bắt buộc để không bị Android kill)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'agri_log_service_channel', 
      'Agri Log Service',
      description: 'Kênh thông báo cho dịch vụ chạy ngầm',
      importance: Importance.high, // Để low để không làm phiền người dùng quá nhiều
      playSound: true,              // Đảm bảo bật âm thanh
      enableVibration: true,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart, // Hàm thực thi khi chạy ngầm
        autoStart: true,
        isForegroundMode: false,
        notificationChannelId: 'agri_log_service_channel',
        initialNotificationTitle: 'Agri Log đang hoạt động',
        initialNotificationContent: 'Ứng dụng đang chạy ngầm để cập nhật dữ liệu...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }
}