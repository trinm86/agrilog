import 'package:flutter/material.dart';

class CalculationExample extends StatefulWidget {
  const CalculationExample({super.key});
  
  @override
  State<CalculationExample> createState() {
    return CalculationExampleState();
  }
}
class CalculationExampleState extends State<CalculationExample> {
  String operate = "";
  String calOperate = "";
  late List<String> listNum;
  double w = 75;
  double h = 55;
  double first = 0;
  double second = 0;
  double result = 0;
  int idx=0;
  late int point = 0;
  // Tạo Calculation cho Form
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  // ignore: strict_top_level_inference
  void _updateTextFieldValue(newValue) {
    // Đặt giá trị mới cho TextFormField
    setState(() {
      // clear kết quả của phép tính trước
      if(_controller.text.contains("=")){
        _controller.text="";
         _controller2.text="";
      }
      if(_controller2.text.contains("x") || _controller2.text.contains("/") || _controller2.text.contains("-") || _controller2.text.contains("+") || _controller2.text.contains("%")) {
        if(_controller2.text.contains("x")){
          idx = _controller2.text.lastIndexOf("x");
        }
        if(_controller2.text.contains("/")){
          idx = _controller2.text.lastIndexOf("/");
        }
        if(_controller2.text.contains("-")){
          idx = _controller2.text.lastIndexOf("-");
        }
        if(_controller2.text.contains("+")){
          idx = _controller2.text.lastIndexOf("+");
        }
        if(_controller2.text.contains("%")){
          idx = _controller2.text.lastIndexOf("%");
        }
        if(idx == _controller2.text.length-1){
          if(_controller.text.isNotEmpty && _controller.text.substring(0,1)=="0") {
            _controller.text = _controller.text.substring(1, _controller.text.length);
          }
          _controller.text = newValue;
        }else{
          if(_controller.text.isNotEmpty && _controller.text.substring(0,1)=="0") {
            _controller.text = _controller.text.substring(1, _controller.text.length);
          }
          _controller.text += newValue;
        }
      }else{
        if(_controller.text.isNotEmpty && _controller.text.substring(0,1)=="0") {
          _controller.text = _controller.text.substring(1, _controller.text.length);
        }
        _controller.text += newValue;
      }  

      if(_controller2.text.isNotEmpty && _controller2.text.substring(0,1)=="0") {
        _controller2.text = _controller2.text.substring(1, _controller2.text.length);
      }
      _controller2.text += newValue;
    });
  }

  // ignore: strict_top_level_inference
  void _updateTextFieldValue2(operate) {
    // Đặt giá trị mới cho TextFormField
    setState(() {
      if(_controller2.text.contains("x") || _controller2.text.contains("/") || _controller2.text.contains("-") || _controller2.text.contains("+") || _controller2.text.contains("%")) {
        if(_controller2.text.contains("x")){
          idx = _controller2.text.lastIndexOf("x");
        }
        if(_controller2.text.contains("/")){
          idx = _controller2.text.lastIndexOf("/");
        }
        if(_controller2.text.contains("-")){
          idx = _controller2.text.lastIndexOf("-");
        }
        if(_controller2.text.contains("+")){
          idx = _controller2.text.lastIndexOf("+");
        }
        if(_controller2.text.contains("%")){
          idx = _controller2.text.lastIndexOf("%");
        }
        if(idx == _controller2.text.length-1){
          _controller2.text = _controller2.text.substring(0, _controller2.text.length-1);
        }
      }else{
        _controller2.text += operate;
      }
    });
  }

