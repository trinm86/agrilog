import 'package:camera/camera.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_first_app/agrilog/accessdb/supabaseservice.dart';
import 'package:my_first_app/agrilog/util/background_service.dart';
import 'package:my_first_app/agrilog/ui/caphe_thu.dart';
import 'package:my_first_app/agrilog/ui/caphe_chi.dart';
import 'package:my_first_app/agrilog/ui/caphe_loinhuan.dart';
import 'package:my_first_app/agrilog/ui/chatscreen.dart';
import 'package:my_first_app/agrilog/ui/chiphikhac.dart';
import 'package:my_first_app/agrilog/ui/ghichu.dart';
import 'package:my_first_app/agrilog/ui/lichcupdien.dart';
import 'package:my_first_app/agrilog/util/config_background.dart';
import 'package:my_first_app/agrilog/util/numberofcores.dart';
import 'package:my_first_app/util/config.dart';
import 'package:my_first_app/agrilog/ui/homepage.dart';
import 'package:my_first_app/agrilog/ui/quanlydulieu.dart';
import 'package:my_first_app/agrilog/ui/saurieng_thu.dart';
import 'package:my_first_app/agrilog/ui/saurieng_chi.dart';
import 'package:my_first_app/agrilog/ui/saurieng_loinhuan.dart';
import 'package:my_first_app/giahanghoa/main_gia_hang_hoa.dart';
import 'package:my_first_app/util/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  try{
    // 1. Luôn gọi dòng này đầu tiên và duy nhất 1 lần
    WidgetsFlutterBinding.ensureInitialized(); 
    
    // 2. Cấu hình Log cho Release mode
    if (const bool.fromEnvironment('dart.vm.product')) {
      debugPrint = (String? message, {int? wrapWidth}) {};
    }

    // 3. Khởi tạo các dịch vụ nền tảng (Platform Services)
    //await Firebase.initializeApp();
    await Supabase.initialize(
      url: ConfigApp.prjUrl,
      anonKey: ConfigApp.anonPublic,
    );
    print("Supabase OK");

    // 4. Khởi tạo Notification và Camera
    //final cameras = await availableCameras();
    //print("Cameras OK");

    // 5. Các dịch vụ logic chạy ngầm (nên cân nhắc cho vào sau nếu nó quá nặng)
    RunMultiCoreService.runCore();
    print("Multi Core OK");

    // Lưu giá trị config vào bộ nhớ máy trước khi khởi động service
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("backgroundTimerMinutes", ConfigAppBackground.backgroundTimerMinutes);
    await prefs.setInt("fromHrs", ConfigAppBackground.fromHrs);
    await prefs.setInt("toHrs", ConfigAppBackground.toHrs);
    await prefs.setStringList("yrsItem", await SupabaseService.getYears());

    await MyBackgroundService.initializeService();

    // 6. Cuối cùng mới chạy App
    runApp(const MyApp(cameras: []));
  }catch(e){
    debugPrint("Lỗi startup: $e");
    // Chạy app tối giản để thoát khỏi màn hình đen
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text("$e")))));
  }
}

class MyApp extends StatelessWidget {  
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        // Đây là delegate mà Flutter cung cấp
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // Đây là delegate mà bạn tự viết
        AppLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('vi', 'VN'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale!.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      title: 'Agri Log',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: HomeScreen(cameras: cameras),
    );
  }
}
// Chuyển HomeScreen thành StatefulWidget để dùng initState
class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({super.key, required this.cameras});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.orange,
        title: const Text('Biểu đồ chi phí'),        
      ),
      drawer: Drawer(
        shape: Border.all(color: Colors.transparent),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            InkWell(
              onTap: () {
                // Điều hướng sang trang biểu đồ như bồ đã làm
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        toolbarHeight: 50,
                        backgroundColor: Colors.orange,
                        title: const Text("Biểu đồ chi phí"),
                      ),
                      body: const ChartApp(),
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 91, // Tăng nhẹ chiều cao để không gian thoáng hơn
                margin: const EdgeInsets.only(bottom: 8), // Tạo khoảng cách với danh sách bên dưới
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Một Icon biểu đồ màu trắng để người dùng biết click vào đây là xem biểu đồ
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.bar_chart, color: Colors.white, size: 30),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BIỂU ĐỒ CHI PHÍ",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            "Xem thống kê chi tiết",
                            style: TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                  ],
                ),
              ),
            ),
            ExpansionTile
            (
              leading: const Icon(Icons.list),
              title: const Text('Cà phê'),
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 35),
                  leading: const Icon(Icons.receipt),
                  title: const Text('Chi phí'),
                  onTap: () {
                    // Handle about tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CaPheMuaApp(search: CurrentDate.year)),
                    );
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 35),
                  leading: const Icon(Icons.savings),
                  title: const Text('Thu tiền'),
                  onTap: () {
                    // Handle about tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CaPheBanApp(search: CurrentDate.year)),
                    );
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 35),
                  leading: const Icon(Icons.trending_up),
                  title: const Text('Lợi nhuận'),
                  onTap: () {
                    // Handle about tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CaPheTongKetApp(nam_nhap: CurrentDate.year)),
                    );
                  },
                ),
              ]
            ),
            ExpansionTile
            (
              leading: const Icon(Icons.list),
              title: const Text('Sầu riêng'),
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 35),
                  leading: const Icon(Icons.receipt),
                  title: const Text('Chi phí'),
                  onTap: () {
                    // Handle about tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SauRiengMuaApp(search: CurrentDate.year)),
                    );
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 35),
                  leading: const Icon(Icons.savings),
                  title: const Text('Thu tiền'),
                  onTap: () {
                    // Handle about tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SauRiengBanApp(search: CurrentDate.year)),
                    );
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 35),
                  leading: const Icon(Icons.trending_up),
                  title: const Text('Lợi nhuận'),
                  onTap: () {
                    // Handle about tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SauRiengTongKetApp(nam_nhap: CurrentDate.year)),
                    );
                  },
                ),
              ]
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Chi phí khác'),
              onTap: () => {
                // Handle about tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChiPhiKhacApp(search: CurrentDate.year)),
                )
              },
            ),
            ListTile(
              leading: const Icon(Icons.electric_meter),
              title: const Text('Lịch cúp điện'),
              onTap: () => {
                // Handle about tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LichCupDienApp()),
                )
              },
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Ghi chú'),
              onTap: () => {
                // Handle about tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GhiChuApp(search: CurrentDate.year)),
                )
              },
            ),
            ListTile(
              leading: const Icon(Icons.price_change),
              title: const Text('Giá hàng hóa'),
              onTap: () => {
                // Handle about tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GiaHangHoaScreen()),
                )
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('AI Support'),
              onTap: () => {
                // Handle about tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatScreen()),
                )
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Quản lý dữ liệu'),
              onTap: () => {
                // Handle about tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuanLyData()),
                )
              },
            ),
          ],
        ),
      ),
      body:  const Center(
        child: ChartApp()
      ),
    );
  }
}
