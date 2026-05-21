import 'package:flutter/material.dart';
import 'package:my_first_app/util/config.dart';

class DataRowHelper {
  static TableRow buildRow<T>({
    required BuildContext context,
    required T item,
    required List<MyColumnConfig<T>> columnsConfig, // Danh sách cột động
    required Function(BuildContext, T)? onEdit,
    required int index,
    bool showEdit = true,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey.withValues(alpha: 0.05) : Colors.transparent,
      ),
      children: [
        // 1. Cột mặc định: Nút Sửa (Luôn luôn có)
        if (showEdit)
          Center(
            child: IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
              onPressed: onEdit != null ? () => onEdit(context, item) : null,
            ),
          ),

        // 2. Duyệt qua danh sách cấu hình để tạo các cột còn lại
        ...columnsConfig.map((config) {
          return _buildCellText(
            config.valueGetter(item),
            align: config.align,
            isBold: config.isBold,
          );
        }),
      ],
    );
  }

  static Widget _buildCellText(String text, {TextAlign align = TextAlign.left, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}