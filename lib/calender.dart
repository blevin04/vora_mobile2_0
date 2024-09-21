// ignore_for_file: sized_box_for_whitespace, non_constant_identifier_names

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:vora_mobile/utils.dart';


final store_ = FirebaseStorage.instance.ref();
final firestore = FirebaseFirestore.instance.collection("Events");
List<DateTime> eventdate = List.empty(growable: true);
List<String> eventId = List.empty(growable: true);
class Calender extends StatefulWidget {
  const Calender({super.key});

  @override
  State<Calender> createState() => _CalenderState();
}

Future<List<String>> getIds()async{
  List<String> eveids = List.empty(growable: true);
 await firestore.where("Title",isNotEqualTo: null).get().then((onValue)async{
    for(var val in onValue.docs){
      if (!eventId.contains(val.id)) {
        eventId.add(val.id);
        eveids.add(val.id);
      }
      if (!eventData.containsKey(val.id)) {
        await geteventsData(val.id);
      }
     
    }
  });
//print(eventdate);
  return eveids;
}
Future<Map<String,dynamic>> getevent(String eventId)async{
  Map<String,dynamic> data = {};

  await firestore.doc(eventId).get().then((onValue1){
    final title_ = <String,dynamic>{"Title":onValue1.data()!["Title"]} ;
    final reg_link =<String,dynamic>{"Reg_Link": onValue1.data()!["Regestration"]};
    final description =<String,dynamic>{"Descrip": onValue1.data()!["Description"]};
    data.addAll(title_);
    data.addAll(reg_link);
    data.addAll(description);
  });
  await store_.child("events/$eventId/cover").getData().then((onValue2){
    final cover = <String,dynamic>{"Cover":onValue2!};
    data.addAll(cover);
  });
  return data;
}

class _CalenderState extends State<Calender> {
  DateTime selected = DateTime.now();
  @override
  Widget build(BuildContext context) {
    double windowwidth = MediaQuery.of(context).size.width;
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
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          title: const Text(
            "My Calendar",
            style: TextStyle(color: Colors.white),
          ),
        ),
        
        body: Column(
          children: [
            FutureBuilder(
              future: getIds(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(),);
                }
                for(var singleEvent in snapshot.data){
                  if (!eventData.containsKey(singleEvent)){
                    
                  }
                }
                return Column(
                  children: [
                    Container(
                    width: MediaQuery.of(context).size.width,
                    child: TableCalendar(       
                                
                      selectedDayPredicate: (date) {
                        final keys_ = eventData.keys.toList();
                        for (var i = 0; i < eventData.length; i++) {
                          final eventdates = eventData[keys_[i]]!["EventDate"].toDate();
                           if (isSameDay(eventdates, date)) {
                          return true;
                        }
                        }
                       if( date == selected){
                        return true;
                       }
                       return false;
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          selected = selectedDay;
                        });                    
                      },
                        daysOfWeekStyle: const DaysOfWeekStyle(
                            weekendStyle: TextStyle(
                                color: Color.fromARGB(255, 170, 166, 166)),
                            weekdayStyle: TextStyle(
                                color: Color.fromARGB(255, 253, 253, 253))),
                        headerStyle: HeaderStyle(
                            formatButtonDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color.fromARGB(255, 56, 54, 54))),
                            formatButtonTextStyle:
                                const TextStyle(color: Colors.white),
                            titleTextStyle: const TextStyle(color: Colors.white)),
                            eventLoader: (day) {
                              bool eventpassed = false;
                              eventData.forEach((key, value){
                                DateTime t = DateTime.now();
                                if (value["EventDate"].toDate().isBefore(DateTime.now())
                                    && isSameDay(value["EventDate"].toDate(), day)
                                ) {
                                  eventpassed = true;
                                }
                              });
                              if (eventpassed) {
                                return ["ok den ok den"];
                              }
                              return [];
                            },
                            
                        calendarStyle:const CalendarStyle(
                          
                          // dayTextFormatter: (date, locale) {
                            
                          // },
                          
                          todayDecoration: BoxDecoration(shape: BoxShape.circle,color: Color.fromARGB(119, 255, 255, 255)),
                          weekendTextStyle: TextStyle(color: Colors.white),
                          selectedDecoration: BoxDecoration(
                            shape: BoxShape.circle,color: Color.fromARGB(255, 83, 94, 247)),
                            defaultTextStyle: TextStyle(
                                color: Color.fromARGB(255, 250, 253, 255)),
                            outsideTextStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 98))),
                        focusedDay: selected,
                        firstDay: DateTime(2000),
                        lastDay: DateTime(2030))
                        
                        ),
                  const SizedBox(height: 30,),
                  Builder(
                    builder: (context) {
                      Map<String,dynamic> event = {};
                      eventData.forEach((key, value) {
                        if (eventData[key]!["EventDate"].toDate().day == selected.day
                            && eventData[key]!["EventDate"].toDate().month == selected.month
                            && eventData[key]!["EventDate"].toDate().year == selected.year
                          ) {
                          event = value;
                        }
                      },);
                      return 
                      event.isNotEmpty?
                      Container(
                        padding:const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)
                          ,border: Border.all(color: const Color.fromARGB(88, 255, 255, 255))),
                        child: Column(
                              children: [
                                Text(event["Title"],style: const TextStyle(color: Colors.white),),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(period(event["EventDate"].toDate()),
                                  style:const TextStyle(color: Colors.white),),
                                ),
                                Text(event["Description"].toString(),style:const TextStyle(color: Colors.white),)
                               
                              ],
                        ),
                      ):
                      Container(
                        child:const Text("No event on this day",style: TextStyle(color: Colors.white),),
                      );
                    }
                  )
                  ],
                );
              },
            ),       
            // Visibility(
            //     child: Container(
            //       decoration: BoxDecoration(border: Border.all(color: const Color.fromARGB(255, 73, 70, 70)),borderRadius: BorderRadius.circular(10)),
            //   width: windowwidth,
            //   child: SingleChildScrollView(
            //     scrollDirection: Axis.vertical,
            //     child: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: FutureBuilder(
            //         future: getdata(),
            //         builder: (BuildContext context, AsyncSnapshot snapshot) {
            //           if (snapshot.connectionState == ConnectionState.waiting) {
            //             return const Center(child: CircularProgressIndicator(),);
            //           }
            //           if (!snapshot.hasData) {
            //              return const Center(child: CircularProgressIndicator(),);
            //           }
            //           if (snapshot.connectionState == ConnectionState.none) {
            //                         return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
            //                       }
            //       var d = eventdate.indexWhere((test)=>test.day == selected.day && test.month == selected.month && test.year == selected.year);
                    
            //           return d>=0? FutureBuilder(
            //             future: getevent(eventId[d]),
            //             builder: (BuildContext context, AsyncSnapshot snapshot) {
            //               if (snapshot.connectionState == ConnectionState.waiting) {
            //                 return const Center(child: CircularProgressIndicator(),);
            //               }
            //               if(!snapshot.hasData){
            //               return  const Center(child: CircularProgressIndicator(),);
            //               }
            //               if (snapshot.connectionState == ConnectionState.none) {
            //                         return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
            //                       }
            //               String titles_ = snapshot.data["Title"];
            //               String decrip = snapshot.data["Descrip"];
                         
            //               int tim_h = eventdate[d].hour;
            //               int tim_m = eventdate[d].minute;
            //               return 
            //             },
            //           ):const Center(child: Text("No registered events on this day",style: TextStyle(color: Colors.white),),);
                     
                      
            //         },
            //       ),
            //     ),
                   
            //   ),
            // ))
          ],
        ),
      ),
    );
  }
}
