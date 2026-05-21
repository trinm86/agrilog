// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_first_app/agrilog/accessdb/lichcupdienservice.dart';
import 'package:my_first_app/agrilog/widget/datarowhelper.dart';
import 'package:my_first_app/agrilog/widget/total_money.dart';
import 'package:my_first_app/giahanghoa/coffeeprice.dart';
import 'package:my_first_app/util/config.dart';

class LichCupDienApp extends StatefulWidget {
  const LichCupDienApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<LichCupDienApp> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  final int numTab = 2;

  final cols = [
    MyColumnConfig<CupDienModel>(valueGetter: (i) => i.khuvuc, align: TextAlign.left),
    MyColumnConfig<CupDienModel>(valueGetter: (i) => i.thoigian, align: TextAlign.left),
    MyColumnConfig<CupDienModel>(valueGetter: (i) => i.lydo, align: TextAlign.left),
  ];
  late Future<List<CupDienModel>> _itemsKh=Future.value([]);
  late Future<List<CupDienModel>> _itemsDv=Future.value([]);

  Future<void> _refreshKh() async {
    setState(() {
      _itemsKh = LichCupDienService().fetchKhachHang();    
    });
  }

   Future<void> _refreshDv() async {
    setState(() {
      _itemsDv = LichCupDienService().fetchDonVi();    
    });
  }

  @override
  void initState() {
    super.initState();
     _tabController = TabController(length: numTab, vsync: this);
    _refreshKh();  
    _refreshDv();
  }

  @override
  void dispose() {    
    _itemsKh = Future.value([]);
    _itemsDv = Future.value([]);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const columnWidths = {
      0: FlexColumnWidth(5.5), 
      1: FlexColumnWidth(2.5), 
      2: FlexColumnWidth(2), 
    };   
    const columnWidthKH = {
      0: FlexColumnWidth(2.5), 
      1: FlexColumnWidth(5), 
      2: FlexColumnWidth(2.5), 
    };   
    return DefaultTabController(
      length: numTab, // Số lượng tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch cúp điện'), 
          backgroundColor: Colors.orange, 
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Mã khách hàng'),
              Tab(text: 'Đơn vị quản lý'),
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
              onRefresh: _refreshKh, // Gọi _refreshData khi kéo xuống
              child: FutureBuilder<List<CupDienModel>>(
                future: _itemsKh,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator()); // Hiển thị khi đang chờ dữ liệu
                  } else if (snapshot.hasError) {
                    // ignore: prefer_interpolation_to_compose_strings
                    return Center(child: Text('Error: ${snapshot.error}')); // Hiển thị khi có lỗi
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data found')); // Hiển thị khi không có dữ liệu
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [ 
                        if(snapshot.data![0].tieude.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: TotalMoneyWidget(content: snapshot.data![0].tieude, fontSize: 17, align: TextAlign.left, alignMent: Alignment.centerLeft,)
                            )
                          ),
                        if (snapshot.data!.isNotEmpty && snapshot.data![0].khuvuc.isNotEmpty)
                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Table(
                                    border: TableBorder.all(color: Colors.grey),
                                    columnWidths: columnWidthKH,
                                    children: [
                                      // Dòng tiêu đề (HEADER)
                                      TableRow(
                                        decoration: BoxDecoration(color: Colors.grey[200]),
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Khách hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Thời gian', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Lý do', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Table(
                                            border: TableBorder.all(color: Colors.grey),
                                            columnWidths: columnWidthKH,
                                            children: [
                                              // Các dòng dữ liệu   
                                              for (int i = 0; i < snapshot.data!.length; i++)
                                                DataRowHelper.buildRow<CupDienModel>(
                                                  context: context,
                                                  item: snapshot.data![i],
                                                  columnsConfig: cols,
                                                  onEdit: null,
                                                  index: i,
                                                  showEdit: false,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                )
                              ],
                            ),
                          )
                      ]
                    );
                  }
                },
              ),
            ),
            RefreshIndicator(
              onRefresh: _refreshDv, // Gọi _refreshData khi kéo xuống
              child: FutureBuilder<List<CupDienModel>>(
                future: _itemsDv,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator()); // Hiển thị khi đang chờ dữ liệu
                  } else if (snapshot.hasError) {
                    // ignore: prefer_interpolation_to_compose_strings
                    return Center(child: Text('Error: ${snapshot.error}')); // Hiển thị khi có lỗi
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data found')); // Hiển thị khi không có dữ liệu
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [ 
                        if(snapshot.data![0].tieude.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: TotalMoneyWidget(content: snapshot.data![0].tieude, fontSize: 17, align: TextAlign.left, alignMent: Alignment.centerLeft)
                            )
                          ),
                        if (snapshot.data!.isNotEmpty)
                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Table(
                                    border: TableBorder.all(color: Colors.grey),
                                    columnWidths: columnWidths,
                                    children: [
                                      // Dòng tiêu đề (HEADER)
                                      TableRow(
                                        decoration: BoxDecoration(color: Colors.grey[200]),
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Khu vực', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Thời gian', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Lý do', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Table(
                                            border: TableBorder.all(color: Colors.grey),
                                            columnWidths: columnWidths,
                                            children: [
                                              // Các dòng dữ liệu   
                                              for (int i = 0; i < snapshot.data!.length; i++)
                                                DataRowHelper.buildRow<CupDienModel>(
                                                  context: context,
                                                  item: snapshot.data![i],
                                                  columnsConfig: cols,
                                                  onEdit: null,
                                                  index: i,
                                                  showEdit: false,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                )
                              ],
                            ),
                          )
                      ]
                    ); 
                  }
                },
              ),
            ),
          ]
        ),  
      ) 
    );
  }
}