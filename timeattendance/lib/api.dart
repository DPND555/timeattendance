import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeattendance/Page/employee/homeemployee.dart';
import 'package:timeattendance/Page/face.dart';
import 'package:timeattendance/Page/login.dart';
import 'Page/maneger/homemaneger.dart';
import 'provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MyColors {
  static Color red = const Color.fromRGBO(235, 28, 36, 1);
  static Color yellow = const Color.fromRGBO(252, 207, 0, 1);
  static Color black = const Color.fromRGBO(35, 31, 32, 1);
  static Color green = const Color.fromRGBO(35, 31, 32, 1);
}

class Data {
  final String id;
  final String time;

  Data(this.id, this.time);
}

class Api {
  static Future<void> saveLoginState({
    required bool isLoggedIn,
    required int userid,
    required String employeejoblevel,
    required String locationName,
    required double latitude,
    required double longitude,
    required int radius,
    required int manegerid,
    required List<String> calendarData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(calendarData);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userid', userid);
    await prefs.setString('employeejoblevel', employeejoblevel);
    await prefs.setString('locationName', locationName);
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
    await prefs.setInt('radius', radius);
    await prefs.setInt('manegerid', manegerid);
    await prefs.setString('calendar_list', jsonString);
  }

  static Future<void> logout({required BuildContext context}) async {
    final provider = Provider.of<Providerpreferrent>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // ตั้งสถานะล็อกอินเป็น false
    await prefs.remove('userid');
    await prefs.remove('employeejoblevel');
    await prefs.remove('locationName');
    await prefs.remove('latitude');
    await prefs.remove('longitude');
    await prefs.remove('radius');
    await prefs.remove('manegerid');
    await prefs.remove('calendar_list');

    OneSignal.logout();

    provider.clearData();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LogInPage()),
        ModalRoute.withName('/login'),
      );
    }
  }

  static Future loaddialog(BuildContext context) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _LoadingDialog(),
      );

  static Future<bool> checkInternetConnection(
      {required BuildContext context}) async {
    try {
      final response =
          await http.get(Uri.parse('https://www.google.com')).timeout(
                const Duration(seconds: 5),
              );
      return response.statusCode == 200;
    } on ClientException catch (e) {
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
                      e.message,
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
      return false; // ไม่มีอินเทอร์เน็ต
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
                      e.toString(),
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
      return false;
    }
  }

  static String formatHour(double hour) {
    int hours = hour.floor(); // ได้ชั่วโมง
    int minutes = ((hour - hours) * 60).round(); // ได้นาที

    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }

  static Future<void> login({
    required BuildContext context,
    required username,
    required password,
  }) async {
    final provider = Provider.of<Providerpreferrent>(context, listen: false);
    var headers = {'Content-Type': 'application/json'};

    loaddialog(context);

    if (!await checkInternetConnection(context: context)) {
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
                'lib/img/PSS Sticker-07.png',
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              const Text(
                "ไม่มีการเชื่อมต่ออินเทอร์เน็ต",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Text(
                "กรุณาตรวจสอบการเชื่อมต่อของคุณ",
                style: TextStyle(fontSize: 16),
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
      return;
    }

    try {
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://pss-sandbox.cityparking.app/api_time_attendance/api/Auth/auth/login'));
      request.body = json.encode(
          {"username": username.toString(), "password": password.toString()});
      request.headers.addAll(headers);

      http.StreamedResponse responselogin = await request.send();

      if (responselogin.statusCode == 200) {
        String responseloginData = await responselogin.stream.bytesToString();
        var jsonResponselogin =
            json.decode(responseloginData) as Map<String, dynamic>;
        if (jsonResponselogin['status'] == "Success") {
          String token = jsonResponselogin['token'];
          int userid = jsonResponselogin['user']?['id'] ?? '';

          provider.setToken(token);
          provider.setUserid(userid);

          var request = http.Request(
              'POST',
              Uri.parse(
                  'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/employee/me'));
          request.body = json.encode({"user_id": provider.userid});
          request.headers.addAll(headers);

          http.StreamedResponse responseme = await request.send();

          if (responseme.statusCode == 200) {
            String responsemeData = await responseme.stream.bytesToString();
            var jsonResponseme =
                json.decode(responsemeData) as Map<String, dynamic>;

            if (jsonResponseme["status"] == "Success") {
              String employeejoblevel =
                  jsonResponseme['employee']?['job_Level'];
              String employeedepartment =
                  jsonResponseme['employee']?['department'];
              int worklocationid =
                  jsonResponseme['employee']?['work_location_id'];

              var request = http.Request(
                  'POST',
                  Uri.parse(
                      'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/employee_id/Maneger_Id'));
              request.body = json.encode(
                  {"job_level": "Manager", "department": employeedepartment});
              request.headers.addAll(headers);

              http.StreamedResponse response = await request.send();

              if (response.statusCode == 200) {
                String responmanagerid = await response.stream.bytesToString();
                var jsonResponsmanagerid =
                    json.decode(responmanagerid) as Map<String, dynamic>;
                int managerid = jsonResponsmanagerid['maneger']?['id'];
                provider.setManagerid(managerid);
              } else {
                print(response.reasonPhrase);
              }

              var url = Uri.parse(
                  'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/calendar');

              var responsecalendar = await http.get(url);

              if (responsecalendar.statusCode == 200) {
                Map<String, dynamic> data = jsonDecode(responsecalendar.body);
                List<dynamic> calendarList = data["calendar"];

                List<String> formattedCalendar = calendarList.map((record) {
                  int id = record["id"];
                  String hourFrom = record["formatted_hour_from"];
                  String formatted_hour_to = record["formatted_hour_to"];

                  return "id $id , $hourFrom - $formatted_hour_to";
                }).toList();
                // print('formattedCalendar $formattedCalendar');
                provider.setCalendar(formattedCalendar);
              } else {
                print("Error: ${responsecalendar.statusCode}");
              }

              var requestgetlocation = http.Request(
                  'POST',
                  Uri.parse(
                      'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/getlocation'));
              requestgetlocation.body =
                  json.encode({"location_id": worklocationid});
              requestgetlocation.headers.addAll(headers);

              http.StreamedResponse responselocation =
                  await requestgetlocation.send();

              if (responselocation.statusCode == 200) {
                String responselocationData =
                    await responselocation.stream.bytesToString();
                var jsonresponselocation =
                    json.decode(responselocationData) as Map<String, dynamic>;

                String locationName =
                    jsonresponselocation['location_Name'] ?? '';
                double latitude = jsonresponselocation['latitude'] ?? '';
                double longitude = jsonresponselocation['longitude'] ?? '';
                int radius = jsonresponselocation['radius'] ?? '';

                provider.setLocationName(locationName);
                provider.setLatitude(latitude);
                provider.setLongitude(longitude);
                provider.setRadius(radius);

                saveLoginState(
                  isLoggedIn: true,
                  userid: userid,
                  employeejoblevel: employeejoblevel,
                  locationName: locationName,
                  latitude: latitude,
                  longitude: longitude,
                  radius: radius,
                  manegerid: provider.managerid,
                  calendarData: provider.calendarlist,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                }

                if (employeejoblevel == 'Manager') {
                  if (context.mounted) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Homepagemanager()));
                  }
                } else {
                  if (context.mounted) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Homepageemployee()));
                  }
                }
              } else {
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
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                              ),
                              Text(
                                responselocation.reasonPhrase!,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          btnCancelOnPress: () {
                            Navigator.pop(context);
                          },
                          btnCancelText: 'OK')
                      .show();
                }
              }
            }
          } else {
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
                            responseme.reasonPhrase!,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      btnCancelOnPress: () {
                        Navigator.pop(context);
                      },
                      btnCancelText: 'OK')
                  .show();
            }
          }
        } else {
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
                          'lib/img/PSS Sticker-07.png',
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                        const Text(
                          "ล็อคอินไม่สำเร็จ",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          "Login failed.",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    btnCancelOnPress: () {
                      Navigator.pop(context);
                    },
                    btnCancelText: 'OK')
                .show();
          }
        }
      } else {
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
                        responselogin.reasonPhrase!,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  btnCancelOnPress: () {
                    Navigator.pop(context);
                  },
                  btnCancelText: 'OK')
              .show();
        }
      }
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
                      "$e",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                btnCancelOnPress: () {
                  Navigator.pop(context);
                },
                btnCancelText: 'OK')
            .show();
      }
    }
  }

  static Future<void> employeeme({required BuildContext context}) async {
    final provider = Provider.of<Providerpreferrent>(context, listen: false);

    var headers = {'Content-Type': 'application/json'};

    if (!await checkInternetConnection(context: context)) {
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
                'lib/img/PSS Sticker-07.png',
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              const Text(
                "ไม่มีการเชื่อมต่ออินเทอร์เน็ต",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Text(
                "กรุณาตรวจสอบการเชื่อมต่อของคุณ",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          btnCancelOnPress: () {},
          btnCancelText: 'OK',
        ).show();
      }
      return;
    }
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/employee/me'));
    request.body = json.encode({"user_id": provider.userid});
    request.headers.addAll(headers);

    http.StreamedResponse responseme = await request.send();

    if (responseme.statusCode == 200) {
      String responsemeData = await responseme.stream.bytesToString();
      var jsonResponseme = json.decode(responsemeData) as Map<String, dynamic>;
      if (jsonResponseme["status"] == "Success") {
        int employeeid = jsonResponseme['employee']?['id'];
        int companyid = jsonResponseme['employee']?['company_id'];
        int worklocationid = jsonResponseme['employee']?['work_location_id'];
        int calendarid = jsonResponseme['employee']?['calendar_id'];
        // int attendanceuserid =
        //     jsonResponseme['employee']?['attendance_user_id'];
        String employeename = jsonResponseme['employee']?['name'];
        String employeerole = jsonResponseme['employee']?['role'];
        String employeejoblevel = jsonResponseme['employee']?['job_Level'];
        String employeedepartment = jsonResponseme['employee']?['department'];
        String employeeemail = jsonResponseme['employee']?['email'];
        String employeemobilephone =
            jsonResponseme['employee']?['mobile_phone'];
        String employeeImage = jsonResponseme['employee']?['employee_image'];
        String checkin = jsonResponseme['employee']?['last_check_in'];
        String checkout = jsonResponseme['employee']?['last_check_out'];

        provider.setEmployeeid(employeeid);
        provider.setCompanyid(companyid);
        provider.setWorklocationid(worklocationid);
        provider.setCalendarid(calendarid);
        // provider.setAttendanceuserid(attendanceuserid);
        provider.setEmployeename(employeename);
        provider.setEmployeerole(employeerole);
        provider.setEmployeejoblevel(employeejoblevel);
        provider.setEmployeedepartment(employeedepartment);
        provider.setEmployeeemail(employeeemail);
        provider.setEmployeemobilephone(employeemobilephone);
        provider.setCheckin(checkin);
        provider.setCheckout(checkout);
        provider.setEmployeeImage(employeeImage);

        OneSignal.login(employeeid.toString());
      }
    } else {
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
                      ('${responseme.reasonPhrase}'),
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
    }
  }

  static Future<void> getDistance({
    required double latitude,
    required double longitude,
    required String datetime,
    required BuildContext context,
  }) async {
    final provider = Provider.of<Providerpreferrent>(context, listen: false);

    if (!await checkInternetConnection(context: context)) {
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
                'lib/img/PSS Sticker-07.png',
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              const Text(
                "ไม่มีการเชื่อมต่ออินเทอร์เน็ต",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Text(
                "กรุณาตรวจสอบการเชื่อมต่อของคุณ",
                style: TextStyle(fontSize: 16),
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
      return;
    }

    String apiKey = "AIzaSyCJ78J6KfHsV_N52N2kkPpYkwDP83xV28s";
    String url =
        "https://maps.googleapis.com/maps/api/distancematrix/json?origins=$latitude,$longitude&destinations=${provider.latitude},${provider.longitude}&language=th&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // String distanceText =
        //     data["rows"][0]["elements"][0]["distance"]["text"];
        int distancevalue = data["rows"][0]["elements"][0]["distance"]["value"];
        // String durationText =
        //     data["rows"][0]["elements"][0]["duration"]["text"];
        // String status = data["status"];

        // print("📍 status: $status");
        // print("📍 ระยะทาง: $distanceText");
        // print("📍 ระยะทางข้อมูล: ${distancevalue.toString()}");
        // print("🕒 เวลาเดินทาง: $durationText");
        if (data["status"] == 'OK') {
          if (distancevalue < provider.radius!) {
            if (context.mounted) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FaceScanPage(
                            latitude: latitude,
                            longitude: longitude,
                            datetime: datetime,
                            distance: distancevalue.toString(),
                          )));
            }
          } else {
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
                            'lib/img/PSS Sticker-07.png',
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          const Text(
                            "ตำแหน่งของคุณอยู่นอกพื้นที",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            "Location is outside the area.",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      btnCancelOnPress: () {
                        Navigator.pop(context);
                      },
                      btnCancelText: 'OK')
                  .show();
            }
          }
        } else {
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
                          'lib/img/PSS Sticker-04.png',
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                        const Text(
                          "status error", // title จะถูกใส่ที่นี่
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    btnCancelOnPress: () {
                      Navigator.pop(context);
                    },
                    btnCancelText: 'OK')
                .show();
          }
        }
      } else {
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
                        "Error: ${response.statusCode}", // title จะถูกใส่ที่นี่
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  btnCancelOnPress: () {
                    Navigator.pop(context);
                  },
                  btnCancelText: 'OK')
              .show();
        }
      }
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
                      ('$e'),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                btnCancelOnPress: () {
                  Navigator.pop(context);
                },
                btnCancelText: 'OK')
            .show();
      }
    }
  }

  static Future<void> scanface({
    required String face1,
    required String face2,
    required String latitude,
    required String longitude,
    required String distance,
    required String datetime,
    required BuildContext context,
  }) async {
    final provider = Provider.of<Providerpreferrent>(context, listen: false);

    if (!await checkInternetConnection(context: context)) {
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
                'lib/img/PSS Sticker-07.png',
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              const Text(
                "ไม่มีการเชื่อมต่ออินเทอร์เน็ต",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Text(
                "กรุณาตรวจสอบการเชื่อมต่อของคุณ",
                style: TextStyle(fontSize: 16),
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
      return;
    }

    if (context.mounted) {
      loaddialog(context);
    }

    var headers = {'token': '06aa1e2621da436ab010f65fc7487046'};
    var request = http.MultipartRequest(
        'POST', Uri.parse('https://api.luxand.cloud/photo/similarity'));
    request.fields.addAll({'threshold': '0.8'});

    // 2. แปลง face2 (Base64) เป็นไฟล์ชั่วคราว
    Uint8List face1Bytes = base64Decode(face1);
    File face1File = await _writeBytesToFile(face1Bytes, 'face1.jpg');

    // 3. เพิ่ม face2 (ไฟล์ที่แปลงจาก Base64) ไปยัง request
    request.files
        .add(await http.MultipartFile.fromPath('face1', face1File.path));

    // 2. แปลง face2 (Base64) เป็นไฟล์ชั่วคราว
    Uint8List face2Bytes = base64Decode(face2);
    File face2File = await _writeBytesToFile(face2Bytes, 'face2.jpg');

    // 3. เพิ่ม face2 (ไฟล์ที่แปลงจาก Base64) ไปยัง request
    request.files
        .add(await http.MultipartFile.fromPath('face2', face2File.path));

    request.headers.addAll(headers);

    // 4. ส่งคำขอไปยัง API
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      // แปลงข้อมูล response ให้เป็น String ก่อน
      String responseData = await response.stream.bytesToString();

      var jsonResponse = json.decode(responseData) as Map<String, dynamic>;

      String formattedCheckIn =
          provider.checkin.replaceAll(RegExp(r'[-:\s]'), '');
      String formattedCheckOut =
          provider.checkout.replaceAll(RegExp(r'[-:\s]'), '');
      int checkin = int.tryParse(formattedCheckIn) ?? 0;
      int checkout = int.tryParse(formattedCheckOut) ?? 0;

      if (jsonResponse["similar"] == true) {
        if (checkin < checkout || checkin == checkout) {
          if (context.mounted) {
            clockin(
              context: context,
              latitude: latitude,
              longitude: longitude,
              distance: distance,
              datetime: datetime,
              faceimage: face1,
            );

            usertomanager(
              context: context,
              employeeid: provider.employeeid,
              managerid: provider.managerid,
              message: 'เข้างานเเล้ว',
            );
          }
        } else if (checkin > checkout) {
          if (context.mounted) {
            clockout(
              context: context,
              latitude: latitude,
              longitude: longitude,
              distance: distance,
              datetime: datetime,
              faceimage: face1,
            );

            usertomanager(
              context: context,
              employeeid: provider.employeeid,
              managerid: provider.managerid,
              message: 'ออกจากที่ทำงานเเล้ว',
            );
          }
        }
      } else {
        if (context.mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            dismissOnTouchOutside: false,
            dismissOnBackKeyPress: false,
            barrierColor: Colors.grey,
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "สแกนหน้า ไม่สำเร็จ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "กรุณาตรวจสอบ ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "แสงอาจไม่เพียงพอ,ใบหน้าอาจไม่ชัดเจน,เครือข่ายอาจมีปัญหา",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "(โปรดลองอีกครั้ง)",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Image.asset(
                  'lib/img/PSS Sticker-07.png',
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
              ],
            ),
            btnOkOnPress: () {
              if (provider.employeejoblevel == "Manager") {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/homemanager', (route) => false);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/homeemployee', (route) => false);
              }
            },
            btnOkText: 'OK',
          ).show();
        }
      }
    } else {
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
                      '${response.reasonPhrase}',
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
    }
  }

  // ฟังก์ชันสร้างไฟล์จาก bytes (Base64)
  static Future<File> _writeBytesToFile(
      Uint8List bytes, String filename) async {
    final directory = await getTemporaryDirectory();
    File file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<void> clockin({
    required BuildContext context,
    required String latitude,
    required String longitude,
    required String distance,
    required String datetime,
    required String faceimage,
  }) async {
    final provider = Provider.of<Providerpreferrent>(context, listen: false);
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request(
        'POST',
        Uri.parse(
            'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/clock-in'));
    request.body = json.encode({
      "emp_id": provider.employeeid,
      "emp_name": provider.employeename,
      "company_id": provider.companyid,
      "calenda_id": provider.calendarid,
      "work_location_id": provider.worklocationid,
      "timeStamp": datetime,
      "check_in_location": "$latitude,$longitude",
      "check_in_distance": distance,
      "create_uid": provider.userid,
      "picture_in": faceimage
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData) as Map<String, dynamic>;

      if (jsonResponse["message"] == "Check-in recorded successfully") {
        if (provider.employeejoblevel == 'Manager') {
          if (context.mounted) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              dismissOnTouchOutside: false,
              dismissOnBackKeyPress: false,
              barrierColor: Colors.grey,
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/img/PSS Sticker-02.png',
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  const Text(
                    "ลงเวลาสำเร็จ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "check in success",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              btnOkOnPress: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/homemanager', (route) => false);
              },
              btnOkText: 'OK',
            ).show();
          }
        } else {
          if (context.mounted) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              dismissOnTouchOutside: false,
              dismissOnBackKeyPress: false,
              barrierColor: Colors.grey,
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/img/PSS Sticker-02.png',
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  const Text(
                    "ลงเวลาสำเร็จ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "check in success",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              btnOkOnPress: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/homeemployee', (route) => false);
              },
              btnOkText: 'OK',
            ).show();
          }
        }
      } else {
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
                      const Text(
                        "เข้างานไม่สำเร็จ", // title จะถูกใส่ที่นี่
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  btnCancelOnPress: () {
                    if (provider.employeejoblevel == "Manager") {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/homemanager', (route) => false);
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/homeemployee', (route) => false);
                    }
                  },
                  btnCancelText: 'OK')
              .show();
        }
      }
    } else {
      if (context.mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          barrierColor: Colors.grey,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'lib/img/PSS Sticker-04.png',
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Text(
                response.reasonPhrase!,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          btnOkOnPress: () {
            if (provider.employeejoblevel == "Manager") {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/homemanager', (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/homeemployee', (route) => false);
            }
          },
          btnOkText: 'OK',
        ).show();
      }
    }
  }

  static Future<void> clockout({
    required BuildContext context,
    required String latitude,
    required String longitude,
    required String distance,
    required String datetime,
    required String faceimage,
  }) async {
    final provider = Provider.of<Providerpreferrent>(context, listen: false);

    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/clock-out'));
    request.body = json.encode({
      "emp_id": provider.employeeid,
      "emp_name": provider.employeename,
      "timeStamp": datetime,
      "check_out_location": "$latitude,$longitude",
      "check_out_distance": distance,
      "create_uid": provider.userid,
      "picture_out": faceimage
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData) as Map<String, dynamic>;

      if (jsonResponse["message"] == "Check-out recorded successfully") {
        if (provider.employeejoblevel == 'Manager') {
          if (context.mounted) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              dismissOnTouchOutside: false,
              dismissOnBackKeyPress: false,
              barrierColor: Colors.grey,
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/img/PSS Sticker-03.png',
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  const Text(
                    "ลงเวลาสำเร็จ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "check out success",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              btnOkOnPress: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/homemanager', (route) => false);
              },
              btnOkText: 'OK',
            ).show();
          }
        } else {
          if (context.mounted) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              dismissOnTouchOutside: false,
              dismissOnBackKeyPress: false,
              barrierColor: Colors.grey,
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/img/PSS Sticker-03.png',
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  const Text(
                    "ลงเวลาสำเร็จ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "check out success",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              btnOkOnPress: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/homeemployee', (route) => false);
              },
              btnOkText: 'OK',
            ).show();
          }
        }
      } else {
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
                      const Text(
                        "ออกงานไม่สำเร็จ", // title จะถูกใส่ที่นี่
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  btnCancelOnPress: () {
                    if (provider.employeejoblevel == "Manager") {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/homemanager', (route) => false);
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/homeemployee', (route) => false);
                    }
                  },
                  btnCancelText: 'OK')
              .show();
        }
      }
    } else {
      if (context.mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          barrierColor: Colors.grey,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'lib/img/PSS Sticker-04.png',
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Text(
                response.reasonPhrase!,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          btnOkOnPress: () {
            if (provider.employeejoblevel == "Manager") {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/homemanager', (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/homeemployee', (route) => false);
            }
          },
          btnOkText: 'OK',
        ).show();
      }
    }
  }

  static Future<void> clockoutreject({
    required BuildContext context,
    required String latitude,
    required String longitude,
    required String distance,
    required String datetime,
    required String faceimage,
    required int recordid,
    required String note,
    required String empid,
    required String empname,
    required String createuid,
    required VoidCallback onSuccess,
  }) async {
    final provider = Provider.of<Providerpreferrent>(context, listen: false);

    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/clock-out'));
    request.body = json.encode({
      "emp_id": empid,
      "emp_name": empname,
      "timeStamp": datetime,
      "check_out_location": "$latitude,$longitude",
      "check_out_distance": distance,
      "create_uid": createuid,
      "picture_out": faceimage
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData) as Map<String, dynamic>;

      if (jsonResponse["message"] == "Check-out recorded successfully") {
        if (context.mounted) {
          rejectout(
            context: context,
            recordid: recordid,
            notes: note,
            onSuccess: onSuccess,
          );
        }
      } else {
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
                      const Text(
                        "Error", // title จะถูกใส่ที่นี่
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  btnCancelOnPress: () {},
                  btnCancelText: 'OK')
              .show();
        }
      }
    } else {
      if (context.mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          barrierColor: Colors.grey,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'lib/img/PSS Sticker-04.png',
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Text(
                response.reasonPhrase!,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          btnOkOnPress: () {
            if (provider.employeejoblevel == "Manager") {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/homemanager', (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/homeemployee', (route) => false);
            }
          },
          btnOkText: 'OK',
        ).show();
      }
    }
  }

  // static Future<void> allmembertoday() async {
  //   var request = http.Request(
  //       'GET',
  //       Uri.parse(
  //           'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/today'));
  //   request.body = '''''';

  //   http.StreamedResponse response = await request.send();

  //   if (response.statusCode == 200) {
  //     print(await response.stream.bytesToString());
  //   } else {
  //     print(response.reasonPhrase);
  //   }
  // }

  static Future<void> approve({
    required BuildContext context,
    required int recordid,
    required VoidCallback onSuccess, // เพิ่ม callback สำหรับอัปเดตข้อมูล
    required String calendaid,
    required int employeeid,
    required String message,
  }) async {
    var headers = {'Content-Type': 'application/json'};
    final provider = Provider.of<Providerpreferrent>(context, listen: false);
    int? calenda_id = int.parse(calendaid);

    var request = http.Request(
        'POST',
        Uri.parse(
            'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/approve'));
    request.body = json.encode({
      "record_id": recordid,
      "calenda_id": calenda_id,
      "user_approve_id":
          provider.employeeid, ////////////////////////////////////////////////
      "approve_status": "Approve",
      "notes": ""
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    print('request ${request.body}');
    if (response.statusCode == 200) {
      String responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData) as Map<String, dynamic>;

      if (jsonResponse["status"] == "Success") {
        if (context.mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
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
                  "อนุมัติสำเร็จ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            btnOkOnPress: () {
              onSuccess(); // อัปเดตข้อมูล
            },
            btnOkText: 'OK',
          ).show();
        }
        managertouser(
          context: context,
          endpoint: employeeid,
          message: message,
        );
      }
    } else {
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
                      '${response.reasonPhrase}',
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
    }
  }

  static Future<void> rejectin({
    required BuildContext context,
    required int recordid,
    required String notes,
    required String latitude,
    required String longitude,
    required String checkindistance,
    required String checkintime,
    required String picturein,
    required String empid,
    required String empname,
    required String createuid,
    required VoidCallback onSuccess, // เพิ่ม callback สำหรับอัปเดตข้อมูล
  }) async {
    var headers = {'Content-Type': 'application/json'};
    final provider = Provider.of<Providerpreferrent>(context, listen: false);

    var request = http.Request(
        'POST',
        Uri.parse(
            'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/reject'));
    request.body = json.encode({
      "record_id": recordid,
      "user_approve_id": provider.employeeid,
      "approve_status": "Reject",
      "notes": notes // เพิ่มข้อความปฏิเสธให้มีความหมาย
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData) as Map<String, dynamic>;

      if (jsonResponse["status"] == "Success") {
        if (context.mounted) {
          clockoutreject(
            context: context,
            latitude: latitude,
            longitude: longitude,
            distance: checkindistance,
            datetime: checkintime,
            faceimage: picturein,
            recordid: recordid,
            note: notes,
            empid: empid,
            empname: empname,
            createuid: createuid,
            onSuccess: onSuccess,
          );
        }
      }
    } else {
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
                      '${response.reasonPhrase}',
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
    }
  }

  static Future<void> rejectout({
    required BuildContext context,
    required int recordid,
    required String notes,
    required VoidCallback onSuccess,
  }) async {
    var headers = {'Content-Type': 'application/json'};
    final provider = Provider.of<Providerpreferrent>(context, listen: false);

    var request = http.Request(
        'POST',
        Uri.parse(
            'https://pss-sandbox.cityparking.app/api_time_attendance/api/attendance/reject'));
    request.body = json.encode({
      "record_id": recordid,
      "user_approve_id": provider.employeeid,
      "approve_status": "Reject",
      "notes": notes // เพิ่มข้อความปฏิเสธให้มีความหมาย
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData) as Map<String, dynamic>;

      if (jsonResponse["status"] == "Success") {
        if (context.mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
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
                  "ปฏิเสธสำเร็จ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            btnOkOnPress: () {
              onSuccess(); // อัปเดตข้อมูล
            },
            btnOkText: 'OK',
          ).show();
        }
      }
    } else {
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
                      '${response.reasonPhrase}',
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
    }
  }

  static Future usertomanager({
    required BuildContext context,
    required int employeeid,
    required int managerid,
    required String message,
  }) async {
    final provider = Provider.of<Providerpreferrent>(context, listen: false);
    var headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Basic os_v2_app_haaz4ph72nbona5ecosqdasuwzkxizrkexvusk5f2wfw4kqrbbmyn24hc7qxv3hfeb45xer5fvfzzawd37v2zivodi4iwptiptj5eka',
      'Cookie':
          '__cf_bm=UqEFyyhVOi9pdASkI7QgUXrm.czHQwLGPPj4fCQfiYA-1741250253-1.0.1.1-.UZn0yhdAFR7q_wcBT9r_YE4iA38Ed39CUXv7oZkKD_sYu8loe829G12RqVgHzlHtB1JoU7qcQlqM3SYndQBH7aG_OaBrbhxWcB40WxXOaE'
    };
    var request = http.Request(
        'POST', Uri.parse('https://onesignal.com/api/v1/notifications'));
    request.body = json.encode({
      "app_id": "38019e3c-ffd3-42e6-83a4-13a5018254b6",
      "include_external_user_ids": ["$employeeid", "$managerid"],
      "small_icon": "ic_stat_onesignal_default",
      "headings": {"en": "ข้อความใหม่"},
      "contents": {"en": "สวัสดี! คุณ ${provider.employeename} ได้$message"},
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future managertouser({
    required BuildContext context,
    required int endpoint,
    required String message,
  }) async {
    final provider = Provider.of<Providerpreferrent>(context, listen: false);
    var headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Basic os_v2_app_haaz4ph72nbona5ecosqdasuwzkxizrkexvusk5f2wfw4kqrbbmyn24hc7qxv3hfeb45xer5fvfzzawd37v2zivodi4iwptiptj5eka',
      'Cookie':
          '__cf_bm=UqEFyyhVOi9pdASkI7QgUXrm.czHQwLGPPj4fCQfiYA-1741250253-1.0.1.1-.UZn0yhdAFR7q_wcBT9r_YE4iA38Ed39CUXv7oZkKD_sYu8loe829G12RqVgHzlHtB1JoU7qcQlqM3SYndQBH7aG_OaBrbhxWcB40WxXOaE'
    };
    var request = http.Request(
        'POST', Uri.parse('https://onesignal.com/api/v1/notifications'));
    request.body = json.encode({
      "app_id": "38019e3c-ffd3-42e6-83a4-13a5018254b6",
      "include_external_user_ids": ["$endpoint"],
      "small_icon": "ic_stat_onesignal_default",
      "headings": {"en": "ข้อความใหม่"},
      "contents": {
        "en": "สวัสดี! คุณ ${provider.employeename} ได้$message ของคุณเเล้ว"
      },
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  ClockState createState() => ClockState();
}

class ClockState extends State<Clock> {
  String time = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          time =
              DateFormat('Hms', 'th').format(DateTime.now()); // Update the time
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      time.isEmpty ? 'Loading...' : time,
      style: const TextStyle(
        fontSize: 20,
      ),
    );
  }
}

class _LoadingDialog extends StatefulWidget {
  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<_LoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<double> _rotationAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(0.6, 0),
      end: const Offset(-0.6, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.05,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SlideTransition(
              position: _animation,
              child: RotationTransition(
                turns: _rotationAnimation,
                child: Image.asset(
                  'lib/img/PSS Sticker-17.png',
                  height: MediaQuery.of(context).size.height * 0.09,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "กำลังโหลด...",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class ColumnChartSample extends StatelessWidget {
  final List<ChartData> chartData = [
    ChartData('มา (Present)', 21, Colors.greenAccent),
    ChartData('สาย (Late)', 8, Colors.orangeAccent),
    ChartData('ขาด (Absent)', 4, Colors.redAccent),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1, // กำหนดความกว้างของกราฟ
      height: MediaQuery.of(context).size.height * 0.2, // กำหนดความสูงของกราฟ
      child: SfCartesianChart(
        title: ChartTitle(text: 'สถานะเข้างานวันนี้'),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: 30,
          interval: 10,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          ColumnSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.label,
            yValueMapper: (ChartData data, _) => data.value,
            pointColorMapper: (ChartData data, _) =>
                data.color, // กำหนดสีของแต่ละคอลัมน์
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

// class ColumnChartSample extends StatelessWidget {
//   final List<ChartData> chartDataPresent = [
//     ChartData('มา (Present)', 30),
//   ];
//   final List<ChartData> chartDataLate = [
//     ChartData('สาย (Late)', 4),
//   ];
//   final List<ChartData> chartDataAbsent = [
//     ChartData('ขาด (Absent)', 1),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 300, // กำหนดความกว้างของกราฟ
//       height: 250, // กำหนดความสูงของกราฟ
//       child: SfCartesianChart(
//         title: ChartTitle(text: 'จำนวนคนมาเข้างาน'),
//         primaryXAxis: CategoryAxis(),
//         primaryYAxis: NumericAxis(
//           minimum: 0,
//           maximum: 50,
//           interval: 10,
//         ),
//         tooltipBehavior: TooltipBehavior(enable: true),
//         series: <CartesianSeries>[
//           // คอลัมน์แรก
//           ColumnSeries<ChartData, String>(
//             dataSource: chartDataPresent,
//             xValueMapper: (ChartData data, _) => data.label,
//             yValueMapper: (ChartData data, _) => data.value,
//             name: 'มา (Present)',
//             color: Colors.green, // สีเขียว
//             dataLabelSettings: DataLabelSettings(isVisible: true),
//           ),
//           // คอลัมน์ที่สอง
//           ColumnSeries<ChartData, String>(
//             dataSource: chartDataLate,
//             xValueMapper: (ChartData data, _) => data.label,
//             yValueMapper: (ChartData data, _) => data.value,
//             name: 'สาย (Late)',
//             color: Colors.orange, // สีส้ม
//             dataLabelSettings: DataLabelSettings(isVisible: true),
//           ),
//           // คอลัมน์ที่สาม
//           ColumnSeries<ChartData, String>(
//             dataSource: chartDataAbsent,
//             xValueMapper: (ChartData data, _) => data.label,
//             yValueMapper: (ChartData data, _) => data.value,
//             name: 'ขาด (Absent)',
//             color: Colors.red, // สีแดง
//             dataLabelSettings: DataLabelSettings(isVisible: true),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChartData {
//   ChartData(this.label, this.value);
//   final String label;
//   final double value;
// }
