import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:timeattendance/provider.dart';
import '../../api.dart';

class AllmemBerin extends StatefulWidget {
  const AllmemBerin({super.key});

  @override
  State<AllmemBerin> createState() => _AllmemBerinState();
}

class _AllmemBerinState extends State<AllmemBerin> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _dataListPending = [];
  List<Map<String, dynamic>> _dataListApprove = [];
  List<Map<String, dynamic>> _dataListReject = [];
  String? selectedTime; // เวลาที่เลือก
  String? selectedId; // ID ของช่วงเวลาที่เลือก
  final note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      var url = Uri.parse(
          'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/today');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> attendanceList = data["attendance"];

        // แยก `attendance_id` มากสุด โดยแยก In / Out
        Map<String, Map<String, dynamic>> employeeMaxAttendanceIn = {};

        for (var record in attendanceList) {
          String name = record["employee_name"];
          int attendanceId = record["attendance_id"] ?? 0;
          String statusApprove =
              record["status_approve_in_out"]?.toString().trim() ?? "";

          // แยก `In` และ `Out`
          if (statusApprove == "In") {
            if (!employeeMaxAttendanceIn.containsKey(name) ||
                attendanceId >
                    employeeMaxAttendanceIn[name]!['attendance_id']) {
              employeeMaxAttendanceIn[name] = record;
            }
          }
        }

        // คัดกรองข้อมูลที่ต้องการ
        List<Map<String, dynamic>> filteredPending = employeeMaxAttendanceIn
            .values
            .where((record) => record["status"]?.toString().trim() == "Pending")
            .toList();

        List<Map<String, dynamic>> filteredApprove = employeeMaxAttendanceIn
            .values
            .where((record) => record["status"]?.toString().trim() == "Approve")
            .toList();

        List<Map<String, dynamic>> filteredReject = employeeMaxAttendanceIn
            .values
            .where((record) => record["status"]?.toString().trim() == "Reject")
            .toList();

        setState(() {
          _dataListPending = filteredPending;
          _dataListApprove = filteredApprove;
          _dataListReject = filteredReject;
        });
        // debugPrint('$_dataListPending');
        // debugPrint("$_dataListApprove", wrapWidth: 1);
        // debugPrint("$_dataListReject");
      } else {
        print(
            "เกิดข้อผิดพลาด: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการเชื่อมต่อ: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    await _fetchData();
  }

  Widget _buildSection(
      String title, List<Map<String, dynamic>> dataList, Color color,
      {bool showActions = false}) {
    return dataList.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(255, 40, 40, 1),
                        Color.fromRGBO(229, 36, 61, 1),
                        Color.fromRGBO(191, 30, 46, 1),
                      ],
                      stops: [0.0, 0.4, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ), // ฟ้าเทา
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    var item = dataList[index];
                    DateTime parsedDate = DateTime.parse(item["check_in_time"]);
                    String formattedDate =
                        DateFormat("HH:mm:ss").format(parsedDate);
                    final provider =
                        Provider.of<Providerpreferrent>(context, listen: false);

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                            foregroundImage:
                                MemoryImage(base64Decode(item["picture_in"])),
                            radius: MediaQuery.of(context).size.width * 0.07),
                        title: Text('${item["employee_name"]} ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Row(
                          children: [
                            Text(
                              'เวลาเข้างาน: $formattedDate',
                            ),
                          ],
                        ),
                        trailing: showActions
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green[100],
                                    child: IconButton(
                                      icon: const Icon(Icons.check,
                                          color: Color(0xFF4CAF50)), // เขียวสด
                                      onPressed: () {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.info,
                                          animType: AnimType.scale,
                                          dialogBackgroundColor: Colors.white,
                                          borderSide: BorderSide(
                                              color: Colors.blue, width: 2),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              1,
                                          padding: const EdgeInsets.all(20),
                                          body: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 15),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'ยืนยันการอนุมัติการเข้างาน',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 20),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300),
                                                    color: Colors.grey.shade50,
                                                  ),
                                                  child:
                                                      DropdownButtonFormField<
                                                          Map<String, String>>(
                                                    value: selectedTime !=
                                                                null &&
                                                            selectedId != null
                                                        ? {
                                                            "id": selectedId!,
                                                            "time":
                                                                selectedTime!
                                                          }
                                                        : null,
                                                    decoration:
                                                        const InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 10),
                                                      border: InputBorder.none,
                                                      hintText:
                                                          'กรุณาเลือกเวลา',
                                                    ),
                                                    icon: const Icon(
                                                        Icons.arrow_drop_down,
                                                        color: Colors.blue),
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 16),
                                                    onChanged:
                                                        (Map<String, String>?
                                                            value) {
                                                      setState(() {
                                                        selectedId = value?[
                                                            "id"]; // เก็บ ID
                                                        selectedTime = value?[
                                                            "time"]; // เก็บช่วงเวลา
                                                      });
                                                    },
                                                    items: provider.calendarlist
                                                        .map((time) {
                                                      String id = time
                                                          .split(" , ")[0]
                                                          .replaceAll("id ",
                                                              ""); // ดึง ID
                                                      String formattedTime =
                                                          time.split(" , ")[
                                                              1]; // ดึงช่วงเวลา
                                                      return DropdownMenuItem(
                                                        value: {
                                                          "id": id,
                                                          "time": formattedTime
                                                        }, // ส่งเป็น Map<String, String>
                                                        child: Text(
                                                            formattedTime), // แสดงแค่เวลา
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          btnOk: ElevatedButton(
                                            onPressed: () {
                                              Api.approve(
                                                context: context,
                                                recordid: item["attendance_id"],
                                                calendaid: selectedId!,
                                                employeeid: item["employee_id"],
                                                message: 'ยืนยันการเข้างาน',
                                                onSuccess: () {
                                                  _fetchData();
                                                  Navigator.of(context).pop();
                                                },
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                            ),
                                            child: const Text(
                                              'ยืนยัน',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          btnCancel: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              foregroundColor: Colors.black87,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                            ),
                                            child: const Text(
                                              'ยกเลิก',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ).show();
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.013),
                                  CircleAvatar(
                                    backgroundColor: Colors.red[100],
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Color(0xFFF44336)), // แดงสด
                                      onPressed: () {
                                        AwesomeDialog(
                                          context: context,
                                          body: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                            ),
                                            child: Column(
                                              children: [
                                                const Text(
                                                    "ยืนยันไม่อนุมัติการเข้างาน"),
                                                TextField(
                                                  maxLines: null,
                                                  controller: note,
                                                ),
                                              ],
                                            ),
                                          ),
                                          dialogType: DialogType.info,
                                          btnOkText: "ยืนยัน",
                                          btnOkOnPress: () {
                                            if (note.text.isNotEmpty) {
                                              String checkInLocation =
                                                  item["check_in_location"];
                                              List<String> locationParts =
                                                  checkInLocation.split(",");
                                              double latitude = double.tryParse(
                                                      locationParts[0]) ??
                                                  0.0;
                                              double longitude =
                                                  double.tryParse(
                                                          locationParts[1]) ??
                                                      0.0;
                                              Api.rejectin(
                                                  context: context,
                                                  recordid:
                                                      item["attendance_id"],
                                                  notes: note.text,
                                                  latitude: latitude.toString(),
                                                  longitude:
                                                      longitude.toString(),
                                                  checkindistance:
                                                      item["check_in_distance"],
                                                  checkintime:
                                                      item["check_in_time"],
                                                  picturein: item["picture_in"],
                                                  empid: item["employee_id"]
                                                      .toString(),
                                                  empname:
                                                      item["employee_name"],
                                                  createuid: item["employee_id"]
                                                      .toString(),
                                                  onSuccess: () {
                                                    _fetchData(); // อัปเดตข้อมูลหลังจากอนุมัติ
                                                  });
                                              note.clear();
                                            } else {
                                              AwesomeDialog(
                                                context: context,
                                                dialogType: DialogType.warning,
                                                body: Column(
                                                  children: [
                                                    Image.asset(
                                                      'lib/img/PSS Sticker-07.png',
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                    ),
                                                    const Text(
                                                      "กรุณากรอกเหตุผลก่อนกดยืนยัน",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                                btnOkOnPress: () {},
                                                btnOkText: "ตกลง",
                                              ).show();
                                            }
                                          },
                                          btnCancelText: "ยกเลิก",
                                          btnCancelOnPress: () {
                                            note.clear();
                                          },
                                        ).show();
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    bool isAllEmpty = _dataListPending.isEmpty &&
        _dataListApprove.isEmpty &&
        _dataListReject.isEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.red,
        title: const Text('การเข้างาน', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.discreteCircle(
                color: Colors.greenAccent,
                secondRingColor: Colors.yellowAccent,
                thirdRingColor: Colors.redAccent,
                size: MediaQuery.of(context).size.height * 0.08,
              ),
            )
          : Container(
              color: const Color.fromRGBO(245, 247, 255, 1),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: RefreshIndicator(
                onRefresh: _refreshData,
                backgroundColor: Colors.white,
                color: Colors.redAccent,
                child: isAllEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'ไม่มีข้อมูล',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const Text(
                              'การเข้างานของพนักงาน',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            Image.asset(
                              'lib/img/PSS Sticker-09.png',
                              height: MediaQuery.of(context).size.height * 0.15,
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        children: [
                          _buildSection('พนักงานที่ยังไม่อนุมัติ',
                              _dataListPending, Colors.transparent,
                              showActions: true),
                          _buildSection('พนักงานที่อนุมัติแล้ว',
                              _dataListApprove, Colors.transparent),
                          _buildSection('พนักงานที่ปฎิเสธแล้ว', _dataListReject,
                              Colors.transparent),
                        ],
                      ),
              ),
            ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.red,
//         title: const Text('การเข้างาน', style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: _isLoading
//           ? Center(
//               child: LoadingAnimationWidget.discreteCircle(
//               color: Colors.greenAccent,
//               secondRingColor: Colors.yellowAccent,
//               thirdRingColor: Colors.redAccent,
//               size: MediaQuery.of(context).size.height * 0.08,
//             ))
//           : Container(
//               color: const Color.fromRGBO(245, 247, 255, 1),
//               width: MediaQuery.of(context).size.width * 1,
//               height: MediaQuery.of(context).size.height * 1,
//               child: RefreshIndicator(
//                 onRefresh: _refreshData,
//                 backgroundColor: Colors.white, // พื้นหลังของ indicator
//                 color: Colors.redAccent,
//                 child: ListView(
//                   children: [
//                     _buildSection('พนักงานที่ยังไม่อนุมัติ', _dataListPending,
//                         Colors.transparent,
//                         showActions: true),
//                     _buildSection('พนักงานที่อนุมัติแล้ว', _dataListApprove,
//                         Colors.transparent),
//                     _buildSection('พนักงานที่ปฎิเสธแล้ว', _dataListReject,
//                         Colors.transparent),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }
