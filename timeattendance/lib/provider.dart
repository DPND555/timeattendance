import 'package:flutter/material.dart';

class Providerpreferrent with ChangeNotifier {
  // จาก Api login
  String _token = '';
  int? _userid;

  // จาก Api calendar
  List<String> _calendarlist = [];

  // จาก Api getemployeedata
  int? _employeeid;
  int? _companyid;
  int? _worklocationid;
  int? _calendarid;
  // int? _attendanceuserid;
  String _employeename = '';
  String _employeerole = '';
  String _employeejoblevel = '';
  String _employeedepartment = '';
  String _employeeemail = '';
  String _employeemobilephone = '';
  String _checkin = '';
  String _checkout = '';
  String _employeeImage = '';

  // จาก Api getlocation
  String _locationName = '';
  double? _latitude;
  double? _longitude;
  int? _radius;

  // จาก Api Maneger_Id
  int? _managerid;
  String _managername = '';

  // จาก Apilogin
  String get token => _token;
  int get userid => _userid!;

  // จาก Api calendar
  List<String> get calendarlist => _calendarlist;

  // จาก Api getemployeedata
  int get employeeid => _employeeid!;
  int get companyid => _companyid!;
  int get worklocationid => _worklocationid!;
  int get calendarid => _calendarid!;
  // int get attendanceuserid => _attendanceuserid!;
  String get employeename => _employeename;
  String get employeerole => _employeerole;
  String get employeejoblevel => _employeejoblevel;
  String get employeedepartment => _employeedepartment;
  String get employeeemail => _employeeemail;
  String get employeemobilephone => _employeemobilephone;
  String get checkin => _checkin;
  String get checkout => _checkout;
  String get employeeImage => _employeeImage;

  // จาก Api getlocation
  String get locationName => _locationName;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  int? get radius => _radius;

  // จาก Api Maneger_Id
  int get managerid => _managerid!;
  String get managername => _managername;

  // อัปเดตค่า header และบันทึกใน SharedPreferences
  // จาก Api login
  Future<void> setToken(String newToken) async {
    _token = newToken;
    notifyListeners();
  }

  Future<void> setUserid(int newUserid) async {
    _userid = newUserid;
    notifyListeners();
  }

  Future<void> setCalendar(List<String> newcalendar) async {
    _calendarlist = newcalendar;
    notifyListeners(); // แจ้งให้ UI อัปเดต
  }

  // จาก Api getemployeedata
  Future<void> setEmployeeid(int newEmployeeid) async {
    _employeeid = newEmployeeid;
    notifyListeners();
  }

  Future<void> setCompanyid(int newCompanyid) async {
    _companyid = newCompanyid;
    notifyListeners();
  }

  Future<void> setWorklocationid(int newWorklocationid) async {
    _worklocationid = newWorklocationid;
    notifyListeners();
  }

  Future<void> setCalendarid(int newCalendarid) async {
    _calendarid = newCalendarid;
    notifyListeners();
  }

  // Future<void> setAttendanceuserid(int newAttendanceuseri) async {
  //   _attendanceuserid = newAttendanceuseri;
  //   notifyListeners();
  // }

  Future<void> setEmployeename(String newEmployeename) async {
    _employeename = newEmployeename;
    notifyListeners();
  }

  Future<void> setEmployeerole(String newEmployeerole) async {
    _employeerole = newEmployeerole;
    notifyListeners();
  }

  Future<void> setEmployeejoblevel(String newJoblevel) async {
    _employeejoblevel = newJoblevel;
    notifyListeners();
  }

  Future<void> setEmployeedepartment(String newDepartment) async {
    _employeedepartment = newDepartment;
    notifyListeners();
  }

  Future<void> setEmployeeemail(String newEmployeeemail) async {
    _employeeemail = newEmployeeemail;
    notifyListeners();
  }

  Future<void> setEmployeemobilephone(String newEmployeemobilephone) async {
    _employeemobilephone = newEmployeemobilephone;
    notifyListeners();
  }

  Future<void> setCheckin(String newCheckin) async {
    _checkin = newCheckin;
    notifyListeners();
  }

  Future<void> setCheckout(String newCheckout) async {
    _checkout = newCheckout;
    notifyListeners();
  }

  Future<void> setEmployeeImage(String newEmployeeImage) async {
    _employeeImage = newEmployeeImage;
    notifyListeners();
  }

  // จาก Api getlocation
  Future<void> setLocationName(String newLocationName) async {
    _locationName = newLocationName;
    notifyListeners();
  }

  Future<void> setLatitude(double newLatitude) async {
    _latitude = newLatitude;
    notifyListeners();
  }

  Future<void> setLongitude(double newLongitude) async {
    _longitude = newLongitude;
    notifyListeners();
  }

  Future<void> setRadius(int newRadius) async {
    _radius = newRadius;
    notifyListeners();
  }

  // จาก Api Maneger_Id
  Future<void> setManagerid(int newManagerid) async {
    _managerid = newManagerid;
    notifyListeners();
  }

  Future<void> setManagername(String newManagername) async {
    _managername = newManagername;
    notifyListeners();
  }

  Future<void> clearData() async {
    _token = '';
    _userid = null;
    _employeeid = null;
    _companyid = null;
    _worklocationid = null;
    _calendarid = null;
    // _attendanceuserid = null;
    _employeename = '';
    _employeerole = '';
    _employeedepartment = '';
    _employeeemail = '';
    _employeemobilephone = '';
    _checkin = '';
    _checkout = '';
    _employeeImage = '';
    _locationName = '';
    _latitude = null;
    _longitude = null;
    _radius = null;
    _managerid = null;
    _managername = '';

    notifyListeners(); // แจ้ง UI ให้ทำการอัปเดตข้อมูล
  }
}
