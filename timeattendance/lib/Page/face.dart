import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:timeattendance/api.dart';
import 'package:timeattendance/provider.dart';

class FaceScanPage extends StatefulWidget {
  const FaceScanPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.datetime,
  });
  final double latitude;
  final double longitude;
  final String distance;
  final String datetime;

  @override
  _FaceScanPageState createState() => _FaceScanPageState();
}

class _FaceScanPageState extends State<FaceScanPage> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  String? base64Image;
  bool _isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);

    _controller = CameraController(frontCamera, ResolutionPreset.veryHigh);
    await _controller!.initialize();

    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _takePicture() async {
    final provider = Provider.of<Providerpreferrent>(context, listen: false);
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile file = await _controller!.takePicture();
      final bytes = await File(file.path).readAsBytes();

      setState(() {
        base64Image = base64Encode(bytes);
      });
      Api.scanface(
        face1: base64Image!,
        face2: provider.employeeImage,
        latitude: widget.latitude.toString(),
        longitude: widget.longitude.toString(),
        distance: widget.distance,
        datetime: widget.datetime,
        context: context,
      );
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'lib/img/PSS Sticker-11.png',
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Text(
              "$e",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        btnCancelOnPress: () {
          Navigator.pop(context);
        },
        btnCancelText: 'OK',
      ).show();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.red,
        title: const Text('สแกนใบหน้า', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          if (_isCameraInitialized)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(-1.0, 1.0), // กลับภาพแนวนอน
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: CameraPreview(_controller!)),
            )
          else
            Center(
                child: LoadingAnimationWidget.discreteCircle(
              color: Colors.greenAccent,
              secondRingColor: Colors.yellowAccent,
              thirdRingColor: Colors.redAccent,
              size: MediaQuery.of(context).size.height * 0.08,
            )),
          Positioned.fill(
            child: CustomPaint(painter: FaceOverlayPainter()),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: FloatingActionButton.extended(
                onPressed: _isButtonDisabled
                    ? null
                    : () async {
                        setState(() => _isButtonDisabled = true);
                        try {
                          _takePicture();
                        } catch (e) {
                          print("Error: $e");
                          if (mounted) {
                            setState(() => _isButtonDisabled = false);
                          }
                        }
                      },
                backgroundColor:
                    _isButtonDisabled ? Colors.grey : Colors.redAccent,
                icon:
                    const Icon(Icons.camera_alt_outlined, color: Colors.white),
                label: const Text(
                  'ถ่ายรูป',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.6);

    double diameter = size.width * 0.85; // ใช้ขนาดเดียวกันเพื่อให้เป็นวงกลม
    double radius = diameter / 2;

    Offset center = Offset(size.width / 2, size.height / 2 - 50);

    Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    Path facePath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    Path finalPath =
        Path.combine(PathOperation.difference, backgroundPath, facePath);

    canvas.drawPath(finalPath, overlayPaint);
    canvas.drawCircle(center, radius, paint); // ใช้ drawCircle แทน drawOval
  }

  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) => false;
}



// class _FaceScanPageState extends State<FaceScanPage> {
//   CameraController? _controller;
//   bool _isCameraInitialized = false;
//   String? base64Image;
//   bool _isButtonDisabled = false; // ตัวแปรเก็บสถานะปุ่ม

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final frontCamera = cameras.firstWhere(
//         (camera) => camera.lensDirection == CameraLensDirection.front);

//     _controller = CameraController(frontCamera, ResolutionPreset.veryHigh);
//     await _controller!.initialize();

//     if (mounted) {
//       setState(() {
//         _isCameraInitialized = true;
//       });
//     }
//   }

//   Future<void> _takePicture() async {
//     final provider = Provider.of<Providerpreferrent>(context, listen: false);
//     if (_controller == null || !_controller!.value.isInitialized) {
//       return;
//     }

//     try {
//       final XFile file = await _controller!.takePicture();
//       final bytes = await File(file.path).readAsBytes();

//       setState(() {
//         base64Image = base64Encode(bytes);
//       });
//       Api.scanface(
//         face1: base64Image!,
//         face2: provider.employeeImage,
//         latitude: widget.latitude.toString(),
//         longitude: widget.longitude.toString(),
//         distance: widget.distance,
//         datetime: widget.datetime,
//         context: context,
//       );
//     } catch (e) {
//       AwesomeDialog(
//               context: context,
//               dialogType: DialogType.error,
//               dismissOnTouchOutside: false,
//               dismissOnBackKeyPress: false,
//               body: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Image.asset(
//                     'lib/img/PSS Sticker-11.png',
//                     height: MediaQuery.of(context).size.height * 0.1,
//                   ),
//                   Text(
//                     "$e", // title จะถูกใส่ที่นี่
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//               btnCancelOnPress: () {
//                 Navigator.pop(context);
//               },
//               btnCancelText: 'OK')
//           .show();
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("สแกนใบหน้า")),
//       body: Stack(
//         children: [
//           if (_isCameraInitialized)
//             Positioned.fill(child: CameraPreview(_controller!))
//           else
//             Center(
//                 child: LoadingAnimationWidget.discreteCircle(
//               color: Colors.greenAccent,
//               secondRingColor: Colors.yellowAccent,
//               thirdRingColor: Colors.redAccent,
//               size: MediaQuery.of(context).size.height * 0.08,
//             )),
//           if (_isCameraInitialized)
//             Positioned.fill(
//               child: CustomPaint(painter: FaceOverlayPainter()),
//             ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 30),
//               child: FloatingActionButton(
//                 onPressed: _isButtonDisabled
//                     ? null
//                     : () async {
//                         setState(() =>
//                             _isButtonDisabled = true); // ปิดปุ่มทันทีหลังจากกด

//                         try {
//                           _takePicture();
//                         } catch (e) {
//                           print("Error: $e");
//                           if (mounted) {
//                             setState(() => _isButtonDisabled = false);
//                           }
//                         }
//                       },
//                 backgroundColor:
//                     _isButtonDisabled ? Colors.grey : Colors.redAccent,
//                 child: Icon(Icons.camera, color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class FaceOverlayPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.greenAccent
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4.0;

//     Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.6);

//     Rect faceRect = Rect.fromCenter(
//       center: Offset(size.width / 2, size.height / 2 - 50),
//       width: size.width * 0.8,
//       height: size.height * 0.6,
//     );

//     Path backgroundPath = Path()
//       ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
//     Path facePath = Path()..addOval(faceRect);
//     Path finalPath =
//         Path.combine(PathOperation.difference, backgroundPath, facePath);

//     canvas.drawPath(finalPath, overlayPaint);
//     canvas.drawOval(faceRect, paint);
//   }

//   @override
//   bool shouldRepaint(FaceOverlayPainter oldDelegate) => false;
// }
