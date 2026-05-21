# Cấu hình cho AGP 8.x và Kotlin 2.x
-keepattributes Signature,Annotation,EnclosingMethod,InnerClasses
-keep class com.google.zxing.** { *; }
-keep class com.shinow.** { *; }
-keep class com.google.firebase.** { *; }
-keep class io.flutter.plugins.** { *; }

# Bảo vệ các lớp lưu trữ dữ liệu của bồ (nếu có dùng để restoreData)
-keep class com.example.my_first_app.models.** { *; }