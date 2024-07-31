import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vora_mobile/homepage.dart';

class Calender extends StatefulWidget {
  const Calender({super.key});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    //   double _height = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black45,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(
            255,
            29,
            36,
            45,
          ),
          leading: IconButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Homepage())),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          title: const Text(
            "My Callender",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                child: TableCalendar(
                    daysOfWeekStyle: const DaysOfWeekStyle(
                        weekendStyle: TextStyle(
                            color: Color.fromARGB(255, 170, 166, 166)),
                        weekdayStyle: TextStyle(
                            color: Color.fromARGB(255, 176, 175, 175))),
                    headerStyle: HeaderStyle(
                        formatButtonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color.fromARGB(255, 56, 54, 54))),
                        formatButtonTextStyle:
                            const TextStyle(color: Colors.white),
                        titleTextStyle: const TextStyle(color: Colors.white)),
                    calendarStyle: const CalendarStyle(
                        defaultTextStyle: TextStyle(
                            color: Color.fromARGB(255, 218, 225, 230)),
                        outsideTextStyle: TextStyle(color: Colors.amber)),
                    focusedDay: DateTime.now(),
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2030))),
            Visibility(
                child: Container(
              width: _width,
              child: Column(
                children: [
                  Container(),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
