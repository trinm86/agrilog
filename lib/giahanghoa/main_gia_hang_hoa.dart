// main.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/agrilog/widget/datarowhelper.dart';
import 'package:my_first_app/agrilog/model/class.dart';
import 'package:my_first_app/giahanghoa/api_service_cf.dart';
import 'package:my_first_app/giahanghoa/coffeeprice.dart';
import 'package:my_first_app/util/config.dart';
import 'package:my_first_app/util/string_inherit.dart';
import 'package:url_launcher/url_launcher.dart';

class GiaHangHoaScreen extends StatefulWidget {
  const GiaHangHoaScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GiaHangHoaScreenState createState() => _GiaHangHoaScreenState();
}

class _GiaHangHoaScreenState extends State<GiaHangHoaScreen> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  late Future<List<CoffeePrice>> futureTieu;
  late Future<List<CoffeePrice>> futureCoffee;
  late Future<List<CoffeePrice>> futureDurian;
  late Future<List<CoffeePrice>> futurePetro;
  late Future<List<CoffeePrice>> futureRate;
  final ApiPriceService apiService = ApiPriceService();
  late Future<AllMarketData> combinedFuture;
  final int numTab = 5;
  
  @override
  void initState() {
    super.initState();
    // Chạy trên luồng riêng
    _tabController = TabController(length: numTab, vsync: this);
    combinedFuture = _fetchAllDataEfficiently();
    // 3. "Trích xuất" các Future con từ Future tổng
    // Cách này giúp bạn có thể dùng FutureBuilder riêng cho từng Tab nếu muốn
    futureDurian = combinedFuture.then((x) => x.durian);
    futurePetro = combinedFuture.then((x) => x.petro);
    futureTieu = combinedFuture.then((x) => x.tieu);
    futureRate = combinedFuture.then((x) => x.rate);
    futureCoffee = combinedFuture.then((x) => x.cafe);
  }

  // Hàm làm mới khi kéo xuống
  Future<void> _refreshDataCf() async {
    setState(() {
      futureCoffee = apiService.fetchDataCoffee();
    });
  }
  // Hàm làm mới khi kéo xuống
  Future<void> _refreshDataDurian() async {
    setState(() {
      futureDurian = apiService.fetchDataDurian();
    });
  }
  // Hàm làm mới khi kéo xuống
  Future<void> _refreshDataP() async {
    setState(() {
      futurePetro = apiService.fetchDataPetro();
    });
  }
  // Hàm làm mới khi kéo xuống
  Future<void> _refreshDataT() async {
     setState(() {
      futureTieu = apiService.fetchDataTieu();
    });
  }

  // Hàm làm mới khi kéo xuống
  Future<void> _refreshDataRate() async {
    setState(() {
      futureRate = apiService.fetchDataRate();
    });
  }

  @override
  void dispose() {
    futureCoffee = Future.value([]);
    futureDurian = Future.value([]);
    futurePetro = Future.value([]);
    futureTieu = Future.value([]);
    futureRate = Future.value([]);
    _tabController.dispose();
    super.dispose();
  }

  Future<AllMarketData> _fetchAllDataEfficiently() async {
    // Sử dụng compute để đẩy việc gộp/parse dữ liệu xuống Background Thread
    return await compute(AllMarketData.loadAllDataWorker, apiService);
  }

  // Hàm này sẽ được gọi khi một tab được nhấn
  // void _onTabChanged(index) {
  //   // Thực hiện hành động khi tab được chọn
    
  //   switch(index){
  //     case 0: refreshCoffee();
  //       break;
  //     case 1: refreshGold();
  //       break;
  //     case 2: refreshPetro();
  //       break;
  //   }
  // }

  // -----------------------------------------------------------------
  // HÀM XỬ LÝ MỞ URL
  // -----------------------------------------------------------------
  Future<void> _launchUrl(String link) async {
    final Uri url = Uri.parse(link);
    // 1. Kiểm tra xem ứng dụng có thể mở URL này không
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // 2. Nếu không mở được, ném ra lỗi hoặc thông báo cho người dùng
      throw Exception('Không thể mở $url');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colsCF = [
      MyColumnConfig<CoffeePrice>(valueGetter: (i) => i.location.replaceAll(RegExp(r'[.]'), ',')),
      MyColumnConfig<CoffeePrice>(
        valueGetter: (i) => i.price.replaceAll(RegExp(r'[.]'), ','),
        align: TextAlign.right,
      ),
      MyColumnConfig<CoffeePrice>(
        valueGetter: (i) => i.change.replaceAll(RegExp(r'[.]'), ','),
        align: TextAlign.right,
      ),
    ];
    final colsDurian = [
      MyColumnConfig<CoffeePrice>(valueGetter: (i) => i.location.replaceAll(RegExp(r'[.]'), ',')),
      MyColumnConfig<CoffeePrice>(
        valueGetter: (i) => i.price.replaceAll(RegExp(r'[.]'), ','),
        align: TextAlign.right,
      ),
      MyColumnConfig<CoffeePrice>(
        valueGetter: (i) => i.change.replaceAll(RegExp(r'[.]'), ','),
        align: TextAlign.right,
      ),
      MyColumnConfig<CoffeePrice>(
        valueGetter: (i) => i.ngay!.replaceAll(RegExp(r'[.]'), ','),
        align: TextAlign.right,
      ),
    ];
    final colsRate = [
      MyColumnConfig<CoffeePrice>(valueGetter: (i) => i.location.replaceAll(RegExp(r'[.]'), ',')),
      MyColumnConfig<CoffeePrice>(
        valueGetter: (i) => i.price.replaceAll(RegExp(r'[.]'), ','),
        align: TextAlign.right,
      ),
      MyColumnConfig<CoffeePrice>(
        valueGetter: (i) => i.change.replaceAll(RegExp(r'[.]'), ','),
        align: TextAlign.right,
      ),
      MyColumnConfig<CoffeePrice>(
        valueGetter: (i) => i.text!.replaceAll(RegExp(r'[.]'), ','),
        align: TextAlign.right,
      ),
    ];
    return DefaultTabController(
      length: numTab, // Số lượng tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Giá hàng hóa'), 
          backgroundColor: Colors.orange, 
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Cà phê'),
              Tab(text: 'Tiêu'),
              Tab(text: 'Tỷ giá'),
              Tab(text: 'Sầu riêng'),
              Tab(text: 'Xăng dầu'),
            ],// Thay đổi màu nền cho tab
            labelColor: Colors.white, // Màu chữ của tab đã chọn
            unselectedLabelColor: Colors.black, // Màu chữ của tab chưa chọn
            // Lắng nghe khi tab thay đổi
            onTap: (index) {
              //_onTabChanged(index);
            },
          ),),
        body:  TabBarView(
          controller: _tabController,
          children: [
            RefreshIndicator(
              onRefresh: _refreshDataCf, // Gọi _refreshData khi kéo xuống
              child: FutureBuilder<List<CoffeePrice>>(
                future: futureCoffee,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator()); // Hiển thị khi đang chờ dữ liệu
                  } else if (snapshot.hasError) {
                    // ignore: prefer_interpolation_to_compose_strings
                    return Center(child: Text('Error: ${snapshot.error}')); // Hiển thị khi có lỗi
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data found')); // Hiển thị khi không có dữ liệu
                  } else {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Table(
                              border: TableBorder.all(color: Colors.grey),
                              columnWidths: const {
                                0: FlexColumnWidth(4), // Cột thứ hai chiếm 3 phần
                                1: FlexColumnWidth(2), // Cột thứ ba chiếm 4 phần
                                2: FlexColumnWidth(2), // Cột thứ ba chiếm 4 phần
                              },
                              children: [
                                // Dòng tiêu đề
                                TableRow(
                                  decoration: BoxDecoration(color: Colors.grey[200]),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Thị trường', style: titleStyle()),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Trung bình', style: titleStyle()),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Thay đổi', style: titleStyle()),
                                      ),
                                    )
                                  ],
                                ),
                                // Các dòng dữ liệu    
                                for (int i = 0; i < snapshot.data!.length; i++)
                                  DataRowHelper.buildRow<CoffeePrice>(
                                    context: context,
                                    item: snapshot.data![i],
                                    columnsConfig: colsCF,
                                    onEdit: null,
                                    showEdit: false,
                                    index:i
                                  ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft, // 💡 Căn trái
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft, 
                                  child: StringInheritedWidget(content: snapshot.data![0].ngay??"", fontSize: 18, child: const TextInheritWidget(),),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft, 
                                  child: Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: TextButton(
                                      onPressed: () => {
                                        _launchUrl(ApiPriceService.apiUrlCoffee)
                                      },
                                      child: const Text('Nguồn thông tin'),
                                    ),
                                  )
                                )
                              ]
                             ),
                          )
                        ],
                      ),
                    ); 
                  }
                },
              ),
            ),
            RefreshIndicator(
              onRefresh: _refreshDataT, // Gọi _refreshData khi kéo xuống
              child: FutureBuilder<List<CoffeePrice>>(
                future: futureTieu,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator()); // Hiển thị khi đang chờ dữ liệu
                  } else if (snapshot.hasError) {
                    // ignore: prefer_interpolation_to_compose_strings
                    return Center(child: Text('Error: ${snapshot.error}')); // Hiển thị khi có lỗi
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data found')); // Hiển thị khi không có dữ liệu
                  } else {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Table(
                              border: TableBorder.all(color: Colors.grey),
                              columnWidths: const {
                                0: FlexColumnWidth(4), // Cột thứ hai chiếm 3 phần
                                1: FlexColumnWidth(2), // Cột thứ ba chiếm 4 phần
                                2: FlexColumnWidth(2), // Cột thứ ba chiếm 4 phần
                              },
                              children: [
                                // Dòng tiêu đề
                                TableRow(
                                  decoration: BoxDecoration(color: Colors.grey[200]),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Khu vực', style: titleStyle()),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Giá mua', style: titleStyle()),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Thay đổi', style: titleStyle()),
                                      ),
                                    )
                                  ],
                                ),
                                // Các dòng dữ liệu  
                                for (int i = 0; i < snapshot.data!.length; i++)
                                  DataRowHelper.buildRow<CoffeePrice>(
                                    context: context,
                                    item: snapshot.data![i],
                                    columnsConfig: colsCF,
                                    onEdit: null,
                                    showEdit: false,
                                    index:i
                                  ),                           
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft, // 💡 Căn trái
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft, 
                                  child: StringInheritedWidget(content: snapshot.data![0].ngay??"", fontSize: 18, child: const TextInheritWidget(),),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft, 
                                  child: Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: TextButton(
                                      onPressed: () => {
                                        _launchUrl(ApiPriceService.apiUrlTieu)
                                      },
                                      child: const Text('Nguồn thông tin'),
                                    ),
                                  )
                                )
                              ]
                             ),
                          )
                        ],
                      ),
                    ); 
                  }
                },
              ),
            ),
            RefreshIndicator(
              onRefresh: _refreshDataRate, // Gọi _refreshData khi kéo xuống
              child: FutureBuilder<List<CoffeePrice>>(
                future: futureRate,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator()); // Hiển thị khi đang chờ dữ liệu
                  } else if (snapshot.hasError) {
                    // ignore: prefer_interpolation_to_compose_strings
                    return Center(child: Text('Error: ${snapshot.error}')); // Hiển thị khi có lỗi
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data found')); // Hiển thị khi không có dữ liệu
                  } else {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Table(
                              border: TableBorder.all(color: Colors.grey),
                              columnWidths: const {
                                0: FlexColumnWidth(3), // Cột thứ hai chiếm 3 phần
                                1: FlexColumnWidth(2), // Cột thứ ba chiếm 4 phần
                                2: FlexColumnWidth(3), // Cột thứ ba chiếm 4 phần
                                3: FlexColumnWidth(2), // Cột thứ ba chiếm 4 phần
                              },
                              children: [
                                // Dòng tiêu đề
                                TableRow(
                                  decoration: BoxDecoration(color: Colors.grey[200]),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Ngoại tệ', style: titleStyle()),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Giá mua', style: titleStyle()),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Chuyển khoản', style: titleStyle()),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Giá bán', style: titleStyle()),
                                      ),
                                    )
                                  ],
                                ),
                                // Các dòng dữ liệu  
                                for (int i = 0; i < snapshot.data!.length; i++)
                                  DataRowHelper.buildRow<CoffeePrice>(
                                    context: context,
                                    item: snapshot.data![i],
                                    columnsConfig: colsRate,
                                    onEdit: null,
                                    showEdit: false,
                                    index:i
                                  ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft, // 💡 Căn trái
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft, 
                                  child: StringInheritedWidget(content: snapshot.data![0].ngay??"", fontSize: 18, child: const TextInheritWidget(),),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft, 
                                  child: Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: TextButton(
                                      onPressed: () => {
                                        _launchUrl(ApiPriceService.apiUrlRate)
                                      },
                                      child: const Text('Nguồn thông tin'),
                                    ),
                                  )
                                )
                              ]
                             ),
                          )
                        ],
                      ),
                    ); 
                  }
                },
              ),
            ),
            RefreshIndicator(
              onRefresh: _refreshDataDurian, // Gọi _refreshData khi kéo xuống
              child: FutureBuilder<List<CoffeePrice>>(
                future: futureDurian,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator()); // Hiển thị khi đang chờ dữ liệu
                  } else if (snapshot.hasError) {
                    // ignore: prefer_interpolation_to_compose_strings
                    return Center(child: Text('Error: ${snapshot.error}')); // Hiển thị khi có lỗi
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data found')); // Hiển thị khi không có dữ liệu
                  } else {
                    return SingleChildScrollView(                    
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Table(
                              border: TableBorder.all(color: Colors.grey),
                              columnWidths: const {
                                0: FlexColumnWidth(3.4), // Cột thứ hai chiếm 3 phần
                                1: FlexColumnWidth(2), // Cột thứ ba chiếm 4 phần
                                2: FlexColumnWidth(2.2), // Cột thứ ba chiếm 4 phần
                                3: FlexColumnWidth(2.4), // Cột thứ ba chiếm 4 phần
                              },
                              children: [
                                // Dòng tiêu đề
                                TableRow(
                                  decoration: BoxDecoration(color: Colors.grey[200]),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Loại sầu riêng', style: titleStyle()),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Miền tây', style: titleStyle()),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Miền đông', style: titleStyle()),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Tây nguyên', style: titleStyle()),
                                      ),
                                    ),
                                  ],
                                ),
                                // Các dòng dữ liệu  
                                for (int i = 0; i < snapshot.data!.length; i++)
                                  DataRowHelper.buildRow<CoffeePrice>(
                                    context: context,
                                    item: snapshot.data![i],
                                    columnsConfig: colsDurian,
                                    onEdit: null,
                                    showEdit: false,
                                    index:i
                                  ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft, // 💡 Căn trái
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: TextButton(
                                onPressed: () => {
                                  _launchUrl(ApiPriceService.apiUrlDurian)
                                },
                                child: const Text('Nguồn thông tin'),
                              ),
                            ),
                          )
                        ],
                      ),
                    ); 
                  }
                },
              ),
            ),
            RefreshIndicator(
              onRefresh: _refreshDataP, // Gọi _refreshData khi kéo xuống
              child: FutureBuilder<List<CoffeePrice>>(
                future: futurePetro,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator()); // Hiển thị khi đang chờ dữ liệu
                  } else if (snapshot.hasError) {
                    // ignore: prefer_interpolation_to_compose_strings
                    return Center(child: Text('Error: ${snapshot.error}')); // Hiển thị khi có lỗi
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data found')); // Hiển thị khi không có dữ liệu
                  } else {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Table(
                              border: TableBorder.all(color: Colors.grey),
                              columnWidths: const {
                                0: FlexColumnWidth(5), // Cột thứ hai chiếm 3 phần
                                1: FlexColumnWidth(2.5), // Cột thứ ba chiếm 4 phần
                                2: FlexColumnWidth(2.5), // Cột thứ ba chiếm 4 phần
                              },
                              children: [
                                // Dòng tiêu đề
                                TableRow(
                                  decoration: BoxDecoration(color: Colors.grey[200]),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Sản phẩm', style: titleStyle()),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Giá', style: titleStyle()),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Thay đổi', style: titleStyle()),
                                      ),
                                    )
                                  ],
                                ),
                                // Các dòng dữ liệu  
                                for (int i = 0; i < snapshot.data!.length; i++)
                                  DataRowHelper.buildRow<CoffeePrice>(
                                    context: context,
                                    item: snapshot.data![i],
                                    columnsConfig: colsCF,
                                    onEdit: null,
                                    showEdit: false,
                                    index:i
                                  ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft, // 💡 Căn trái
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft, 
                                  child: StringInheritedWidget(content: snapshot.data![0].ngay??"", fontSize: 18, child: const TextInheritWidget(),),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft, 
                                  child: Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: TextButton(
                                      onPressed: () => {
                                        _launchUrl(ApiPriceService.apiUrlPetro)
                                      },
                                      child: const Text('Nguồn thông tin'),
                                    ),
                                  )
                                )
                              ]
                             ),
                          )
                        ],
                      ),
                    ); 
                  }
                },
              ),
            )
          ],
        ),        
      )
    );
  }

  TextStyle titleStyle() => const TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
  TextStyle dataStyle() => const TextStyle(fontSize: 15);
}