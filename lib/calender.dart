import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:table_calendar/table_calendar.dart';

import 'package:vora_mobile/homepage.dart';

final store_ = FirebaseStorage.instance.ref();
final firestore = FirebaseFirestore.instance.collection("Events");
List<DateTime> eventdate = List.empty(growable: true);
List<String> eventId = List.empty(growable: true);
class Calender extends StatefulWidget {
  const Calender({super.key});

  @override
  State<Calender> createState() => _CalenderState();
}
Future<String> getdata()async{
 await firestore.where("Title",isNotEqualTo: null).get().then((onValue)async{
    for(var val in onValue.docs){
      if (!eventId.contains(val.id)) {
        eventId.add(val.id);
      }
      
      await firestore.doc(val.id).get().then((value)async{
        DateTime dat =await value.data()!["EventDate"].toDate();
        if (!eventdate.contains(dat)) {
          eventdate.add(dat);
        }
      });
    }
  });
print(eventdate);
  return "ok";
}
Future<Map<String,dynamic>> getevent(String eventId)async{
  Map<String,dynamic> data =Map();

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
              onPressed: () => Navigator.pushReplacement(context,
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
                  selectedDayPredicate: (date) {
                    for (var i = 0; i < eventdate.length; i++) {
                       if (eventdate[i].day==date.day && eventdate[i].month == date.month && eventdate[i].year == date.year) {
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
                    calendarStyle: const CalendarStyle(
                      weekendTextStyle: TextStyle(color: Colors.white),
                      selectedDecoration: BoxDecoration(shape: BoxShape.circle,color: Colors.blue),
                        defaultTextStyle: TextStyle(
                            color: Color.fromARGB(255, 106, 177, 228)),
                        outsideTextStyle: TextStyle(color: Color.fromARGB(255, 81, 80, 78))),
                    focusedDay: DateTime.now(),
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2030))),
                    const SizedBox(height: 30,),
            Visibility(
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: const Color.fromARGB(255, 73, 70, 70)),borderRadius: BorderRadius.circular(10)),
              width: _width,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder(
                    future: getdata(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(),);
                      }
                      if (!snapshot.hasData) {
                         return const Center(child: CircularProgressIndicator(),);
                      }
                      if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                  var d = eventdate.indexWhere((test)=>test.day == selected.day && test.month == selected.month && test.year == selected.year);
                    
                      return d>=0? FutureBuilder(
                        future: getevent(eventId[d]),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(),);
                          }
                          if(!snapshot.hasData){
                          return  const Center(child: CircularProgressIndicator(),);
                          }
                          if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                          String titles_ = snapshot.data["Title"];
                          String decrip = snapshot.data["Descrip"];
                          int tim_h = eventdate[d].hour;
                          int tim_m = eventdate[d].minute;
                          return Column(
                        children: [
                          Container(
                            child: Text(titles_,style: const TextStyle(color: Colors.white),),
                          ),
                          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.white)),child:Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("From  $tim_h: $tim_m ",style: TextStyle(color: Colors.white),),
                          ),),
                          Text(decrip,style:const TextStyle(color: Colors.white),)
                         
                        ],
                                          );
                        },
                      ):const Center(child: Text("No registered events on this day",style: TextStyle(color: Colors.white),),);
                     
                      
                    },
                  ),
                ),
                   
                
              ),
            ))
          ],
        ),
      ),
    );
  }
}
