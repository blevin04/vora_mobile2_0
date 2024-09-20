// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:vora_mobile/utils.dart';

class Announcemnts extends StatefulWidget {
  const Announcemnts({super.key});

  @override
  State<Announcemnts> createState() => _AnnouncemntsState();
}
final store = FirebaseStorage.instance.ref();
final firestore = FirebaseFirestore.instance;

Future<Map<String,dynamic>> getannouncementData(String anId)async{
Map<String,dynamic> data = {};
String comId = "";
  await firestore.collection("Announcements").doc(anId).get().then((onValue){
    data.addAll(onValue.data()!) ;
    comId = onValue.data()!["Community"];
    
  });//voramobile-70ba7.appspot.com/communities/1c743d70-4cbb-11ef-bff1-d967d3b04270
  await firestore.collection("Communities").where("Name", isEqualTo: comId).get().then((onValu){
   for(var dat in onValu.docs){
   // print("object= ${dat.data()}");
    comId = dat.id;
   }
  });

  await store.child("/communities/$comId/cover_picture").getData().then((onValue){
    final img = <String,dynamic>{"Cover_picture":onValue!};
    data.addAll(img);
  });

return data;
}


Future<List<String>>getannouncements() async{
  List<String> AnnouncemntsIds = List.empty(growable: true);
 await firestore.collection("Announcements").where("AnnouncementId", isNotEqualTo: null).get().then((onValue){
  for(var val in onValue.docs){
    AnnouncemntsIds.add(val.id);
   // print("vall = $val");
  }
  });
  return AnnouncemntsIds;
}

class _AnnouncemntsState extends State<Announcemnts> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
          255,
          29,
          36,
          45,
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon:const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
            title:const Text("Announcements",
            style: TextStyle(color: Colors.white),),
      ),

      body: FutureBuilder(
        future: getannouncements(),
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
          
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder(
                future: getannouncementData(snapshot.data[index]),
                builder: (BuildContext context, AsyncSnapshot snapshot2) {
                  if (snapshot2.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(),);
                  }
                  if (!snapshot2.hasData) {
                    return const Center(child: Text("Error occured",style: TextStyle(color: Colors.white),),);
                  }
                  if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                  String titles_ =snapshot2.data["Title"];
                  String data_ = snapshot2.data["Description"];
                  String club_ = snapshot2.data["Community"];
                  Uint8List cover_picture = snapshot2.data!["Cover_picture"];
                  DateTime ttime = snapshot2.data!["AnnounceTime"].toDate();
                  return Card(
                    color: const Color.fromARGB(134, 38, 37, 37),
                    margin:const EdgeInsets.all(10),
                    elevation: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding:const EdgeInsets.all(5),
                          height: 70,
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: MemoryImage(cover_picture),
                              ),
                              Padding(padding:const EdgeInsets.only(left: 10),child: Text(club_,
                              style:const TextStyle(color: Colors.white,fontSize: 18),),)
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(titles_,style:const TextStyle(color:  Colors.white,fontSize: 18) ),
                            Text(period(ttime),style:const TextStyle(color: Colors.white),)
                          ],
                        ),
                        Center(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(data_,style:const TextStyle(color:  Colors.white,) ),
                        ),)
                      ],
                    ),
                    
                  );
                },
              );
            },
          );
        },
      ),

    ));
  }
}
