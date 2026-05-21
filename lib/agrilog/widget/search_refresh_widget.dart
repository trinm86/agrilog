import 'package:flutter/material.dart';
import 'package:my_first_app/util/config.dart';

typedef SearchCallback = void Function(String search);
class SearchRefreshWidget extends StatefulWidget {
  // Hàm refresh được truyền từ bên ngoài để thực thi logic tìm kiếm
  final SearchCallback onRefresh;
  final String paraSearch;
  final String labelSearch;
  const SearchRefreshWidget({
    super.key,
    required this.onRefresh,
    required this.paraSearch,
    required this.labelSearch
  });

  @override
  State<SearchRefreshWidget> createState() => _SearchRefreshWidgetState();
}

class _SearchRefreshWidgetState extends State<SearchRefreshWidget> {
  // Controller để quản lý dữ liệu nhập vào của TextFormField
  final TextEditingController _searchController = TextEditingController(text: CurrentDate.year);
  
  // Getter để lấy giá trị năm đã nhập
  String get searchValue => _searchController.text;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.paraSearch.isNotEmpty ? widget.paraSearch : CurrentDate.year;
  }

  @override
  void dispose() {
    // Rất quan trọng: Giải phóng controller để tránh rò rỉ bộ nhớ
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
        child: Column(
          children: [
            Row(
            // Căn chỉnh nội dung (TextFormField và ElevatedButton) bắt đầu từ trái
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Bọc TextFormField trong SizedBox để đặt chiều rộng cố định
              SizedBox(
                width: 300, // Chiều rộng cố định cho ô tìm kiếm
                child: Form( // Bọc trong Form để sử dụng Key và validation nếu cần
                  child: TextFormField(
                    controller: _searchController, // Sử dụng Controller đã khai báo
                    decoration: InputDecoration(labelText: widget.labelSearch),
                    // Có thể thêm inputFormatters hoặc keyboardType ở đây
                  ),
                ),
              ),
              
              // Thêm một khoảng cách nhỏ giữa ô nhập và nút
              const SizedBox(width: 8), 

              // Nút Tìm
              ElevatedButton(
                onPressed: () {
                  final search = _searchController.text;
                  // Gọi hàm refresh được truyền từ widget cha
                  widget.onRefresh(search);
                  
                  // Bạn có thể in giá trị tìm kiếm ra đây:
                  // print('Đang tìm kiếm năm: ${_searchController.text}'); 
                },
                child: const Icon(Icons.search),
              ),
            ]),
            const SizedBox(height: 3)
          ],
        ),
      )
    ) ;
  }
}