  void _calculateNumber() {
    setState(() {
      if(_controller2.text.contains("x")){
        calOperate = "x";
      }
      if(_controller2.text.contains("/")){
        calOperate = "/";
      }
      if(_controller2.text.contains("-")){
        calOperate = "-";
      }
      if(_controller2.text.contains("+")){
        calOperate = "+";
      } 
      if(_controller2.text.contains("%")){
        calOperate = "%";
      }      
      listNum = _controller2.text.split(calOperate);
      first = double.tryParse(listNum[0]) ?? 0;
      second = 0;
      if(listNum.length>1){
        second = double.tryParse(listNum[1]) ?? 0;
      }      
    });
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ của controller khi không dùng nữa
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var styleFrom = ElevatedButton.styleFrom(
                      minimumSize: Size(w, h),
                      backgroundColor: Colors.white
                    );
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator'), backgroundColor: Colors.orange,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Expanded(child: Text("")),
              TextFormField(
                controller: _controller2,
                enabled: false,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 30),
                decoration: const InputDecoration(
                  border: InputBorder.none, // Loại bỏ đường viền
                ),
              ),
              TextFormField(
                controller: _controller,
                enabled: false,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(width: 0, height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(style: styleFrom, onPressed: (){
                    setState(() {
                      operate = "";
                      _controller.text = "0";
                      _controller2.text = "0";
                    });
                  }, child: const Text("AC", style: TextStyle(fontSize: 20, color: Colors.orange),)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    setState(() {
                      if(_controller.text.isNotEmpty){
                        _controller.text = _controller.text.substring(0, _controller. text.length-1);
                        if(_controller.text.isEmpty){
                          _controller.text = "0";
                        }
                      }else{
                        _controller.text = "0";
                      }

                      if(_controller2.text.isNotEmpty){
                        _controller2.text = _controller2.text.substring(0, _controller2. text.length-1);
                        if(_controller2.text.isEmpty){
                          _controller2.text = "0";
                        }
                      }else{
                        _controller2.text = "0";
                      }
                    });
                  }, child: const Icon(Icons.arrow_back, color: Colors.orange,)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                      setState(() {
                      operate = "%";
                      _updateTextFieldValue2(operate);
                    });
                  }, child: const Text("%", style: TextStyle(fontSize: 20, color: Colors.orange),)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    setState(() {
                      operate = "/";
                      _updateTextFieldValue2(operate);
                    });
                  }, child: const Text("/", style: TextStyle(fontSize: 20, color: Colors.orange),))
                ],
              ),
              const SizedBox(width: 0, height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(style: styleFrom, onPressed: (){
                    _updateTextFieldValue("7");
                  }, child: const Text("7", style: TextStyle(fontSize: 20, color: Colors.orange),)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    _updateTextFieldValue("8");
                  }, child: const Text("8", style: TextStyle(fontSize: 20, color: Colors.orange),)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    _updateTextFieldValue("9");
                  }, child: const Text("9", style: TextStyle(fontSize: 20, color: Colors.orange),)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    setState(() {
                      operate = "x";
                      _updateTextFieldValue2(operate);
                    });
                  }, child: const Text("x", style: TextStyle(fontSize: 20, color: Colors.orange),))
                ],
              ),
              const SizedBox(width: 0, height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(style: styleFrom, onPressed: (){
                    _updateTextFieldValue("4");
                  }, child: const Text("4", style: TextStyle(fontSize: 20, color: Colors.orange),)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    _updateTextFieldValue("5");
                  }, child: const Text("5", style: TextStyle(fontSize: 20, color: Colors.orange),)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    _updateTextFieldValue("6");
                  }, child: const Text("6", style: TextStyle(fontSize: 20, color: Colors.orange),)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    setState(() {
                      operate = "-";
                      _updateTextFieldValue2(operate);
                    });
                  }, child: const Text("-", style: TextStyle(fontSize: 20, color: Colors.orange),))
                ],
              ),
              const SizedBox(width: 0, height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(style: styleFrom, onPressed: (){
                    _updateTextFieldValue("1");
                  }, child: const Text("1", style: TextStyle(fontSize: 20, color: Colors.orange),)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    _updateTextFieldValue("2");
                  }, child: const Text("2", style: TextStyle(fontSize: 20, color: Colors.orange),)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    _updateTextFieldValue("3");
                  }, child: const Text("3", style: TextStyle(fontSize: 20, color: Colors.orange),)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    setState(() {
                      operate = "+";
                      _updateTextFieldValue2(operate);
                    });
                  }, child: const Text("+", style: TextStyle(fontSize: 20, color: Colors.orange),))
                ],
              ),
              const SizedBox(width: 0, height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(style: styleFrom, onPressed: (){}, child: const Icon(Icons.refresh, color: Colors.orange,)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    _updateTextFieldValue("0");
                  }, child: const Text("0", style: TextStyle(fontSize: 20, color: Colors.orange),)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    if(!_controller.text.contains(".")){
                      _updateTextFieldValue(".");
                    }
                  }, child: const Text(".", style: TextStyle(fontSize: 20, color: Colors.orange),)),
                  ElevatedButton(style: styleFrom, onPressed: (){
                    setState(() {
                      _calculateNumber();
                      switch(operate){
                        case "/": result = first / second;
                        break;
                        case "x": result = first * second;
                        break;
                        case "-": result = first - second;
                        break;
                        case "+": result = first + second;
                        break;
                        case "%": result = first % second;
                        break;
                      }
                      
                      point = (result % result.toInt())>0 ? 2 : 0;
                      _controller.text = "= ${result.toStringAsFixed(point)}";
                      operate = "";
                      first = 0;
                      second = 0;
                      result = 0;
                    });
                  }, child: const Text("=", style: TextStyle(fontSize: 20, color: Colors.orange),))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}