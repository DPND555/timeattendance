import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeattendance/Page/employee/homeemployee.dart';
import 'package:timeattendance/Page/login.dart';
import 'package:timeattendance/Page/maneger/homemaneger.dart';
import 'package:timeattendance/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.initialize(
      "38019e3c-ffd3-42e6-83a4-13a5018254b6"); // ใส่ App ID ที่ได้จาก OneSignal Dashboard

  // ขอ permission สำหรับ notification
  OneSignal.Notifications.requestPermission(true);

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print("Notification received in foreground: ${event.notification.body}");
    // ถ้าไม่อยากให้แสดง notification นี้ใน foreground ให้เรียก event.preventDefault();
  });

  // Listener สำหรับตอนกด notification
  OneSignal.Notifications.addClickListener((event) {
    print("Notification clicked: ${event.notification.body}");
    // ใส่ logic เช่น เปิดหน้าใหม่เมื่อกด notification
  });

  

  await initializeDateFormatting('th_TH', '');
  Intl.defaultLocale = 'th_TH';
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      MultiProvider(
        providers: [
          // ใช้ ChangeNotifierProvider สำหรับ Providerpreferrent
          ChangeNotifierProvider(create: (_) => Providerpreferrent()),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LogInPage(),
      routes: {
        '/login': (context) => const LogInPage(),
        '/homemanager': (context) => const Homepagemanager(),
        '/homeemployee': (context) => const Homepageemployee(),
      },
    );
  }
}

// import 'dart:math';

// import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// late List<CameraDescription> cameras;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   cameras = await availableCameras();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: CameraScreen(),
//     );
//   }
// }

// class CameraScreen extends StatefulWidget {
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   late CameraController _controller;
//   final FaceDetector _faceDetector = FaceDetector(
//     options: FaceDetectorOptions(
//       enableContours: false, // ปิดถ้าไม่ต้องการ contour
//       enableLandmarks: false, // ปิดถ้าไม่ต้องการ landmarks
//       enableClassification: false, // ปิดถ้าไม่ต้องการ classification
//       minFaceSize: 0.15, // ขนาดใบหน้าขั้นต่ำที่ตรวจจับได้
//       performanceMode: FaceDetectorMode.accurate, // หรือ fast ถ้าต้องการเร็ว
//     ),
//   );
//   bool _isFaceInCircle = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = CameraController(cameras[0], ResolutionPreset.high);
//     _controller.initialize().then((_) {
//       if (mounted) {
//         setState(() {});
//         _startFaceDetection(); // เริ่มตรวจจับใบหน้า
//       }
//     });
//   }

//   void _startFaceDetection() {
//     int frameCount = 0;
//     _controller.startImageStream((CameraImage image) async {
//       frameCount++;
//       if (frameCount % 10 != 0)
//         return; // ประมวลผลทุกๆ 10 เฟรม (~3 ครั้งต่อวินาที ถ้า 30 FPS)

//       final inputImage = _convertCameraImage(image);
//       final faces = await _faceDetector.processImage(inputImage);
//       print("Detected faces: ${faces.length}");
//       if (faces.isNotEmpty) {
//         final face = faces.first;
//         print("Face bounding box: ${face.boundingBox}");
//         _checkIfFaceInCircle(face.boundingBox);
//       } else {
//         setState(() {
//           _isFaceInCircle = false;
//         });
//       }
//     });
//   }

//   InputImage _convertCameraImage(CameraImage image) {
//     print("Image width: ${image.width}, height: ${image.height}");
//     print("Planes: ${image.planes.length}");
//     final WriteBuffer allBytes = WriteBuffer();
//     for (Plane plane in image.planes) {
//       allBytes.putUint8List(plane.bytes);
//     }
//     final bytes = allBytes.done().buffer.asUint8List();
//     print("Bytes length: ${bytes.length}");
//     final Size imageSize =
//         Size(image.width.toDouble(), image.height.toDouble());
//     final InputImageRotation rotation =
//         InputImageRotation.rotation0deg; // อาจต้องปรับตามทิศกล้อง
//     final InputImageFormat format =
//         InputImageFormat.nv21; // อาจต้องเปลี่ยนตามแพลตฟอร์ม

//     return InputImage.fromBytes(
//       bytes: bytes,
//       metadata: InputImageMetadata(
//         size: imageSize,
//         rotation: rotation,
//         format: format,
//         bytesPerRow: image.planes[0].bytesPerRow,
//       ),
//     );
//   }

//   void _checkIfFaceInCircle(Rect boundingBox) {
//     double circleRadius = 100;
//     double circleCenterX = MediaQuery.of(context).size.width / 2;
//     double circleCenterY = MediaQuery.of(context).size.height / 2;

//     double faceCenterX = boundingBox.left + (boundingBox.width / 2);
//     double faceCenterY = boundingBox.top + (boundingBox.height / 2);
//     double distance = sqrt(pow(faceCenterX - circleCenterX, 2) +
//         pow(faceCenterY - circleCenterY, 2));

//     print("Face center: ($faceCenterX, $faceCenterY)");
//     print("Circle center: ($circleCenterX, $circleCenterY)");
//     print("Distance: $distance");

//     setState(() {
//       _isFaceInCircle = distance < circleRadius &&
//           boundingBox.width < 200 &&
//           boundingBox.height < 200;
//       print("Is face in circle? $_isFaceInCircle");
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_controller.value.isInitialized) {
//       return Container();
//     }
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         CameraPreview(_controller),
//         Container(
//           width: 200,
//           height: 200,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: _isFaceInCircle ? Colors.green : Colors.white,
//               width: 2,
//             ),
//           ),
//         ),
//         Positioned(
//           bottom: 50,
//           child: Text(
//             _isFaceInCircle
//                 ? "ใบหน้าอยู่ในวงกลม!"
//                 : "กรุณาขยับใบหน้าให้อยู่ในวงกลม",
//             style: TextStyle(
//               color: _isFaceInCircle ? Colors.green : Colors.red,
//               fontSize: 20,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _faceDetector.close();
//     super.dispose();
//   }
// }
