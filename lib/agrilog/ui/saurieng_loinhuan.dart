// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:my_first_app/agrilog/widget/datarowhelper.dart';
import 'package:my_first_app/util/config.dart';
import 'package:my_first_app/agrilog/widget/search_refresh_widget.dart';
import 'package:my_first_app/agrilog/widget/total_money.dart';
import 'package:my_first_app/agrilog/model/class.dart';
import 'package:my_first_app/agrilog/accessdb/business_logic.dart';

class SauRiengTongKetApp extends StatefulWidget {
  final String nam_nhap;
  const SauRiengTongKetApp({super.key, required this.nam_nhap});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<SauRiengTongKetApp> {
  final TextEditingController _search = TextEditingController(text: CurrentDate.year);

  late CayTrongBloc bloc;
  late Future<List<LoiNhuanModel>> _itemsFuture;
  final cols = [
    MyColumnConfig<LoiNhuanModel>(valueGetter: (i) => i.nam, align: TextAlign.center),
    MyColumnConfig<LoiNhuanModel>(
      valueGetter: (i) => FormatNum.integer.format(i.thutien),
      align: TextAlign.right,
    ),
    MyColumnConfig<LoiNhuanModel>(
      valueGetter: (i) => FormatNum.integer.format(i.chitien),
      align: TextAlign.right,
    ),
    MyColumnConfig<LoiNhuanModel>(
      valueGetter: (i) => FormatNum.integer.format(i.loinhuan),
      align: TextAlign.right,
    ),
  ];

  void refresh(String search){
    setState(() {
      _search.text = search;
      _itemsFuture = bloc.getLoiNhuans(_search.text);
    });
  }

  @override
  void initState() {
    super.initState();
    _search.text = widget.nam_nhap.isNotEmpty 
                   ? widget.nam_nhap 
                   : CurrentDate.year;
    bloc = CayTrongBloc(LoaiCay.saurieng,_search.text);
    _itemsFuture = bloc.getLoiNhuans(_search.text);
  }

  @override
  void dispose() {  
    _search.dispose();  
    _itemsFuture = Future.value([]);
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: const Text("Tổng kết Sầu riêng"),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<LoiNhuanModel>>(
        future: _itemsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<LoiNhuanModel>> snapshot) {
          if (snapshot.hasData) {
            const columnWidths = {
              0: FlexColumnWidth(1.5), // Cột đầu tiên chiếm 2 phần
              1: FlexColumnWidth(2.75), // Cột đầu tiên chiếm 2 phần
              2: FlexColumnWidth(2.75), // Cột thứ hai chiếm 3 phần
              3: FlexColumnWidth(3), // Cột thứ ba chiếm 4 phần
            };
            if (snapshot.connectionState == ConnectionState.waiting) {                
                return Column(
                  children: [
                    SearchRefreshWidget(
                      labelSearch : "Năm",
                      paraSearch: _search.text,
                      onRefresh: refresh, // Truyền hàm tìm kiếm vào đây
                    ),
                    const Center(child: CircularProgressIndicator())]); // H
              } else if (snapshot.hasError) {
                // ignore: prefer_interpolation_to_compose_strings
                return Column(
                  children: [
                    SearchRefreshWidget(
                      labelSearch : "Năm",
                      paraSearch: _search.text,
                      onRefresh: refresh, // Truyền hàm tìm kiếm vào đây
                    ),
                    const Text('Lỗi khi tải dữ liệu')
                ] ); // H
              } else if (snapshot.data!.isEmpty) {
                return Column(
                  children: [
                    SearchRefreshWidget(
                      labelSearch : "Năm",
                      paraSearch: _search.text,
                      onRefresh: refresh, // Truyền hàm tìm kiếm vào đây
                    ),
                    const Text('Không có dữ liệu.')
                ] ); // Hiển thị khi không có dữ liệu
              } else {
                // Hiển thị danh sách người dùng khi có dữ liệu
                return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [ 
                          SearchRefreshWidget(
                            labelSearch : "Năm",
                            paraSearch: _search.text,
                            onRefresh: refresh, // Truyền hàm tìm kiếm vào đây
                          ),
                          // 💡 1. TIÊU ĐỀ BẢNG (KHÔNG CUỘN)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 0.0, top: 4.0),
                            child: Table(
                              border: TableBorder.all(color: Colors.grey),
                              columnWidths: columnWidths,
                              children: [
                                // Dòng tiêu đề (HEADER)
                                TableRow(
                                  decoration: BoxDecoration(color: Colors.grey[200]),
                                  children: [
                                    const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Năm', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Thu tiền', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Chi tiền', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0, right: 0),
                                  child: TotalMoneyWidget(content: FormatNum.integer.format(snapshot.data!.fold<double>(0, (sum, item) => sum + item.loinhuan)), fontSize: 14),
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
                                    padding: const EdgeInsets.fromLTRB(4,0,4,10),
                                    child: Table(
                                      border: TableBorder.all(color: Colors.grey),
                                      columnWidths: columnWidths,
                                      children: [
                                        // Các dòng dữ liệu   
                                        for (int i = 0; i < snapshot.data!.length; i++)
                                          DataRowHelper.buildRow<LoiNhuanModel>(
                                            context: context,
                                            item: snapshot.data![i],
                                            columnsConfig: cols,
                                            onEdit: null,
                                            showEdit: false,
                                            index:i
                                          ),                                        
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          )
                        ]
                      );  
              }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}