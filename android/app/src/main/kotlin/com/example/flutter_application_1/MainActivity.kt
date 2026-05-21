package com.example.my_first_app

import io.flutter.embedding.android.FlutterFragmentActivity
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Chỉ cần dòng này, Flutter sẽ tự tìm các plugin có trong pubspec.yaml 
        // và nạp chúng vào thông qua file GeneratedPluginRegistrant tự động.
        super.configureFlutterEngine(flutterEngine)
    }
}