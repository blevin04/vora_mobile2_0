// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:vora_mobile/Accounts.dart';
import 'package:vora_mobile/clubs.dart';

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
  if (userData.isEmpty) {
    await firestore.collection("users").doc(user.uid).get().then((userd){
    userData.addAll(userd.data()!);
  });
  }
  List comms =userData["Communities"];
  List comnames = List.empty(growable: true);
  for(var commidd in comms){
    await firestore.collection("Communities").doc(commidd).get().then((comdata){
      comnames.add(comdata.data()!["Name"]);
    });
  }
  for(var comname in comnames){
    await firestore.collection("Announcements").where("Community",isEqualTo: comname).get().then(( onval1)async{
      for(var vall in onval1.docs){
        List viewd = List.empty(growable: true);
      await firestore.collection("Announcements").doc(vall.id).get().then((check){
        viewd = check.data()!["Viewed"];
      });
      if (!viewd.contains(user.uid)) {
         AnnouncemntsIds.add(vall.id);
      }
      }
    });
  }
  
//  await firestore.collection("Announcements").where("AnnouncementId", isNotEqualTo: null).get().then((onValue){
//   for(var val in onValue.docs){
//     AnnouncemntsIds.add(val.id);
//    // print("vall = $val");
//   }
//   });
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
            actions: [
              IconButton(onPressed: ()async{
                showcircleprogress(context);
                String state = await markAsRead("",true);
                if (state == "Success") {
                  setState(() {
                  });
                }
                Navigator.pop(context);
              },
               icon:const Icon(Icons.checklist_rtl_sharp,color: Colors.white,))
            ],
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
          if (snapshot.data.isEmpty) {
            List comms = userData["Communities"];
            return  Center(child: 
            TextButton(child: Text(comms.isEmpty?"Join Club to view its Announcements..":
                "No Announcemnts."
                ),
            onPressed: ()async {
              comms.isEmpty?
              await Navigator.push(context, MaterialPageRoute(builder: (context)=>const Clubs())):
                null;
            },));
          }
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder(
                future: getannouncementData(snapshot.data[index]),
                builder: (BuildContext context, AsyncSnapshot snapshot2) {
                  if (snapshot2.connectionState == ConnectionState.waiting) {
                    return  Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        decoration: BoxDecoration(color: const Color.fromARGB(59, 255, 255, 255),borderRadius: BorderRadius.circular(10)),
                      child:const Center(child:  CircularProgressIndicator()),
                      ),
                    );
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                CircleAvatar(
                                backgroundImage: MemoryImage(cover_picture),
                              ),
                              Padding(padding:const EdgeInsets.only(left: 10),child: Text(club_,
                              style:const TextStyle(color: Colors.white,fontSize: 18),),),
                              ],),
                              
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(period(ttime),style:const TextStyle(color: Colors.white),),
                              ),
                              IconButton(onPressed: ()async{
                                String state = await markAsRead(snapshot.data[index]);
                                if (state == "Success") {
                                  print(state);
                                  setState(() {
                                    
                                  });
                                }
                                print(state);
                              }, 
                              icon:const Icon(Icons.check_circle_outline_rounded ,color: Colors.white,))
                            ],
                          ),
                        ),
                        Text(titles_,style:const TextStyle(color:  Colors.white,fontSize: 18) ),
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
