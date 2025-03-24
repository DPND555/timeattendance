import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:timeattendance/api.dart';

class AttendanceSummaryPage extends StatefulWidget {
  const AttendanceSummaryPage({super.key});

  @override
  State<AttendanceSummaryPage> createState() => _AttendanceSummaryPageState();
}

class _AttendanceSummaryPageState extends State<AttendanceSummaryPage> {
  bool _isLoading = false;
  List<AttendanceRecord> _attendanceRecords = [];
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (_isLoading) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      var url = Uri.parse(
          'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/today');
      print("เริ่มร้องขอ API: ${DateTime.now()}");
      // เพิ่ม timeout 10 วินาที
      var response = await http.get(url).timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          print("Timeout เกิดขึ้น: ${DateTime.now()}");
          throw Exception("การเชื่อมต่อหมดเวลา: API ไม่ตอบสนองภายใน 10 วินาที");
        },
      );
      print("ได้รับ response: ${DateTime.now()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> attendanceList = data["attendance"];

        Map<String, Map<String, dynamic>> employeeMaxAttendanceIn = {};

        for (var record in attendanceList) {
          String name = record["employee_name"];
          int attendanceId = record["attendance_id"] ?? 0;
          String statusApprove =
              record["status_approve_in_out"]?.toString().trim() ?? "";

          if (statusApprove == "In") {
            if (!employeeMaxAttendanceIn.containsKey(name) ||
                attendanceId >
                    employeeMaxAttendanceIn[name]!['attendance_id']) {
              employeeMaxAttendanceIn[name] = record;
            }
          }
        }

        List<AttendanceRecord> attendanceRecords = [];

        for (var record in employeeMaxAttendanceIn.values) {
          String status = record["status"]?.toString().trim() ?? "";
          String employeeName = record["employee_name"] ?? "Unknown";
          String checkInTime = record["check_in_time"] ?? "-";
          String checkOutTime = record["check_out_time"] ?? "-";
          int lateTime = record["late_time"] ?? 0;

          DateTime dateTime = DateTime.parse(checkInTime);

          String formattedDate =
              DateFormat("HH:mm:ss dd/MM/yyyy").format(dateTime);
          String formattedDate2 = checkOutTime == "-"
              ? "-"
              : DateFormat("HH:mm:ss dd/MM/yyyy")
                  .format(DateTime.parse(checkOutTime));

          if (status == "Reject") continue;
          

          AttendanceStatus attendanceStatus;

          if (status == "Approve") {
            if (lateTime > 0) {
              attendanceStatus = AttendanceStatus.late;
            } else {
              attendanceStatus = AttendanceStatus.present;
            }
          } else if (status == "Pending") {
            attendanceStatus = AttendanceStatus.present;
          } else {
            continue;
          }

          attendanceRecords.add(
            AttendanceRecord(
              employeeName: employeeName,
              checkInTime: formattedDate,
              checkOutTime: formattedDate2,
              status: attendanceStatus,
              date: DateTime.now(),
            ),
          );
        }

        if (mounted) {
          setState(() {
            _attendanceRecords = attendanceRecords;
          });
        }
      } else {
        // แจ้งเตือนเมื่อ status code ไม่ใช่ 200
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "เกิดข้อผิดพลาด: ${response.statusCode} - ${response.reasonPhrase}"),
            ),
          );
        }
      }
    } catch (e) {
      // จัดการข้อผิดพลาดทั้งหมด (timeout, network error, etc.)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ไม่สามารถเชื่อมต่อ API ได้: $e"),
          ),
        );
        // print(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'มาทำงาน';
      case AttendanceStatus.late:
        return 'มาสาย';
      case AttendanceStatus.absent:
        return 'ขาดงาน';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.red,
        title: const Text('ลงเวลางาน', style: TextStyle(color: Colors.white)),
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
            ))
          : Column(
              children: [
                // Date selector
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _dateFormat.format(DateTime.now()),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // Attendance stats card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'สรุปการเข้างานประจำวัน',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2,
                            child: AttendanceColumnChartToday(
                                attendanceRecords: _attendanceRecords),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'รายการเข้างานวันนี้',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Attendance list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = _attendanceRecords[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _getStatusColor(record.status).withOpacity(0.2),
                            radius: MediaQuery.of(context).size.width * 0.05,
                            child: Icon(
                              record.status == AttendanceStatus.present
                                  ? Icons.check_circle
                                  : record.status == AttendanceStatus.late
                                      ? Icons.access_time
                                      : Icons.cancel,
                              color: _getStatusColor(record.status),
                            ),
                          ),
                          title: Text(
                            record.employeeName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'เข้างาน: ${record.checkInTime}  |  ออกงาน: ${record.checkOutTime}',
                              ),
                              Text(
                                _getStatusText(record.status),
                                style: TextStyle(
                                  color: _getStatusColor(record.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class AttendanceColumnChartToday extends StatefulWidget {
  final List<AttendanceRecord> attendanceRecords;

  const AttendanceColumnChartToday(
      {super.key, required this.attendanceRecords});

  @override
  State<AttendanceColumnChartToday> createState() =>
      _AttendanceColumnChartTodayState();
}

class _AttendanceColumnChartTodayState
    extends State<AttendanceColumnChartToday> {
  @override
  Widget build(BuildContext context) {
    // ดึงวันปัจจุบัน
    final DateTime today = DateTime.now();

    // กรองเฉพาะข้อมูลของวันปัจจุบัน
    final todayRecords = widget.attendanceRecords.where((record) {
      return record.date.year == today.year &&
          record.date.month == today.month &&
          record.date.day == today.day;
    }).toList();

    // นับจำนวนของแต่ละสถานะ
    int presentCount =
        todayRecords.where((r) => r.status == AttendanceStatus.present).length;
    int lateCount =
        todayRecords.where((r) => r.status == AttendanceStatus.late).length;
    int absentCount =
        todayRecords.where((r) => r.status == AttendanceStatus.absent).length;

    // สร้างข้อมูลของกราฟ
    final List<AttendanceData> chartData = [
      AttendanceData('มาทำงาน', presentCount, Colors.green),
      AttendanceData('มาสาย', lateCount, Colors.orange),
      AttendanceData('ขาดงาน', absentCount, Colors.red),
    ];

    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(
        labelStyle: TextStyle(fontSize: 12),
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum:
            ((presentCount + lateCount + absentCount) * 1.2).ceilToDouble(),
        interval: 1,
        labelStyle: const TextStyle(fontSize: 10),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.top,
        toggleSeriesVisibility: false,
      ),
      onLegendTapped: (LegendTapArgs args) {
        setState(() {});
      },
      series: <CartesianSeries>[
        ColumnSeries<AttendanceData, String>(
          name: 'สถานะเข้างาน',
          dataSource: chartData,
          xValueMapper: (AttendanceData data, _) => data.day,
          yValueMapper: (AttendanceData data, _) => data.count,
          pointColorMapper: (AttendanceData data, _) => data.color,
          width: 0.8,
          spacing: 0.2,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true, // เปิดการแสดงตัวเลข
            labelAlignment:
                ChartDataLabelAlignment.outer, // จัดตำแหน่งไว้ด้านบนแท่งกราฟ
            textStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ), // ปรับสไตล์
          ),
        ),
      ],
    );
  }
}

// ปรับคลาสให้เก็บค่าของแต่ละสถานะ
class AttendanceData {
  final String day;
  final int count;
  final Color color;

  AttendanceData(this.day, this.count, this.color);
}

// Data classes
enum AttendanceStatus { present, late, absent }

class AttendanceRecord {
  final String employeeName;
  final String checkInTime;
  final String checkOutTime;
  final AttendanceStatus status;
  final DateTime date;

  AttendanceRecord({
    required this.employeeName,
    required this.checkInTime,
    required this.checkOutTime,
    required this.status,
    required this.date,
  });
}
