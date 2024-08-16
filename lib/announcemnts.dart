import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vora_mobile/homepage.dart';

class Announcemnts extends StatefulWidget {
  const Announcemnts({super.key});

  @override
  State<Announcemnts> createState() => _AnnouncemntsState();
}
final store = FirebaseStorage.instance.ref();
final firestore = FirebaseFirestore.instance;

Future<List<String>>getannouncements() async{
  List<String> AnnouncemntsIds = List.empty(growable: true);
 await firestore.collection("Announcements").where("AnnouncementId", isNotEqualTo: null).get().then((onValue){
  for(var val in onValue.docs){
    AnnouncemntsIds.add(val.id);
    print("vall = $val");
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
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Homepage()));
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
                future: firestore.collection("Announcements").doc(snapshot.data[index]).get(),
                builder: (BuildContext context, AsyncSnapshot snapshot2) {
                  if (snapshot2.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(),);
                  }
                  if (!snapshot2.hasData) {
                    return const Center(child: CircularProgressIndicator(),);
                  }
                  if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                  String titles_ =snapshot2.data["Title"];
                  String data_ = snapshot2.data["Description"];
                  String club_ = snapshot2.data["Community"];
                  return Card(
                    color: const Color.fromARGB(255, 26, 26, 26),
                    margin: EdgeInsets.all(10),
                    elevation: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 50,
                          child: Row(
                            children: [
                              CircleAvatar(),
                              Padding(padding: EdgeInsets.only(left: 10),child: Text(club_,style: TextStyle(color: Colors.white,fontSize: 18),),)
                            ],
                          ),
                        ),
                        Text(titles_,style:const TextStyle(color:  Colors.white,fontSize: 18) ),
                        Center(child: Text(data_,style:const TextStyle(color:  Colors.white,) ),)
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
