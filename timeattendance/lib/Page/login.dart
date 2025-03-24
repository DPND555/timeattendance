import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeattendance/Page/employee/homeemployee.dart';
import 'package:timeattendance/Page/maneger/homemaneger.dart';
import 'package:timeattendance/api.dart';
import 'package:timeattendance/provider.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool isKeyboardOpen = false;
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    checkLoginState();
  }

  Future<void> checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = Provider.of<Providerpreferrent>(context, listen: false);

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userid = prefs.getInt('userid') ?? 0;
    final employeejoblevel = prefs.getString('employeejoblevel') ?? '';
    final locationName = prefs.getString('locationName') ?? '';
    final latitude = prefs.getDouble('latitude') ?? 0.0;
    final longitude = prefs.getDouble('longitude') ?? 0.0;
    final radius = prefs.getInt('radius') ?? 0;
    final manegerid = prefs.getInt('manegerid') ?? 0;
    final String? jsonString = prefs.getString('calendar_list');

    // ถ้ามีข้อมูล calendar_data ให้อ่านค่าและแปลงเป็น List<String>
    List<String> calendarData = [];
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      calendarData = List<String>.from(jsonList);
    }

    // เมื่อเปิดแอปจะอัพเดตข้อมูลที่มีใน SharedPreferences ไปที่ provider
    provider.setUserid(userid);
    provider.setEmployeemobilephone(employeejoblevel);
    provider.setLocationName(locationName);
    provider.setLatitude(latitude);
    provider.setLongitude(longitude);
    provider.setRadius(radius);
    provider.setManagerid(manegerid);
    provider.setCalendar(calendarData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isLoggedIn) {
        if (employeejoblevel == 'Manager') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homepagemanager()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homepageemployee()),
          );
        }
      }
    });
  }

  // void getPlayerId() async {
  //   var status = await OneSignal.User.getOnesignalId();
  //   print("Player ID: $status");
  // }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom; // ตรวจจับคีย์บอร์ด
    isKeyboardOpen = keyboardHeight > 0; // ตรวจสอบว่าคีย์บอร์ดเปิดอยู่หรือไม่

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false, // ปิดการปรับขนาด UI อัตโนมัติ
        body: Stack(
          children: [
            // พื้นหลัง Gradient
            Container(
              height: screenHeight,
              decoration: const BoxDecoration(
                  // gradient: LinearGradient(
                  //   colors: [
                  //     Color.fromRGBO(255, 40, 61, 1),
                  //     Color.fromRGBO(229, 36, 55, 1),
                  //     Color.fromRGBO(191, 30, 46, 1)
                  //   ],
                  //   stops: [0.0, 0.1, 1.0],
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  // ),
                  image: DecorationImage(
                      image: AssetImage(
                        'lib/img/backgroun.jpg',
                      ),
                      fit: BoxFit.fill)),
            ),

            // 🔴 ข้อความที่ต้องการเพิ่มบนพื้นหลังสีแดง
            Align(
              alignment: Alignment.topCenter, // จัดตำแหน่งให้อยู่ตรงกลางด้านบน
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height *
                        0.13), // ปรับตำแหน่งลงมาตามต้องการ
              ),
            ),
            // Animated Positioned สำหรับ Container สีขาว
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: isKeyboardOpen
                  ? 0
                  : screenHeight * 0.35, // ขึ้นบนสุดเมื่อคีย์บอร์ดเปิด
              left: 0,
              right: 0,
              child: Container(
                height: screenHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: keyboardHeight),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.07),
                      Image.asset(
                        'lib/img/psslogo.png',
                        height: screenHeight * 0.05,
                      ),
                      SizedBox(height: screenHeight * 0.05),

                      // Username Field
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ชื่อผู้ใช้',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      textFieldContainer(
                        username,
                        "Example@Cityparking.co.th",
                        Icons.person_outline,
                        TextInputAction.next,
                        focusNode: _usernameFocusNode,
                        nextFocusNode:
                            _passwordFocusNode, // เมื่อกด Next ให้ไปช่องรหัสผ่าน
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Password Field
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'รหัสผ่าน',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      textFieldContainer(
                        password,
                        "*****",
                        Icons.lock_outline,
                        TextInputAction.done, // ช่องสุดท้ายใช้ `done`
                        focusNode: _passwordFocusNode, // FocusNode ของรหัสผ่าน
                        isPassword: true,
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // ปุ่ม Login
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 30),
                          ),
                          onPressed: () async {
                            if (username.text.isNotEmpty &&
                                password.text.isNotEmpty) {
                              await Api.login(
                                context: context,
                                username: username.text,
                                password: password.text,
                              );

                              username.clear();
                              password.clear();
                            } else {
                              AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      dismissOnTouchOutside: false,
                                      dismissOnBackKeyPress: false,
                                      body: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                            'lib/img/PSS Sticker-07.png',
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                          ),
                                          const Text(
                                            'กรุณากรอกข้อมูลให้ครบถ้วน',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                      btnCancelOnPress: () {},
                                      btnCancelText: 'OK')
                                  .show();
                            }
                          },
                          child: const Text(
                            "เข้าสู่ระบบ",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // SizedBox(height: screenHeight * 0.03),

                      // // ลืมรหัสผ่าน
                      // const Align(
                      //   alignment: Alignment.center,
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Text(
                      //         'หากลืมรหัสผ่าน ',
                      //         style: TextStyle(
                      //             color: Colors.grey,
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.bold),
                      //       ),
                      //       Text(
                      //         'กดที่นี่เพื่อกู้คืน ?',
                      //         style: TextStyle(
                      //             color: Colors.redAccent,
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.bold),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ฟังก์ชันสร้าง TextField
  Widget textFieldContainer(
    TextEditingController controller,
    String hint,
    IconData icon,
    TextInputAction textInputAction, {
    bool isPassword = false,
    FocusNode? focusNode, // รับ FocusNode เป็นพารามิเตอร์
    FocusNode? nextFocusNode, // FocusNode ถัดไป
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        // เมื่อโฟกัสเปลี่ยน ให้รีเฟรช UI
        setState(() {});
      },
      child: Builder(
        builder: (context) {
          bool hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              boxShadow: hasFocus
                  ? [
                      // เงาเข้มขึ้นเมื่อได้รับโฟกัส
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.2),
                        offset: const Offset(4, 4),
                        blurRadius: 4,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4, -4),
                        blurRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.grey.shade500,
                        offset: const Offset(3, 3),
                        blurRadius: 4,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-3, -3),
                        blurRadius: 2,
                      ),
                    ],
            ),
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: TextInputType.emailAddress,
              textInputAction: textInputAction, // TextInputAction.next,
              focusNode: focusNode,
              onEditingComplete: () {
                if (nextFocusNode != null) {
                  FocusScope.of(context)
                      .requestFocus(nextFocusNode); // ไปช่องถัดไป
                } else {
                  FocusScope.of(context).unfocus(); // ปิดคีย์บอร์ด
                }
              },
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: Icon(icon, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.redAccent.shade400, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}

