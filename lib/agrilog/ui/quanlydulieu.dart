// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_first_app/agrilog/accessdb/supabaseservice.dart';

class QuanLyData extends StatefulWidget {
  const QuanLyData({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _QuanLyDataState createState() => _QuanLyDataState();
}

class _QuanLyDataState extends State<QuanLyData> {
  late bool _backup = true;
  late bool _restore = true;
  late bool _update = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: const Text("Quản lý dữ liệu"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _backup = false;                      
                    });
                    final res = await SupabaseService.backupDataToLocal();    
                    setState(() {
                      _backup = res;                
                    }); 
                  },
                  child: _backup ? const SizedBox(
                      width: 180, // Đặt chiều rộng mong muốn (ví dụ: 200 pixels)
                      child: Text(
                        "Backup to Google Drive",
                        textAlign: TextAlign.center, // Tùy chọn căn giữa văn bản trong SizedBox
                      ),
                    ) : const CircularProgressIndicator(),
                ),
                const SizedBox(height: 10, width: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _restore = false;                      
                    });
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Xác nhận phục hồi"),
                          content: const Text("Dữ liệu hiện tại sẽ mất hết?", style: TextStyle(fontSize: 15)),
                          actions: <Widget>[
                            TextButton(onPressed: () {
                                Navigator.of(context).pop(); // Dismiss the dialog
                                setState(() {
                                  _restore = true;                      
                                });
                              }, 
                              child: const Text("Hủy")
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop(); // Dismiss the dialog
                                final res = await SupabaseService.restoreDataFromLocal(); 
                                setState(() {
                                  _restore = res;                
                                });               
                              },
                              child: const Text("OK")
                            ),
                          ],
                        );
                      },
                    ); // Re // Dismiss the dialog
                  },
                  child:_restore ? const SizedBox(
                      width: 180, // Đặt chiều rộng mong muốn (ví dụ: 200 pixels)
                      child: Text(
                        "Restore from Google Drive",
                        textAlign: TextAlign.center, // Tùy chọn căn giữa văn bản trong SizedBox
                      ),
                    ) : const CircularProgressIndicator(),
                ),
                const SizedBox(height: 10, width: 30),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _update = false;                      
                    });
                    final res = await SupabaseService.restoreDataFromGitHub();   
                    setState(() {
                      _update = res;                
                    }); 
                  },
                  child: _update ? const SizedBox(
                      width: 180, // Đặt chiều rộng mong muốn (ví dụ: 200 pixels)
                      child: Text(
                        "Restore from Github",
                        textAlign: TextAlign.center, // Tùy chọn căn giữa văn bản trong SizedBox
                      ),
                    ) : const CircularProgressIndicator(),
                ),
              ],
            )
          ),
        )
      )
    );
  }
}