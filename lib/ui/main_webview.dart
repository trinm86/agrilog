import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  final int numTab = 3;
  late final WebViewController? _ctrlVnexpress;
  late final WebViewController? _ctrlBaomoi;
  late final WebViewController? _ctrlCafe;

  @override
  void initState() {
    super.initState();
    // Chạy trên luồng riêng
    _tabController = TabController(length: numTab, vsync: this);
    // Khởi tạo ngay và luôn ở đây
    _ctrlVnexpress = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            print('Đã load xong trang: $url');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://vnexpress.net/')); // Thay bằng link của bồ
    _ctrlBaomoi = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            print('Đã load xong trang: $url');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://baomoi.com/')); // Thay bằng link của bồ
    _ctrlCafe = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            print('Đã load xong trang: $url');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://cafef.vn/')); // Thay bằng link của bồ
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: numTab, // Số lượng tab
      child: Scaffold(
      appBar: AppBar(
        title: const Text("Tin tức online"),
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'VnExpress'),
            Tab(text: 'Báo mới'),
            Tab(text: 'Cafef'),
          ],// Thay đổi màu nền cho tab
          labelColor: Colors.white, // Màu chữ của tab đã chọn
          unselectedLabelColor: Colors.black, // Màu chữ của tab chưa chọn
          // Lắng nghe khi tab thay đổi
          onTap: (index) {
            //_onTabChanged(index);
          },
        )
      ),
      body: TabBarView(
          controller: _tabController,
          children:[ 
            SingleChildScrollView(
              child: Column(
                children: [
                  _ctrlVnexpress == null 
                      ? const CircularProgressIndicator() 
                      : SizedBox(
                          height: 600, // Phải cho nó một con số cụ thể ở đây
                          child: WebViewWidget(controller: _ctrlVnexpress),
                        ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  _ctrlBaomoi == null 
                      ? const CircularProgressIndicator() 
                      : SizedBox(
                          height: 600, // Phải cho nó một con số cụ thể ở đây
                          child: WebViewWidget(controller: _ctrlBaomoi),
                        ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  _ctrlCafe == null 
                      ? const CircularProgressIndicator() 
                      : SizedBox(
                          height: 600, // Phải cho nó một con số cụ thể ở đây
                          child: WebViewWidget(controller: _ctrlCafe),
                        ),
                ],
              ),
            ),
          ]
        ),
      )
    );
  }
}