//

// import 'package:flutter/material.dart';
// import 'package:timeattendance/api.dart';

// class LogInPage extends StatefulWidget {
//   const LogInPage({super.key});

//   @override
//   State<LogInPage> createState() => _LogInPageState();
// }

// class _LogInPageState extends State<LogInPage> {
//   final username = TextEditingController();
//   final password = TextEditingController();
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.grey[100],
//         body: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // SizedBox(height: MediaQuery.of(context).size.height * 0.1),
//                   Card(
//                     color: Colors.white,
//                     elevation: 15,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Image.asset(
//                             'lib/img/psslogo.png',
//                             height: MediaQuery.of(context).size.height * 0.05,
//                           ),
//                           const Text(
//                             "Login to Cityparking",
//                             style: TextStyle(
//                               fontFamily: 'Bitter',
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                           TextField(
//                             controller: username,
//                             cursorColor: Colors.black,
//                             textInputAction: TextInputAction.next,
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey[600]!,
//                                   width: 2,
//                                 ),
//                               ),
//                               hintText: 'Enter your email',
//                               prefixIcon: const Icon(Icons.person_outline),
//                             ),
//                           ),
//                           TextField(
//                             controller: password,
//                             cursorColor: Colors.black,
//                             obscureText: true,
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey[600]!,
//                                   width: 2,
//                                 ),
//                               ),
//                               hintText: 'Enter your password',
//                               prefixIcon: const Icon(Icons.lock_outline),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: MyColors.red,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 15),
//                               ),
//                               onPressed: () async {
//                                 // if (username.text.isEmpty &&
//                                 //     password.text.isEmpty) {
//                                 //   Fluttertoast.showToast(
//                                 //     msg: 'กรุณากรอกข้อมูลให้ครถ้วน',
//                                 //     toastLength: Toast.LENGTH_LONG,
//                                 //     gravity: ToastGravity.BOTTOM,
//                                 //     backgroundColor: Colors.white,
//                                 //     textColor: Colors.black,
//                                 //     fontSize: 16.0,
//                                 //   );
//                                 // } else {
//                                 //   Api.login(
//                                 //     context: context,
//                                 //     username: username.text,
//                                 //     password: password.text,
//                                 //   );
//                                 //   username.clear();
//                                 //   password.clear();
//                                 // }
//                                 await Api.login(
//                                   context: context,
//                                   username: '',
//                                   password: '',
//                                 );
//                               },
//                               child: const Text(
//                                 "Login",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// //
