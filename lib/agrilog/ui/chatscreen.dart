// ignore_for_file: constant_identifier_names, deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:my_first_app/agrilog/model/class.dart';
// Giả định: Bạn đã thêm package google_generative_ai
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:my_first_app/util/config.dart'; 
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // 1. Danh sách lưu trữ lịch sử tin nhắn
  final List<Message> _messages = [];
  
  // 2. Controller để quản lý TextField
  final TextEditingController _textController = TextEditingController();
  
  // 3. Controller để cuộn ListView (tự động cuộn xuống tin nhắn mới nhất)
  final ScrollController _scrollController = ScrollController();

  final GenerativeModel _model = GenerativeModel(
      model: GeminiAI.GEMINI_MODEL, // Hoặc mô hình phù hợp khác
      apiKey: GeminiAI.GEMINI_API_KEY, 
      // Thêm dòng này để ép AI luôn nói tiếng Việt
      systemInstruction: Content.system(
        "BẮT BUỘC: Luôn luôn trả lời bằng tiếng Việt, ngay cả khi người dùng hỏi bằng ngôn ngữ khác. "
      ),
    );

  // 4. Khai báo các biến cho Speech-to-Text
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false; // Trạng thái sẵn sàng của STT
  bool _isListening = false;  // Trạng thái đang ghi âm

  // Trong class _ChatScreenState, thêm các biến sau:
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initSpeech();    
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _speechToText.stop(); // Tắt mic
    // 3. Xóa danh sách tin nhắn để hỗ trợ GC
    _messages.clear();
    _selectedImage = null;
    super.dispose();
  }

  // 1. Hàm chọn ảnh từ thư viện hoặc chụp hình
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 70, // Giảm chất lượng một chút để upload nhanh hơn
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  
  // Khởi tạo Speech-to-Text
  void _initSpeech() async {
    try{
      // Kiểm tra và yêu cầu quyền truy cập
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          // Cập nhật trạng thái lắng nghe (tùy chọn)
          if (status == 'listening') {
            setState(() => _isListening = true);
          } else if (status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          print('Lỗi STT: $error');
          setState(() => _isListening = false);
        },
      );
      setState(() {}); // Cập nhật UI sau khi khởi tạo
    }catch (e){
      print('Lỗi STT: $e');
    }
  }

  // Bắt đầu lắng nghe giọng nói
  void _startListening() async {
    if (_speechEnabled) {
      setState(() => _isListening = true);
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            // Dùng selection để con trỏ không bị nhảy về đầu dòng trên máy cũ
            _textController.value = TextEditingValue(
              text: result.recognizedWords,
              selection: TextSelection.collapsed(offset: result.recognizedWords.length),
            );
          });

          if (result.finalResult) {
            _stopListening();
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5), // Tự dừng nếu người dùng im lặng 5s
        localeId: 'vi_VN',
        cancelOnError: true, // Quan trọng cho máy cũ để không bị treo service
        listenMode: ListenMode.confirmation, // Chế độ này giúp nhận diện Tiếng Việt chính xác hơn
      );
    } else {
      // Xử lý khi STT không khả dụng
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dịch vụ nhận dạng giọng nói chưa sẵn sàng.")),
      );
    }
  }

  // Dừng lắng nghe
  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  String _cleanTextForSpeech(String text) {
    return text
        .replaceAll(RegExp(r'[*#_~]'), '') // Xóa dấu định dạng Markdown
        .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '') // Xóa các link web [tên](url)
        .replaceAll(RegExp(r' {2,}'), ' ') // Xóa khoảng trắng thừa
        .trim();
  }

  // GIẢ ĐỊNH: Logic gửi tin nhắn (thay thế bằng API Call thực tế)
  void _handleSubmitted(String text) async {
    // Thiết lập tham số Backoff
    const int maxAttempts = 4; // Thử tối đa 4 lần
    const Duration baseDelay = Duration(seconds: 2); // Bắt đầu chờ 2 giây

    // 1. Xóa nội dung nhập và đóng bàn phím
    _textController.clear();
    FocusScope.of(context).unfocus();
    File? imageToSend = _selectedImage; // Lưu lại ảnh hiện tại
    
    // ===============================================
    // *** THỰC HIỆN GỌI API THỰC TẾ ***
    try {
      // Chuẩn bị nội dung gửi đi (Text + Image)
      List<DataPart> imageParts = [];

      if (imageToSend != null) {
        final bytes = await imageToSend.readAsBytes();
        imageParts.add(DataPart('image/jpeg', bytes));
      }

      // Tạo nội dung kết hợp
      final prompt = [
        Content.multi([
          TextPart(text),
          ...imageParts,
        ])
      ];
      
      if(!(imageToSend == null && text.isEmpty)){
         // 2. Thêm tin nhắn người dùng và cập nhật UI
        setState(() {
          _selectedImage = null; // Xóa ảnh trên giao diện xem trước
          _messages.insert(0, Message(content: text, sender: MessageSender.user, imageFile: imageToSend, isTyping: false));
          // Thêm tin nhắn chờ (ví dụ: 'Đang gõ...')
          _messages.insert(0, Message(content: 'Đang trả lời...', sender: MessageSender.ai, isTyping: true)); 
        });
        _scrollToBottom();

        // Gọi hàm gửi tin nhắn của đối tượng chat
        // Gọi hàm tiện ích để xử lý thử lại
        final response = await _retryOnFailure(
          // Hàm API cần được gọi
          () async => await _model.generateContent(prompt),
          maxAttempts,
          baseDelay,
        );
        
        // Lấy nội dung phản hồi
        // ignore: unnecessary_null_comparison
        if (response != null) {
          final aiResponseText = response.text ?? 'Lỗi: Không nhận được phản hồi.';

          // 3. Cập nhật trạng thái: Xóa tin nhắn chờ và thêm phản hồi thực tế
          setState(() {
            // Giả định tin nhắn chờ nằm ở vị trí 0
            _messages.removeAt(0); 
            _messages.insert(0, Message(content: _cleanTextForSpeech(aiResponseText), sender: MessageSender.ai, isTyping: false));
          });
        }
      }
    } on Exception catch (e) {
      // Xử lý lỗi cuối cùng (sau khi đã thử lại 4 lần)
      String errorMessage = "Lỗi nghiêm trọng: Đã thử lại $maxAttempts lần nhưng không thành công. Vui lòng kiểm tra kết nối mạng hoặc thử lại sau.";
      
      if (e.toString().contains("overload")) {
          errorMessage = "AI đang quá tải do lượng truy cập lớn. Vui lòng chờ 30 giây rồi thử lại.";
      }

      setState(() {
        _messages.removeAt(0);
        _messages.insert(0, Message(content: errorMessage, sender: MessageSender.ai, isTyping: false));
      });
    }
    // ===============================================

    _scrollToBottom();
  }

  void _scrollToBottom() {
    // Đảm bảo cuộn tới tin nhắn mới nhất
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Widget Xây dựng Vùng Input (Dưới cùng)
  Widget _buildTextComposer() {
    return Column(
      children: [
        // Hiển thị ảnh xem trước nếu có
        if (_selectedImage != null)
        Container(
          height: 100,
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          child: Stack(
            children: [
              Image.file(_selectedImage!, height: 100, width: 100, fit: BoxFit.cover),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedImage = null),
                  child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget>[
              // Nút mở Menu chọn ảnh
              IconButton(
                icon: const Icon(Icons.photo_camera, color: Colors.orange),
                onPressed: () {
                  _showPickerMenu();
                },
              ),
              IconButton(
                icon: Icon(_isListening ? Icons.mic_off : Icons.mic, color: _isListening ? Colors.red : Colors.grey),
                onPressed: _speechEnabled ? (_isListening ? _stopListening : _startListening) : null,
              ),
              Flexible(
                child: TextField(
                  controller: _textController,
                  onSubmitted: _handleSubmitted,
                  decoration: const InputDecoration.collapsed(hintText: "Nhập tin nhắn hoặc gửi ảnh..."),
                  enabled: !_isListening,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Hàm xây dựng giao diện tin nhắn đã được nâng cấp
  Widget _buildMessage(Message message) {
    final bool isUser = message.sender == MessageSender.user;
    final bool isAi = message.sender == MessageSender.ai;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- AVATAR AI ---
          if (isAi)
            CircleAvatar(
              backgroundColor: Colors.orange.shade600,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
          if (isAi) const SizedBox(width: 8),

          Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  // --- LÀM ĐẸP PHẦN NGƯỜI DÙNG TẠI ĐÂY ---
                  gradient: isUser
                      ? LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isAi ? Colors.white : null,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 0),
                    bottomRight: Radius.circular(isUser ? 0 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: isAi ? Border.all(color: Colors.grey.shade200) : null,
                ),
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // --- PHẦN HÌNH ẢNH ---
                    if (message.imageFile != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            message.imageFile!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    // --- PHẦN VĂN BẢN ---
                    if (message.content.isNotEmpty)
                      isAi && !message.isTyping
                          ? MarkdownBody(
                              data: message.content,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(fontSize: 15, color: Colors.black87),
                              ),
                            )
                          : Text(
                              message.content,
                              style: TextStyle(
                                fontSize: 15,
                                color: isUser ? Colors.white : Colors.black87,
                                fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                  ],
                ),
              ),
            ],
          ),

          // --- AVATAR NGƯỜI DÙNG ---
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue.shade700),
              ),
            ),
        ],
      ),
    );
  }

  // Hàm thực hiện logic Exponential Backoff and Retry
  Future<GenerateContentResponse?> _retryOnFailure(
    Future<GenerateContentResponse> Function() apiCall,
    int maxRetries,
    Duration baseDelay,
  ) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // 1. Thực hiện cuộc gọi API được truyền vào
        final response = await apiCall();
        return response; // Thành công, thoát vòng lặp và trả về kết quả
        
      } catch (e) {
        // Kiểm tra xem lỗi có phải là lỗi tạm thời (ví dụ: quá tải, rate limit)
        // Trong trường hợp này, chúng ta giả định mọi GenerativeAIException đều là lỗi tạm thời.
        print('Lỗi lần $attempt: $e');

        if (attempt == maxRetries) {
          rethrow; // Thử lại lần cuối thất bại, ném lỗi ra ngoài để xử lý
        }

        // 2. Tính toán thời gian chờ theo cấp số nhân
        // Thời gian chờ = baseDelay * (2^ (attempt - 1)) + jitter (ngẫu nhiên)
        
        // Jitter (Thêm ngẫu nhiên 0 - 500ms) để tránh bão hòa máy chủ
        final int jitterMs = Random().nextInt(500); 
        
        final Duration delay = baseDelay * pow(2, attempt - 1).toInt() + Duration(milliseconds: jitterMs);

        print('Thử lại sau ${delay.inSeconds} giây...');
        await Future.delayed(delay);
      }
    }
    return null; // Không bao giờ đạt đến đây nếu logic đúng
  }

  // 4. Hàm hiển thị lựa chọn Nguồn ảnh
  void _showPickerMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Thư viện ảnh'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Máy ảnh'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50, title: const Text('AI Support'), backgroundColor: Colors.orange),
      body: Column(
        children: <Widget>[
          // Vùng hiển thị tin nhắn (Chiếm phần lớn không gian)
          Flexible(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              reverse: true, // Tin nhắn mới nhất nằm ở dưới cùng
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _buildMessage(_messages[index]),
            ),
          ),
          const Divider(height: 1.0),
          // Vùng nhập liệu
          _buildTextComposer(),
        ],
      ),
    );
  }
}