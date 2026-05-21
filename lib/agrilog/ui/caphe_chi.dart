// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_first_app/agrilog/util/currencyinputformatter.dart';
import 'package:my_first_app/agrilog/widget/datarowhelper.dart';
import 'package:my_first_app/agrilog/util/formatter_utility.dart';
import 'package:my_first_app/agrilog/widget/search_refresh_widget.dart';
import 'package:my_first_app/agrilog/widget/total_money.dart';
import 'package:my_first_app/agrilog/model/class.dart';
import 'package:my_first_app/agrilog/accessdb/business_logic.dart';
import 'package:my_first_app/util/config.dart';
import 'package:my_first_app/util/toast.dart';

class CaPheMuaApp extends StatefulWidget {
  final String search;
  const CaPheMuaApp({super.key, required this.search});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<CaPheMuaApp> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final GlobalKey<FormFieldState<String>> ngayNhapKey = GlobalKey<FormFieldState<String>>();
  static final GlobalKey<FormFieldState<String>> tieuDeKey = GlobalKey<FormFieldState<String>>();
  static final GlobalKey<FormFieldState<String>> donGiaKey = GlobalKey<FormFieldState<String>>();
  static final GlobalKey<FormFieldState<String>> soLuongKey = GlobalKey<FormFieldState<String>>();
  static final GlobalKey<FormFieldState<String>> thanhTienKey = GlobalKey<FormFieldState<String>>();
  static final GlobalKey<FormFieldState<String>> namSXKey = GlobalKey<FormFieldState<String>>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _dongia = TextEditingController();
  final TextEditingController _soluong = TextEditingController();
  final TextEditingController _thanhtien = TextEditingController();
  final TextEditingController _search = TextEditingController(text: CurrentDate.year);
  // ignore: non_constant_identifier_names
  String don_gia="0";
  // ignore: non_constant_identifier_names
  String so_luong="0";
  // ignore: non_constant_identifier_names
  String thanh_tien="0";

  late CayTrongBloc bloc;
  late Future<List<CayTrongModel>> _itemsFuture;
  final cols = [
      MyColumnConfig<CayTrongModel>(valueGetter: (i) => i.ngaynhap),
      MyColumnConfig<CayTrongModel>(valueGetter: (i) => i.tieude),
      MyColumnConfig<CayTrongModel>(
        valueGetter: (i) => FormatNum.integer.format(i.dongia),
        align: TextAlign.right,
      ),
      MyColumnConfig<CayTrongModel>(
        valueGetter: (i) => FormatNum.decimal.format(i.soluong),
        align: TextAlign.right,
      ),
      MyColumnConfig<CayTrongModel>(
        valueGetter: (i) => FormatNum.integer.format(i.thanhtien),
        align: TextAlign.right,
      ),
    ];
  void refresh(String search){
    setState(() {
      _search.text = search;
      _itemsFuture = bloc.getAlls(_search.text);      
    });
  }

