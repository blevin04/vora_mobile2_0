import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vora_mobile/dedicated/DedicatedCommunityPage.dart';
import 'package:vora_mobile/firebase_Resources/add_content.dart';
import 'package:vora_mobile/utils.dart';


class Dedicatedeventpage extends StatefulWidget{
 final  String eventId;
  const Dedicatedeventpage({super.key, required this.eventId
  
  } );
  @override
  State<Dedicatedeventpage> createState() => _DedicatedeventpageState();
}

final firestore_1 = FirebaseFirestore.instance;
final firestorage = FirebaseStorage.instance.ref();
Future<String> getname(String evId)async{
  String eventName = "Unknown";
  await firestore_1.collection("Events").doc(evId).get().then((evdata){
    eventName = evdata.data()!["Title"].toString();
  });

  return eventName;
}

Future<Map<String, dynamic>> getevent(String evId)async{
  Map<String,dynamic> eventdata = Map();
  await firestore_1.collection("Events").doc(evId).get().then((onValue)async{
    final data1 = onValue.data()!;
    
    final commId = data1["Community"];
    final comId = <String,dynamic>{"ComId":commId};
    
    eventdata.addAll(comId);
    await firestore_1.collection("Communities").doc(commId).get().then((val){
      final comdata = <String,dynamic>{"ComName": val.data()!["Name"]};
      final numbers = <String,dynamic>{"Numbers":val.data()!["Numbers"]};
      eventdata.addAll(numbers);
      eventdata.addAll(comdata);
    });
    await firestorage.child("/communities/$commId/cover_picture").getData().then((cImg){
      final commImg = <String,dynamic>{"ComImg": cImg!};
      
      eventdata.addAll(commImg);  
    });
    eventdata.addAll(data1);
  });
  await firestorage.child("/events/$evId/").list().then((docs)async{
    List<Uint8List> imgList = List.empty(growable: true);
    for(var imgs in docs.items){
      var path = imgs.toString().split(":").last;
        path = path.split(")").first;
        path =path.split(":").last;
        path = path.split(" ").last;
        print(path);
      await firestorage.child(path).getData().then((imgdata){
        imgList.add(imgdata!); 
       
      });
    }
    final imgmap = <String,dynamic>{"Images":imgList};
    eventdata.addAll(imgmap);
  });

  return eventdata;
}

