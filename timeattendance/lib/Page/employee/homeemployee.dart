import 'dart:convert';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:timeattendance/Page/map.dart';
import 'package:timeattendance/api.dart';
import 'package:timeattendance/provider.dart';

class Homepageemployee extends StatefulWidget {
  const Homepageemployee({super.key});

  @override
  State<Homepageemployee> createState() => _HomepageemployeeState();
}

class _HomepageemployeeState extends State<Homepageemployee> {
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData(); // เรียก API ทุกครั้งที่หน้าแสดง
  }

  Future<void> _fetchData() async {
    if (_isLoading) return; // ป้องกันการเรียกซ้ำ
    setState(() => _isLoading = true);

    try {
      // เรียก API
      await Api.employeeme(context: context);
    } catch (e) {
      if (context.mounted) {
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
                      '$e',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                btnCancelOnPress: () {},
                btnCancelText: 'OK')
            .show();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Future<void> _fetchData2() async {
  //   if (_isLoading) return;
  //   setState(() => _isLoading = true);

  //   try {
  //     var url = Uri.parse(
  //         'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/today');
  //     var response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> data = jsonDecode(response.body);
  //       List<dynamic> attendanceList = data["attendance"];

  //       // เก็บ `attendance_id` มากสุด เฉพาะ `In`
  //       Map<String, Map<String, dynamic>> employeeMaxAttendanceIn = {};

  //       for (var record in attendanceList) {
  //         String name = record["employee_name"];
  //         int attendanceId = record["attendance_id"] ?? 0;
  //         String statusApprove =
  //             record["status_approve_in_out"]?.toString().trim() ?? "";

  //         // รับเฉพาะ `In`
  //         if (statusApprove == "In") {
  //           if (!employeeMaxAttendanceIn.containsKey(name) ||
  //               attendanceId >
  //                   employeeMaxAttendanceIn[name]!['attendance_id']) {
  //             // ลบ key "faces" ถ้ามี
  //             Map<String, dynamic> cleanedRecord = Map.from(record);
  //             cleanedRecord.remove("faces");
  //             cleanedRecord.remove("picture_in");

  //             employeeMaxAttendanceIn[name] = cleanedRecord;
  //           }
  //         }
  //       }

  //       setState(() {
  //         _dataListIn = employeeMaxAttendanceIn.values
  //             .toList(); // เก็บเฉพาะ In ที่ลบ faces แล้ว
  //       });
  //     } else {
  //       print(
  //           "เกิดข้อผิดพลาด: ${response.statusCode} - ${response.reasonPhrase}");
  //     }
  //   } catch (e) {
  //     print("เกิดข้อผิดพลาดในการเชื่อมต่อ: $e");
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  // bool _isSubscribed = false;

  // void _checkSubscriptionStatus() async {
  //   bool? subscribed = OneSignal.User.pushSubscription.optedIn;
  //   setState(() {
  //     _isSubscribed = subscribed!;
  //   });
  // }

  // void _toggleSubscription(bool value) async {
  //   if (value) {
  //     OneSignal.User.pushSubscription.optIn(); // เปิดการสมัครรับ
  //     print("User subscribed to notifications");
  //   } else {
  //     OneSignal.User.pushSubscription.optOut(); // ปิดการสมัครรับ
  //     print("User unsubscribed from notifications");
  //   }
  //   setState(() {
  //     _isSubscribed = value;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Providerpreferrent>(context, listen: false);

    Uint8List bytes = base64Decode(provider.employeeImage);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    String formattedCheckIn =
        provider.checkin.replaceAll(RegExp(r'[-:\s]'), '');
    String formattedCheckOut =
        provider.checkout.replaceAll(RegExp(r'[-:\s]'), '');
    int checkin = int.tryParse(formattedCheckIn) ?? 0;
    int checkout = int.tryParse(formattedCheckOut) ?? 0;

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.transparent,
              highlightElevation: 0,
              elevation: 0,
              onPressed: () {
                AwesomeDialog(
                        context: context,
                        dialogType: DialogType.info,
                        dismissOnTouchOutside: false,
                        dismissOnBackKeyPress: false,
                        body: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'lib/img/PSS Sticker-03.png',
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                            const Text(
                              'ออกจากระบบ',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        btnOkOnPress: () {
                          Api.logout(context: context);
                        },
                        btnOkText: 'ออกจากระบบ',
                        btnCancelOnPress: () {},
                        btnCancelText: 'ยกเลิก')
                    .show();
              },
              child: const Icon(
                Icons.login_outlined,
                color: Colors.white,
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            body: provider.employeeImage.isNotEmpty
                ? Stack(
                    children: [
                      // พื้นหลังแบบ Gradient
                      Container(
                        height: screenHeight * 0.35,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(255, 40, 61, 1),
                              Color.fromRGBO(229, 36, 55, 1),
                              Color.fromRGBO(191, 30, 46, 1)
                            ],
                            stops: [0.0, 0.4, 1.0], // ควบคุมสัดส่วนสี
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: screenHeight * 0.07),

                          // Avatar + ชื่อ
                          Center(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  foregroundImage: MemoryImage(bytes),
                                  radius: screenHeight * 0.08,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  provider.employeename,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          // เมนูการทำงาน
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25),
                                ),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.04),
                                  // Card เมนู
                                  Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      children: [
                                        checkin > checkout
                                            ? ListTile(
                                                title: Center(
                                                    child: Text(
                                                        'เข้างานเมื่อ: ${provider.checkin}',
                                                        style: const TextStyle(
                                                            fontSize: 15))),
                                                trailing: const Icon(
                                                    Icons.verified,
                                                    color: Colors.greenAccent),
                                              )
                                            : const SizedBox.shrink(),
                                        checkin > checkout
                                            ? const Divider(height: 1)
                                            : const SizedBox.shrink(),
                                        ListTile(
                                          leading: const Icon(
                                              Icons.calendar_today,
                                              color: Colors.black),
                                          title: const Text('ดูตารางงาน'),
                                          trailing: const Icon(
                                              Icons.arrow_forward_ios_rounded),
                                          onTap: () {
                                            AwesomeDialog(
                                                    context: context,
                                                    dialogType:
                                                        DialogType.error,
                                                    dismissOnTouchOutside:
                                                        false,
                                                    dismissOnBackKeyPress:
                                                        false,
                                                    body: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Image.asset(
                                                          'lib/img/PSS Sticker-11.png',
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                        ),
                                                        const Text(
                                                          "ยังไม่พร้อมใช้งาน", // title จะถูกใส่ที่นี่
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                    btnCancelOnPress: () {},
                                                    btnCancelText: 'OK')
                                                .show();
                                          },
                                        ),
                                        // const Divider(height: 1),
                                        // ListTile(
                                        //   leading: const Icon(
                                        //       Icons.calendar_today,
                                        //       color: Colors.black),
                                        //   title: const Text('ดูตารางงาน'),
                                        //   trailing: const Icon(
                                        //       Icons.arrow_forward_ios_rounded),
                                        //   onTap: () {
                                        //     // Navigator.push(
                                        //     //     context,
                                        //     //     MaterialPageRoute(
                                        //     //         builder: (context) =>
                                        //     //             const AttendanceSummaryPage()));
                                        //   },
                                        // ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  // Switch(
                                  //   value: _isSubscribed,
                                  //   onChanged: (value) {
                                  //     _toggleSubscription(value);
                                  //   },
                                  // ),
                                  // ปุ่มลงเวลางาน
                                  SizedBox(
                                    width: screenWidth * 1,
                                    height: screenHeight * 0.1,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MapsPage()),
                                        );
                                        // Api.fetchCalendar();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.greenAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: const Text(
                                        'ลงเวลางาน',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.03),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Center(
                    child: LoadingAnimationWidget.discreteCircle(
                    color: Colors.greenAccent,
                    secondRingColor: Colors.yellowAccent,
                    thirdRingColor: Colors.redAccent,
                    size: screenHeight * 0.08,
                  ))));
  }
}
