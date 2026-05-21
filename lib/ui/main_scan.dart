import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lấy danh sách các camera có sẵn trên thiết bị
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Kit Barcode Scanner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BarcodeScannerPage(cameras: cameras),
    );
  }
}

class BarcodeScannerPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const BarcodeScannerPage({super.key, required this.cameras});

  @override
  // ignore: library_private_types_in_public_api
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final ImagePicker _imagePicker = ImagePicker();
  late CameraController _cameraController;
  late BarcodeScanner _barcodeScanner;
  bool _isScanning = false;
  String _scanResult = 'No barcode detected';
  String _scanStorageResult = 'No barcode detected';

  @override
  void initState() {
    super.initState();
    _barcodeScanner = BarcodeScanner();
    _initializeCamera();
  }

  void reInitCamera(){
    _cameraController.dispose();
    _barcodeScanner.close();
    setState(() {
      _scanResult = "";
    });
    _barcodeScanner = BarcodeScanner();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = CameraController(
        widget.cameras.first, // Sử dụng camera đầu tiên
        ResolutionPreset.medium,
      );

      await _cameraController.initialize();
      setState(() {});
      _startScanning();
    } catch (e) {
      setState(() {
        _scanResult = "Error: $e";
      });
    }  
  }

  Future<void> _scanBarcodeFromImage() async {
    try {
      setState(() {
        _scanStorageResult = "";
      });

      // Chọn hình ảnh từ thư viện
      final XFile? imageFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);

      if (imageFile == null) {
        setState(() {
          _scanStorageResult = 'No image selected';
        });
        return;
      }

      // Chuyển hình ảnh thành InputImage
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);

      // Quét mã vạch
      final List<Barcode> barcodes =
          await _barcodeScanner.processImage(inputImage);

      if (barcodes.isEmpty) {
        setState(() {
          _scanStorageResult = 'No barcode found';
        });
      } else {
        setState(() {
          _scanStorageResult = barcodes.map((barcode) => barcode.rawValue ?? '').join('\n');
        });
      }
    } catch (e) {
      setState(() {
        _scanStorageResult = 'Error: $e';
      });
    } finally {
      reInitCamera();
    }
  }

  Future<void> _startScanning() async {
    _isScanning = true;

    _cameraController.startImageStream((CameraImage image) async {
      if (!_isScanning) return;

      // 1. Chuyển đổi format ảnh từ Camera sang ML Kit
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return;

      // 2. Lấy thông tin metadata (Quan trọng: Dùng InputImageMetadata thay cho InputImageData)
      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg, // Bạn nên tính toán rotation theo hướng thiết bị
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      // 3. Tạo InputImage từ bytes
      final inputImage = InputImage.fromBytes(
        bytes: _concatenatePlanes(image.planes), // Hàm gộp các plane bên dưới
        metadata: metadata,
      );

      try {
        final barcodes = await _barcodeScanner.processImage(inputImage);
        if (barcodes.isNotEmpty && _isScanning) {
          setState(() {
            _scanResult = barcodes.first.rawValue ?? 'No data';
            // Nếu muốn dừng sau khi quét trúng:
            // _isScanning = false;
            // _cameraController.stopImageStream();
          });
        }
      } catch (e) {
        print("Lỗi quét barcode: $e");
      }
    });
  }

  // Hàm bổ trợ để gộp các mặt phẳng ảnh (Planes) thành mảng Byte duy nhất
  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (_cameraController.value.isInitialized)
            AspectRatio(
              aspectRatio: _cameraController.value.aspectRatio,
              child: CameraPreview(_cameraController),
            )
          else
            const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: _scanBarcodeFromImage,
              child: const Text('Select Image from Gallery'),
            ),
          Padding(padding: const EdgeInsets.all(5), child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'From camera:\n$_scanResult',
                style: const TextStyle(fontSize: 18),
                ),
            )
          ),
          const SizedBox(height: 20),
          Padding(padding: const EdgeInsets.all(5), child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'From storage:\n$_scanStorageResult',
                style: const TextStyle(fontSize: 18),
              ),
            )
          ),
        ],
      ),
    );
  }
}