class _DedicatedeventpageState extends State<Dedicatedeventpage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(onPressed: ()=>Navigator.pop(context), icon:const Icon(Icons.arrow_back,color: Colors.white,)
        ),
        title: FutureBuilder(
          future: getname(widget.eventId),
          initialData: "....",
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState==ConnectionState.waiting) {
              return const Center(child: CircleAvatar(),);
            }

            return Text(snapshot.data,style:const TextStyle(color: Colors.white),);
          },
        ),
        
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: getevent(widget.eventId),
          
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(),);
            }
            if (snapshot.connectionState == ConnectionState.none) {
              return const Center(child: Column(
                children: [
                  Icon(Icons.wifi_off_outlined,color: Colors.white,),
                  Text("No internet access",style: TextStyle(color: Colors.white),),
                ],
              ),);
            }
            
            List<Uint8List> imgsData = snapshot.data!["Images"];
            Uint8List CommImage = snapshot.data!["ComImg"];
            String CommName = snapshot.data!["ComName"].toString();
           Map<String,dynamic> contacts = snapshot.data!["Numbers"];
            
            DateTime eTime = snapshot.data!["EventDate"].toDate();
            String eventTime = period(eTime);
            String about = snapshot.data!["Description"];
            String EventName = snapshot.data!["Title"];
            bool liked = false; //change to add a checker
            bool commented = false;
            int comments = 0;
            int likes = 0;
            String comId_ = snapshot.data!["ComId"];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 300,
                    child: Stack(
                      children: [
                        ListView.builder(
                          itemCount: imgsData.length,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          //reverse: true,
                          
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 250,
                              child: Image.memory(imgsData[index]),
                              );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(color: Colors.transparent,border: Border.all(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: MemoryImage(CommImage),
                                      radius: 28,
                                    ),
                                    SizedBox(width: 20,),
                                    Text(CommName,style:const TextStyle(color: Colors.white),)
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(color: Colors.transparent,
                                border: Border.all(color: const Color.fromARGB(255, 65, 64, 64)),borderRadius: BorderRadius.circular(10)),
                                padding:const EdgeInsets.all(10),
                                child: Text(eventTime,style:const TextStyle(color: Colors.white),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Text(about,style:const TextStyle(color: Colors.white),),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StatefulBuilder(
                      builder: (BuildContext context, setState_like) {
                        return Column(
                          children: [IconButton(onPressed: (){
                            setState_like((){
                              liked = !liked;
                              liked? 
                              likes++:likes--;
                            });
                          }, //function to like / unlike the event
                          icon: Icon(Icons.favorite_sharp,color: liked?Colors.red:const Color.fromARGB(255, 74, 73, 73),)),
                          Text(likes.toString(),style: TextStyle(color:liked? Colors.white:const Color.fromARGB(255, 77, 75, 75)),)
                          ],
                        );
                      },
                    ),
                    StatefulBuilder(
                      builder: (BuildContext context, setState_comment) {
                        return Column(
                          children: [
                            IconButton(onPressed: (){
                              setState_comment((){
                                commented = !commented;
                              });
                            }, icon: Icon(Icons.comment,color:
                             commented?Colors.blue:const Color.fromARGB(255, 76, 74, 74),)),
                             Text(comments.toString(),style: TextStyle(color: 
                             commented?Colors.white:const Color.fromARGB(255, 101, 98, 98)),)
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Visibility(
                  visible: eTime.isAfter(DateTime.now()),
                  child: InkWell(
                    onTap: ()async {
                      String status = "Error Occured";
                     status = await rsvp(eventId: widget.eventId);
                     if (status == "Success") {
                       showsnackbar(context, "RSVP'd Successfully to $EventName");
                     }
                     else{
                      showsnackbar(context, "Ann error occured please try again");
                     }
                     },
                  child: Container(decoration: BoxDecoration(color: Colors.green,
                  borderRadius: BorderRadius.circular(10)),
                  child:const Center(child:  Text("RSVP",style: TextStyle(color: Colors.white),),),
                  ),
                )),
                const SizedBox(height: 20,),
                InkWell(
                  onTap: (){},//Open the resources link 
                  child: Container(
                    padding:const EdgeInsets.only(right: 50),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.transparent,borderRadius: BorderRadius.circular(10)),
                    child:const Row(
                      children: [
                        Text("Resources",style: TextStyle(color: Colors.white),),
                        SizedBox(width: 20,)
                        ,Icon(Icons.book,color: Colors.white,)
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(onPressed: ()async{
                  await Navigator.push(context, MaterialPageRoute(builder: (context)=>Dedicatedcommunitypage(clubId: comId_,)));
                }, //community page
                child: Text(CommName,style:const TextStyle(color: Colors.white),)),
                const SizedBox(height: 10,),
                TextButton(onPressed: (){},//events from the club
                 child: Text("More events from $CommName",style:const TextStyle(color: Colors.white),)),
                ListView.builder(
                  itemCount: contacts.length,
                  shrinkWrap: true,
                  physics:const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    String key_ = contacts.keys.toList()[index];
                    return ListTile(
                      onTap: (){}, //go to the page of community
                      leading: getIcon(key_),
                      title: Text(key_,style:const TextStyle(color: const Color.fromARGB(215, 255, 255, 255)),),
                    );
                  },
                ),
               const SizedBox(height: 20,),
               const Divider()

              ],
            );
          },
        ),
      ),
    );
  }
}