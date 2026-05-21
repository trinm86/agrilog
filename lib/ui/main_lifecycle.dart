import 'package:flutter/material.dart';
import 'package:my_first_app/util/toast.dart';

class LifecycleDemo extends StatefulWidget {
  const LifecycleDemo({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LifecycleDemoState createState() => _LifecycleDemoState();
}

class _LifecycleDemoState extends State<LifecycleDemo> with WidgetsBindingObserver {
  String _appState = 'App is active';
  var imageBg = const AssetImage('images/media.jpg');
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Thêm observer vào vòng đời
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Gỡ bỏ observer khi huỷ widget
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    setState(() {
      switch (state) {
        case AppLifecycleState.resumed:
          _appState = 'App is active'; // ứng dụng đang hoạt động và hiển thị trên màn hình
          break;
        case AppLifecycleState.inactive:
          _appState = 'App is inactive'; // ứng dụng không hoạt động nhưng chưa vào chế độ nền (có 1 ứng dụng khác overlay)
          break;
        case AppLifecycleState.paused:
          _saveData();
          _appState = 'App is in background'; // ứng dụng ở chế độ nền, người dùng không tương tác trực tiếp
          break;
        case AppLifecycleState.detached:
          _appState = 'App is detached'; // ứng dụng tách khỏi hệ thống (đóng hoặc thoát hoàn toàn)
          break;
        case AppLifecycleState.hidden:
          _appState = 'App is hidden';
          break;
      }
    });

    // In trạng thái ứng dụng hiện tại ra console để tiện theo dõi
    showToast('App state changed: $_appState');
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(imageBg, context);
    var card = SizedBox(
      height: 210.0,
      child: Card( // cả 3 thông tin sẽ hiển thị trong 1 card 
        child: Column( // hiển thị theo Column 
          children: [// và là 1 list children: 3 ListTiles và 1 Divider
            ListTile( // mỗi một thông tin sẽ là một ListTile
              title: const Text('1625 Main Street',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('My City, CA 99984'),
              leading: Icon(
                Icons.restaurant_menu,
                color: Colors.blue[500],
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('(408) 555-1212',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              leading: Icon(
                Icons.contact_phone,
                color: Colors.blue[500],
              ),
            ),
            ListTile(
              title: const Text('costa@example.com'),
              leading: Icon(
                Icons.contact_mail,
                color: Colors.blue[500],
              ),
            ),
          ],
        ),
      ),
    );
    var stack = Stack( // chúng ta sử dụng Stack 
      alignment: const Alignment(0.7, 0.5),
      children: [ // với layout chứa các thành phần con 
        CircleAvatar( // một avatar là first child, vì thể nó sẽ là base widget trong Stack
          backgroundImage: imageBg,
          radius: 150.0,
        ),
        Container( // và Container để hiểnt thị Text 
          decoration: const BoxDecoration(
            color: Color.fromARGB(115, 226, 143, 18),
          ),
          child: Text(
            _appState,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 239, 244, 250),
            ),
          ),
        ),
      ],
    );
    return Scaffold(
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Lifecycle Demo'),
      ),
      body: Column(
        children: [
          Center(
            child: stack
          ), 
          card
        ],
      ) ,
      floatingActionButton: FloatingActionButton(onPressed: (){
        showToast('You clicked the button');
      }, child: const Text("+", style: TextStyle(fontSize: 30)))
    );
  }

  void _saveData() {
    // Lưu trạng thái hoặc dữ liệu ở đây
    showToast('Data saved when app is in background');
  }
}
