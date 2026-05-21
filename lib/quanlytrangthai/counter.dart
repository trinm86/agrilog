import 'package:flutter/material.dart';

class Counter with ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // Cập nhật tất cả widget đang sử dụng dữ liệu này
  }
}

class Counter2 with ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment(int count) {
    _count+= count;
    notifyListeners(); // Cập nhật tất cả widget đang sử dụng dữ liệu này
  }
}