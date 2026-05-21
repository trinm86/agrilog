import 'package:flutter/material.dart';
import 'package:my_first_app/agrilog/ui/caphe_thu.dart';
import 'package:my_first_app/agrilog/ui/caphe_chi.dart';
import 'package:my_first_app/agrilog/ui/caphe_loinhuan.dart';
import 'package:my_first_app/agrilog/model/class.dart';
import 'package:my_first_app/util/config.dart';
import 'package:my_first_app/agrilog/ui/saurieng_thu.dart';
import 'package:my_first_app/agrilog/ui/saurieng_chi.dart';
import 'package:my_first_app/agrilog/ui/saurieng_loinhuan.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GroupedColumnChart extends StatelessWidget {
  final List<ThreeChartData> chartData; 
  final String chartTitle;  
  final bool showLabel;
  final bool isNotEmptyYear;  

  const GroupedColumnChart({super.key, required this.chartData, required this.chartTitle, required this.showLabel, required this.isNotEmptyYear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height/2.25,
        padding: const EdgeInsets.all(0),
        child: SfCartesianChart(
          title: const ChartTitle(text: ''),
          legend: Legend(isVisible: showLabel), // Hiển thị chú giải
          tooltipBehavior: TooltipBehavior(enable: false), // tắt tooltip
          primaryXAxis: CategoryAxis(
            title: AxisTitle(text: chartTitle),
          ),
          
          series:[
            // Series 1: Thu (Màu xanh lá)
            ColumnSeries<ThreeChartData, String>(              
              dataSource: chartData,
              xValueMapper: (ThreeChartData data, _) => isNotEmptyYear ? data.tencay : data.cycle,
              yValueMapper: (ThreeChartData data, _) => data.costThu/FormatNum.trieu,
              name: 'Thu', // Tên hiện trên chú giải
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              color: Colors.green.shade700,
              onPointTap: (ChartPointDetails details) {                
                pointTap(context,details,chartData,ReportEnum.thu);
              },
            ),
            
            // Series 2: Chi (Màu đỏ)
            ColumnSeries<ThreeChartData, String>(
              dataSource: chartData,
              xValueMapper: (ThreeChartData data, _) => isNotEmptyYear ? data.tencay : data.cycle,
              yValueMapper: (ThreeChartData data, _) => data.costChi/FormatNum.trieu,
              name: 'Chi',
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              color: Colors.red.shade700,
              onPointTap: (ChartPointDetails details) {                
                pointTap(context,details,chartData,ReportEnum.chi);
              },
            ),

            // Series 3: Lợi nhuận (Màu xanh dương)
            ColumnSeries<ThreeChartData, String>(
              dataSource: chartData,
              xValueMapper: (ThreeChartData data, _) => isNotEmptyYear ? data.tencay : data.cycle,
              yValueMapper: (ThreeChartData data, _) => data.costLoiNhuan/FormatNum.trieu,
              name: 'Lơi nhuận',
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              color: Colors.blue.shade700,
              onPointTap: (ChartPointDetails details) {                
                pointTap(context,details,chartData,ReportEnum.tongket);
              },
            ),
          ],
        ),
      ),
    );
  }
}

void pointTap(BuildContext context, ChartPointDetails details, List<ThreeChartData> chartData, int wid) {                
  // 2. Lấy chỉ số của CỘT (Point Index)
  final int? pointIndex = details.pointIndex; // KHÔNG BAO GIỜ NULL KHI DÙNG onPointTap

  if (pointIndex != null) {
    // 3. Truy cập dữ liệu gốc từ dataSource
    final ThreeChartData tappedData = chartData[pointIndex];

    // 0: thu tiền, 1: chi tiền, 2: tổng kết
    switch(wid){
      case ReportEnum.thu:
        // Ví dụ: Điều hướng đến trang chi tiết
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => tappedData.loaicay == LoaiCay.caphe ? CaPheBanApp(search: tappedData.cycle):SauRiengBanApp(search: tappedData.cycle),
          ),
        );
      break;
      case ReportEnum.chi:
        // 4. Gọi hàm xử lý và điều hướng
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => tappedData.loaicay == LoaiCay.caphe ? CaPheMuaApp(search: tappedData.cycle):SauRiengMuaApp(search: tappedData.cycle),
          ),
        );
      break;
      case ReportEnum.tongket:
        // 4. Gọi hàm xử lý và điều hướng
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => tappedData.loaicay == LoaiCay.caphe ? CaPheTongKetApp(nam_nhap: tappedData.cycle):SauRiengTongKetApp(nam_nhap: tappedData.cycle),
          ),
        );
      break;
    }
  }
}