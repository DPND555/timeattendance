import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeattendance/api.dart';

class Leavework extends StatefulWidget {
  const Leavework({super.key});

  @override
  State<Leavework> createState() => _LeaveworkState();
}

class _LeaveworkState extends State<Leavework> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: MyColors.red,
        centerTitle: true,
        title: Text(
          'Calendar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: DateTime.now(),
            availableGestures: AvailableGestures.all,
            headerStyle:
                HeaderStyle(formatButtonVisible: false, titleCentered: true),
          )
        ],
      ),
    );
  }
}