  // Thêm hàm này vào class _MyAppState
  void _updateThanhTien() {
    // 1. Lấy giá trị Đơn giá và Số lượng, loại bỏ dấu phân cách nếu có
    final cleanDonGia = _dongia.text.replaceAll(RegExp(r'[,]'), '');
    final cleanSoLuong = _soluong.text.replaceAll(RegExp(r'[,]'), '');
    
    final double donGia = double.tryParse(cleanDonGia) ?? 0;
    final double soLuong = double.tryParse(cleanSoLuong) ?? 0;
    
    // 2. Tính toán Thành tiền
    final double thanhTien = donGia * soLuong;
    
    // 3. Cập nhật trực tiếp Controller (không cần setState)
    _thanhtien.text = FormatNum.integer.format(thanhTien);
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
    _dongia.text = FormatNum.integer.format(item.dongia);
    _soluong.text = FormatNum.decimal.format(item.soluong);
    _thanhtien.text = FormatNum.integer.format(item.thanhtien);

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
                      key: namSXKey,
                      initialValue: item.nam,
                      decoration: const InputDecoration(labelText: 'Năm'),
                      keyboardType: TextInputType.number, // Hiển thị bàn phím số
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],            
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Chưa nhập năm';
                        }
                        value = value.replaceAll(RegExp(r'[,]'), '');
                        final number = double.tryParse(value.trim());
                        if (number == null) {
                          return 'Năm không hợp lệ';
                        }
                        if (number <= 0) {
                          return 'Năm phải lớn hơn 0';
                        }
                        return null;
                      },
                    ),
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
                      decoration: const InputDecoration(labelText: "Nội dung"),
                      validator: (value) {
                        value = value?.trim();
                        if (value == null || value.isEmpty) {
                          return 'Chưa nhập nội dung';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      key: donGiaKey,
                      controller: _dongia,
                      decoration: const InputDecoration(labelText: 'Đơn giá'),
                      keyboardType: TextInputType.number, // Hiển thị bàn phím số
                      inputFormatters: [
                        CurrencyInputFormatter(allowDecimal: false), // 👈 Dùng class vừa tạo ở đây
                      ],
                      onChanged: (value)=>{
                        _updateThanhTien()
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Chưa nhập đơn giá';
                        }
                        value = value.replaceAll(RegExp(r'[,]'), '');
                        final number = double.tryParse(value.trim());
                        if (number == null) {
                          return 'Đơn giá không hợp lệ';
                        }
                        if (number <= 0) {
                          return 'Đơn giá phải lớn hơn 0';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      key: soLuongKey,
                      controller: _soluong,
                      decoration: const InputDecoration(labelText: 'Số lượng'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                      inputFormatters: [
                        CurrencyInputFormatter(allowDecimal: true), // 👈 Dùng class vừa tạo ở đây
                      ],
                      onChanged: (value)=>{
                        _updateThanhTien()
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Chưa nhập số lượng';
                        }
                        value = value.replaceAll(RegExp(r'[,]'), '');
                        final number = double.tryParse(value.trim());
                        if (number == null) {
                          return 'Số lượng không hợp lệ';
                        }
                        if (number <= 0) {
                          return 'Số lượng phải lớn hơn 0';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      key: thanhTienKey,
                      controller: _thanhtien,
                      enabled: false,
                      //initialValue: numberFormat2.format(item.thanhtien),
                      decoration: const InputDecoration(labelText: 'Thành tiền'),
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
                  //don_gia = (donGiaKey.currentState?.value ?? '0').replaceAll(RegExp(r'[,]'), '');
                  //so_luong = (soLuongKey.currentState?.value ?? '0').replaceAll(RegExp(r'[,]'), '');
                  CayTrongModel update = CayTrongModel(
                    id: item.id,
                    ngaynhap: ngayNhapKey.currentState?.value ?? '',
                    tieude:  tieuDeKey.currentState?.value ?? '',
                    dongia:  double.tryParse(_dongia.text.replaceAll(',', '')) ?? 0, //double.tryParse(don_gia)??0,
                    soluong: double.tryParse(_soluong.text.replaceAll(',', '')) ?? 0, // double.tryParse(so_luong)??0,
                    thanhtien: 0,
                    loaicay: LoaiCay.caphe,
                    loainhap: LoaiNhap.mua,
                    nam: namSXKey.currentState?.value ?? ''
                  );
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
    _dongia.text = '0';
    _soluong.text = '0';
    _thanhtien.text = '0';    
    _search.text = widget.search.isNotEmpty ? widget.search : CurrentDate.year;
    bloc = CayTrongBloc.withParams(LoaiCay.caphe, LoaiNhap.mua, _search.text);
    _itemsFuture = bloc.getAlls(_search.text);    
  }

  @override
  void dispose() {    
    _dongia.dispose();
    _soluong.dispose();
    _thanhtien.dispose();
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
        title: const Text("Chi tiền Cà phê"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 40),
            onPressed: () async {
              // Clear the text fields
              setState(() {
                _dateController.text = '';            
              });
              _dongia.text = '';
              _soluong.text = '';
              _thanhtien.text = '';
              // ignore: unnecessary_new
              _onCellTap(context, CayTrongModel(ngaynhap: CurrentDate.dateFormat.format(DateTime.now()), tieude: '', dongia: 0, soluong: 1, thanhtien: 0, loaicay: LoaiCay.caphe, loainhap: LoaiNhap.ban, nam:DateTime.now().year.toString()));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CayTrongModel>>(
        future: _itemsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<CayTrongModel>> snapshot) {
          if (snapshot.hasData) {
            const columnWidths = {
              0: FlexColumnWidth(1), // Cột đầu tiên chiếm 2 phần
              1: FlexColumnWidth(1.4), // Cột đầu tiên chiếm 2 phần
              2: FlexColumnWidth(3.4), // Cột thứ hai chiếm 3 phần
              3: FlexColumnWidth(2.1), // Cột thứ ba chiếm 4 phần
              4: FlexColumnWidth(1), // Cột thứ ba chiếm 4 phần
              5: FlexColumnWidth(2.1), // Cột thứ ba chiếm 4 phần
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
                                  padding: EdgeInsets.all(0),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Ngày', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Nội dung', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Giá', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('SL', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0, right: 0),
                                  child: TotalMoneyWidget(content: FormatNum.integer.format(snapshot.data!.fold<double>(0, (sum, item) => sum + item.thanhtien)), fontSize: 14),
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
                                          DataRowHelper.buildRow<CayTrongModel>(
                                            context: context,
                                            item: snapshot.data![i],
                                            columnsConfig: cols,
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