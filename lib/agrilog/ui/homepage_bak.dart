import 'package:flutter/material.dart';
import 'package:my_first_app/agrilog/ui/chiphikhac.dart';
import 'package:my_first_app/util/config.dart';
import 'package:my_first_app/agrilog/widget/syncfusion_column_chart.dart';
import 'package:my_first_app/agrilog/accessdb/business_logic.dart';
import 'package:my_first_app/agrilog/model/class.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartAppBak extends StatefulWidget {
  const ChartAppBak({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<ChartAppBak> {
  late Future<ChartReport> _itemsFuture;
  late ReportBloc bloc = ReportBloc('');
  void refresh(){
    setState(() {
      _itemsFuture = bloc.getLoiNhuans('');
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void dispose() {    
    bloc.dispose();
    super.dispose();
  }
  Future<void> _refreshDataCf() async {
    refresh(); // Gọi lại hàm tải dữ liệu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: FutureBuilder<ChartReport>(
        future: _itemsFuture,
        builder: (BuildContext context, AsyncSnapshot<ChartReport> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {                
                return const Center(child: CircularProgressIndicator()); // H
              } else if (snapshot.hasError) {
                // ignore: prefer_interpolation_to_compose_strings
                return const Text('Lỗi khi tải dữ liệu'); // H
              } else if (!snapshot.hasData) {
                return const Text('Không có dữ liệu.'); // Hiển thị khi không có dữ liệu
              } else {
                // Hiển thị danh sách người dùng khi có dữ liệu
                return RefreshIndicator(
                  onRefresh: _refreshDataCf, // Gọi _refreshData khi kéo xuống
                  child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column( // 💡 SỬ DỤNG COLUMN ĐỂ CHỨA TIÊU ĐỀ VÀ BIỂU ĐỒ
                        mainAxisSize: MainAxisSize.min, // Đảm bảo Column không chiếm hết không gian
                        children: [
                          GroupedColumnChart(
                            chartData: snapshot.data!.caphes,
                            chartTitle: 'Lợi nhuận Cà phê (triệu đồng)',
                            showLabel: true,
                            isNotEmptyYear: true,
                          ),
                          GroupedColumnChart(
                            chartData: snapshot.data!.sauriengs,
                            chartTitle: 'Lợi nhuận Sầu riêng (triệu đồng)',
                            showLabel: false,
                            isNotEmptyYear: true,
                          ),
                          SfCartesianChart(
                            primaryXAxis: const CategoryAxis(title: AxisTitle(text: 'Chi phí khác (triệu đồng)')),
                            primaryYAxis: const NumericAxis(),

                            series:[
                              ColumnSeries<SaleData, String>(
                                name: '',
                                dataSource: snapshot.data!.chiphis,
                                xValueMapper: (SaleData sales, _) => sales.year,
                                yValueMapper: (SaleData sales, _) => sales.sales/FormatNum.trieu,
                                dataLabelSettings: const DataLabelSettings(isVisible: true),
                                onPointTap: (ChartPointDetails details) {              
                                  final int? pointIndex = details.pointIndex; 
                                  if (pointIndex != null) {
                                    final SaleData tappedData = snapshot.data!.chiphis[pointIndex];
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChiPhiKhacApp(search: tappedData.year),
                                      ),
                                    );
                                  }
                                },
                              ),
                              
                              // 2. LineSeries (Thường dùng cho Mục tiêu hoặc Xu hướng)
                              LineSeries<SaleData, String>(
                                name: '',
                                dataSource: snapshot.data!.chiphis,
                                xValueMapper: (SaleData sales, _) => sales.year,
                                yValueMapper: (SaleData sales, _) => sales.sales/FormatNum.trieu,
                                markerSettings: const MarkerSettings(isVisible: true), // Đánh dấu điểm dữ liệu
                                dataLabelSettings: const DataLabelSettings(isVisible: true),
                              ),
                            ],
                          )
                        ]
                      )
                    )
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