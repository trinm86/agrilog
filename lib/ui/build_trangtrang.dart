import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_first_app/giahanghoa/api_service_cf.dart';
import 'package:my_first_app/giahanghoa/coffeeprice.dart';
import 'package:my_first_app/widget/widget_clickable.dart';

class SearchTrangTrang extends StatefulWidget {
  const SearchTrangTrang({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchTrangTrangState createState() => _SearchTrangTrangState();
}

class _SearchTrangTrangState extends State<SearchTrangTrang> {
  static final GlobalKey<FormFieldState<String>> _firstKey = GlobalKey<FormFieldState<String>>();
  late Future<List<CoffeePrice>> futureTrangTrang;
  final ApiPriceService apiService = ApiPriceService();
  late String url = 'https://www.trangtrang.com/';

  @override
  void initState() {
    super.initState();
    futureTrangTrang = apiService.fetchDataTrangTrang('');
  }

  @override
  void dispose() {
    futureTrangTrang = Future.value([]);
    super.dispose();
  }

  void refresh(){
    setState(() {
      futureTrangTrang = apiService.fetchDataTrangTrang(_firstKey.currentState!.value.toString());
    });
  }

  // Future<void> _openLink(String url) async {
  //   url = "$url${_firstKey.currentState!.value.toString()}.html";
  //   final Uri uri = Uri.parse(url);

  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(
  //       uri,
  //       mode: LaunchMode.externalApplication, // Opens in system browser
  //     );
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4,4,0,0), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 300,
                child: TextFormField(
                  key: _firstKey,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.number, // Hiển thị bàn phím số
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Chỉ cho phép số nguyên
                  ],
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'Nhập số điện thoại';
                    }
                    return null;
                  },
                ),
              ),            
              ElevatedButton(
                onPressed: () {
                  // Sử dụng _formKey để truy cập và xác nhận Form
                  if (_firstKey.currentState!.validate()) {
                    refresh();
                    //_printValueKeys();
                  }
                },
                child: const Text('Tìm'),
              ),
            ],
          )
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4,4,0,0), 
            child: ClickableText(
              text: 'Nguồn: trangtrang.com',
              url: "$url${_firstKey.currentState?.value?.toString()}.html",
            )
          ),
        ),
        FutureBuilder<List<CoffeePrice>>(
          future: futureTrangTrang,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // Hiển thị khi đang chờ dữ liệu
            } else if (snapshot.hasError) {
              // ignore: prefer_interpolation_to_compose_strings
              return Center(child: Text('Build: Failed to load data _ ${snapshot.error}')); // Hiển thị khi có lỗi
            } else {
              // Hiển thị danh sách người dùng khi có dữ liệu
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Table(
                        border: TableBorder.all(color: Colors.grey),
                        columnWidths: const {
                          0: FlexColumnWidth(3), // Cột đầu tiên chiếm 2 phần
                          1: FlexColumnWidth(3), // Cột thứ hai chiếm 3 phần
                        },
                        children: [
                          // Dòng tiêu đề
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[200]),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Tiêu đề', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Kết quả', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          // Các dòng dữ liệu
                          ...snapshot.data!.map((user) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user.location),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user.price),
                                )
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ); 
            }
          },
        ),
      ],
    ); 
  }
}

