import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_first_app/util/config.dart';
import 'package:my_first_app/agrilog/util/formatter_utility.dart';
import 'package:my_first_app/util/toast.dart';
import 'package:my_first_app/widget/widget_checkbox.dart';

class SelectList {
  String key;
  String value;

  SelectList(this.key, this.value);
}

class GlobalKeyExample extends StatefulWidget {
  const GlobalKeyExample({super.key});

  @override
  State<GlobalKeyExample> createState() {
    return GlobalKeyExampleState();
  }
}

class GlobalKeyExampleState extends State<GlobalKeyExample> {
  bool chk = false;
  String selVal = "ST";
  // Biến để lưu trữ các giá trị Dropdown
  final List<SelectList> _dropdownItems = [
    SelectList('', ' -- // -- '),
    SelectList('ST', 'Sóc Trăng'),
    SelectList('HG', 'Hậu Giang'),
    SelectList('CT', 'Cần Thơ'),
    SelectList('LD', 'Lâm Đồng')
  ];
  // Tạo GlobalKey cho Form
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Tạo GlobalKey cho từng TextFormField
  static final GlobalKey<FormFieldState<String>> _firstNameKey =
      GlobalKey<FormFieldState<String>>();
  static final GlobalKey<FormFieldState<String>> _ageKey =
      GlobalKey<FormFieldState<String>>();
  final TextEditingController _dateController = TextEditingController();
  static final GlobalKey<FormFieldState<String>> _doubleKey =
      GlobalKey<FormFieldState<String>>();
  static final GlobalKey<FormFieldState<String>> _selectKey =
      GlobalKey<FormFieldState<String>>();
  static final GlobalKey<FormFieldState<bool>> _checkBoxKey =
      GlobalKey<FormFieldState<bool>>();
  static final GlobalKey<FormFieldState<bool>> _checkBoxGKey =
      GlobalKey<FormFieldState<bool>>();

  String get _showValueKeys {
    // Lấy giá trị từ các GlobalKey của TextFormField
    final firstName = _firstNameKey.currentState?.value ?? '';
    final age = _ageKey.currentState?.value ?? '';
    final double = _doubleKey.currentState?.value ?? '';
    final select = _selectKey.currentState?.value ?? '';
    final isChecked = _checkBoxKey.currentState?.value ?? false;
    final isCheckedG = _checkBoxGKey.currentState?.value ?? false;

    return 'Họ tên: $firstName, Tuổi: $age, Giới tính: ${isChecked ? 'Male' : 'Female'}, Ngày sinh: ${_dateController.text}, Accept: $isCheckedG, Double: $double, Select: $select';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Control Example'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    key: _firstNameKey,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (value) {
                      value = value?.trim();
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    key: _ageKey,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number, // Hiển thị bàn phím số
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter
                          .digitsOnly, // Chỉ cho phép số nguyên
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your age';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    key: _doubleKey,
                    decoration: const InputDecoration(
                        labelText: 'Enter a decimal number'),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true), // Cho phép nhập số thập phân
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(
                          r'^\d*\.?\d*')), // Chỉ cho phép số và một dấu chấm
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a decimal number';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  // how to add a date picker to a textfield in flutter
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                        labelText: "Date",
                        suffixIcon: IconButton(
                            onPressed: () {
                              FormatterUtility.selectDate(context, _dateController, CurrentDate.dateFormat); // Dismiss the dialog
                            },
                            icon: const Icon(Icons.calendar_today))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please select a date";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    key:
                        _selectKey, // Đặt GlobalKey cho DropdownButtonFormField
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Chọn nơi sinh',
                    ),
                    initialValue: selVal,
                    items: _dropdownItems.map((SelectList item) {
                      return DropdownMenuItem<String>(
                        value: item.key,
                        child: Text(item.value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selVal = newValue!;
                      });
                    },
                    validator: (value) {
                      value = value?.trim();
                      if (value == null || value.isEmpty) {
                        return 'Please select an option';
                      }
                      return null;
                    },
                  ),
                  CheckboxFormField(
                    key: _checkBoxKey,
                    title: const Text('Gender'),
                    validator: (value) {
                      if (value == null) {
                        return 'Please check Gender';
                      }
                      return null;
                    },
                  ),
                  CheckboxFormField(
                    key: _checkBoxGKey,
                    title: const Text('I accept'),
                    validator: (value) {
                      if (value == null) {
                        return 'You must accept terms and conditions';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Sử dụng _formKey để truy cập và xác nhận Form
                      if (_formKey.currentState!.validate()) {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(content: Text(_showValueKeys), duration: const Duration(seconds: 4),),
                        // );
                        showToast(_showValueKeys);
                        //_printValueKeys();
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
