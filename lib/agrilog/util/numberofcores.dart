import 'dart:isolate';
import 'dart:io';
import 'dart:async';

class RunMultiCoreService {
  static const int restTime = 80;
  static const int workTime = 100 - restTime;
  static void runCore() async {
    // Xác định số nhân CPU
    int numberOfCores = (Platform.numberOfProcessors / 2).ceil();
    print("Phát hiện $numberOfCores nhân. Đang khởi động chế độ $workTime% tải...");

    // Kích hoạt từng Isolate trên mỗi nhân
    for (int i = 0; i < numberOfCores; i++) {
      Isolate.spawn(_throttledWork, i);
    }
  }

  // Hàm thực thi trên mỗi core
  static void _throttledWork(int coreId) async {

    while (true) {
      final stopwatch = Stopwatch()..start();

      // 1. Giai đoạn hoạt động (Work) - Chạy vòng lặp rỗng để đốt CPU
      while (stopwatch.elapsedMilliseconds < workTime) {
        // Thực hiện các phép tính toán học liên tục
        double _ = 123.45 * 678.90; 
      }

      stopwatch.stop();

      // 2. Giai đoạn nghỉ (Rest) - Cho phép CPU hạ nhiệt
      await Future.delayed(const Duration(milliseconds: restTime));
    }
  }
}