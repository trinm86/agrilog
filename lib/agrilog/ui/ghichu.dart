// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_first_app/agrilog/widget/datarowhelper.dart';
import 'package:my_first_app/agrilog/util/formatter_utility.dart';
import 'package:my_first_app/agrilog/widget/search_refresh_widget.dart';
import 'package:my_first_app/agrilog/model/class.dart';
import 'package:my_first_app/agrilog/accessdb/business_logic.dart';
import 'package:my_first_app/util/config.dart';
import 'package:my_first_app/util/toast.dart';

class GhiChuApp extends StatefulWidget {
  final String search;
  const GhiChuApp({super.key, required this.search});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<GhiChuApp> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final GlobalKey<FormFieldState<String>> ngayNhapKey = GlobalKey<FormFieldState<String>>();
  static final GlobalKey<FormFieldState<String>> tieuDeKey = GlobalKey<FormFieldState<String>>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _search = TextEditingController(text: CurrentDate.year);

  late CayTrongBloc bloc = CayTrongBloc.withParams(LoaiCay.ghichu, LoaiNhap.mua, _search.text);
  final cols = [
    MyColumnConfig<CayTrongModel>(valueGetter: (i) => i.ngaynhap),
    MyColumnConfig<CayTrongModel>(valueGetter: (i) => i.tieude),
    MyColumnConfig<CayTrongModel>(
      valueGetter: (i) => FormatNum.integer.format(i.thanhtien),
      align: TextAlign.right,
    ),
  ];
  final notes = [
    MyColumnConfig<CayTrongModel>(valueGetter: (i) => i.ngaynhap),
    MyColumnConfig<CayTrongModel>(valueGetter: (i) => i.tieude),
  ];
  late Future<List<CayTrongModel>> _itemsFuture;

  void refresh(String search){
    setState(() {
      _search.text = search;
      _itemsFuture = bloc.getNotes(_search.text);      
    });
  }

  TextButton _showDeleteButton(BuildContext context, bool isEdit, int id) {
    if(isEdit){
      return TextButton(
        child: const Text("Xóa"),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Xác nhận xóa"),
                content: const Text("Bạn có chắc xóa?"),
                actions: <Widget>[
                  TextButton(onPressed: () {
                      Navigator.of(context).pop(); // Dismiss the dialog
                    }, 
                    child: const Text("Hủy")
                  ),
                  TextButton(
                    onPressed: () async {
                      await bloc.delete(id); // Call deleteAll method
                      refresh(_search.text);
                      Navigator.of(context).pop(); // Dismiss the dialog
                      Navigator.of(context).pop(); // Dismiss the dialog
                      showToast('Đã xóa');
                    },
                    child: const Text("Xóa")
                  ),
                ],
              );
            },
          ); // Re // Dismiss the dialog
        },
      );
    }else{
      return TextButton(
        onPressed: () {  },
        child: const Text(""));
    }
  }
  void _onCellTap(BuildContext context, CayTrongModel item) {
    var isEdit = (item.id ?? 0) > 0;
    setState(() {
      _dateController.text = item.ngaynhap;      
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEdit ? "Cập nhật" : "Thêm mới"),
          alignment: Alignment.topCenter,
          insetPadding: const EdgeInsets.only(top: 0, left: 20.0, right: 20.0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9, // Chiều rộng bằng 80% màn hình
            height: 350.0,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      key: ngayNhapKey,
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Ngày",
                        suffixIcon: IconButton(onPressed: () {
                              FormatterUtility.selectDate(context, _dateController, CurrentDate.dateFormat);
                            }, icon: const Icon(Icons.calendar_today)
                          )
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Chưa nhập ngày";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      key: tieuDeKey,
                      initialValue: item.tieude,
                      decoration: const InputDecoration(labelText: "Nội dung", alignLabelWithHint: true),
                      maxLines: 10,
                      validator: (value) {
                        value = value?.trim();
                        if (value == null || value.isEmpty) {
                          return 'Chưa nhập nội dung';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              )
            )
          ),
          actions: <Widget>[
            _showDeleteButton(context, isEdit, item.id??0),
            TextButton(
              child: const Text("Hủy"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text("Lưu"),
              onPressed: () async {
                if(_formKey.currentState!.validate()) {
                  CayTrongModel update = CayTrongModel(
                    id: item.id,
                    ngaynhap: ngayNhapKey.currentState?.value ?? '',
                    tieude:  tieuDeKey.currentState?.value ?? '',
                    dongia:  0,
                    soluong:  1,
                    thanhtien: 0,
                    loaicay: LoaiCay.ghichu,
                    loainhap: LoaiNhap.mua,
                    nam: ''
                  );
                  update.soluong=1;
                  update.thanhtien = update.dongia * 1;
                  update.nam = update.ngaynhap.isNotEmpty ? update.ngaynhap.substring(6) : '';
                  if(isEdit){
                    await bloc.update(update); // Update the client
                  }else{
                    await bloc.insert(update); // Update the client
                  }
                  refresh(_search.text);
                  Navigator.of(context).pop(); // Dismiss the dialog
                  showToast('Lưu thành công');
                }
              }
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _search.text = widget.search.isNotEmpty ? widget.search : CurrentDate.year;
    _itemsFuture = bloc.getNotes(_search.text);  
  }

  @override
  void dispose() {    
    // 💡 Dispose FocusNode và remove listener
    _itemsFuture = Future.value([]);
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: const Text("Nhập ghi chú"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 40),
            onPressed: () async {
              // Clear the text fields
              setState(() {
                _dateController.text = '';            
              });
              // ignore: unnecessary_new
              _onCellTap(context, CayTrongModel(ngaynhap: CurrentDate.dateFormat.format(DateTime.now()), tieude: '', dongia: 0, soluong: 1, thanhtien: 0, loaicay: LoaiCay.ghichu, loainhap: LoaiNhap.mua, nam:DateTime.now().year.toString()));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CayTrongModel>>(
        future: _itemsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<CayTrongModel>> snapshot) {
          if (snapshot.hasData) {
            const columnWidths = {
              0: FlexColumnWidth(1), 
              1: FlexColumnWidth(2), 
              2: FlexColumnWidth(7), 
            };          
            if (snapshot.connectionState == ConnectionState.waiting) {   
                return Column(
                  children: [
                    SearchRefreshWidget(
                      labelSearch : "Nội dung tìm",
                      paraSearch: _search.text,
                      onRefresh: refresh, // Truyền hàm tìm kiếm vào đây
                    ),
                    const Center(child: CircularProgressIndicator())]); // H
              } else if (snapshot.hasError) {
                // ignore: prefer_interpolation_to_compose_strings
                return Column(
                  children: [
                    SearchRefreshWidget(
                      labelSearch : "Nội dung tìm",
                      paraSearch: _search.text,
                      onRefresh: refresh, // Truyền hàm tìm kiếm vào đây
                    ),
                    const Text('Lỗi khi tải dữ liệu')
                ] ); // H
              } else if (snapshot.data!.isEmpty) {
                return Column(
                  children: [
                    SearchRefreshWidget(
                      labelSearch : "Nội dung tìm",
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
                      labelSearch : "Nội dung tìm",
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
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(0),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Ngày', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Nội dung', style: TextStyle(fontWeight: FontWeight.bold)),
                              )
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
                                    DataRowHelper.buildRow<CayTrongModel>(
                                      context: context,
                                      item: snapshot.data![i],
                                      columnsConfig: notes,
                                      onEdit: _onCellTap,
                                      index: i,
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