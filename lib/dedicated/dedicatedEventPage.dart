import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vora_mobile/Accounts.dart';
import 'package:vora_mobile/dedicated/DedicatedCommunityPage.dart';
import 'package:vora_mobile/events.dart';
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
bool commentsOpen = false;
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
  List<dynamic> imgList = List.empty(growable: true);
  if (eventData[evId]!["Images"].isNotEmpty) {
   // print(eventData[evId]!["Images"].length);
    imgList = eventData[evId]!["Images"]; 
  }else{
      await firestorage.child("/events/$evId/").list().then((docs)async{
    for(var imgs in docs.items){
      var path = imgs.toString().split(":").last;
        path = path.split(")").first;
        path =path.split(":").last;
        path = path.split(" ").last;
       // print(path);
      await firestorage.child(path).getData().then((imgdata){
        imgList.add(imgdata!); 
       
      });
    }
    
  });
  }
    final imgmap = <String,dynamic>{"Images":imgList};
    eventdata.addAll(imgmap);

  return eventdata;
}
TextEditingController commentEventsDpageController = TextEditingController();
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
      body: RefreshIndicator(
        onRefresh: ()async{
          setState(() {
          });
        },
        child: SingleChildScrollView(
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
              if (!snapshot.hasData) {
                return const Center(child: Text("Error occured refresh page"),);
              }
              
              List<dynamic> imgsData = snapshot.data!["Images"];
              Uint8List CommImage = snapshot.data!["ComImg"];
              String CommName = snapshot.data!["ComName"].toString();
             Map<String,dynamic> contacts = snapshot.data!["Numbers"];
              
              DateTime eTime = snapshot.data!["EventDate"].toDate();
              String eventTime = period(eTime);
              String about = snapshot.data!["Description"];
              String EventName = snapshot.data!["Title"];
             
              bool liked = snapshot.data!["Likes"].contains(user.uid); 
              var  commented = false;
              //change to add a checker
              snapshot.data!["Comments"].forEach((keys,value){
                if (value.containsValue(user.uid)) {
                  commented = true;
                }
              });
              
              int comments = snapshot.data!["Comments"].length;
              int likes = snapshot.data!["Likes"].length;
              String comId_ = snapshot.data!["ComId"];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 300,
                      child: Stack(
                        children: [
                          ListView.builder(
                            itemCount: imgsData.length,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            //reverse: true,
                            
                            itemBuilder: (BuildContext context, int index) {
                              return SizedBox(
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
                                  padding:const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: const Color.fromARGB(135, 0, 0, 0)
                                  ,border: Border.all(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: MemoryImage(CommImage),
                                        radius: 28,
                                      ),
                                     const SizedBox(width: 20,),
                                      Text(CommName,style:const TextStyle(color: Colors.white),)
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(color: const Color.fromARGB(135, 0, 0, 0),
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
                    padding:const EdgeInsets.all(10),
                    child: Text(about,style:const TextStyle(color: Colors.white),),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  StatefulBuilder(
                    builder: (BuildContext context, setStaterow) {
                      return Column(
                        children: [
                          Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Visibility(
                            visible: commentsOpen,
                            child:Row(
                              children: [
                                SizedBox(
                                  height: 60,
                                  width: 200,
                                  child: TextField(
                                  onTapOutside: (event) => FocusScope.of(context).requestFocus(FocusNode()) ,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:  const BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                      labelText: "Add comment",
                                      labelStyle: const TextStyle(
                                          color: Color.fromARGB(255, 161, 159, 159))),
                                  controller: commentEventsDpageController,
                                    ),
                                ),
                                IconButton(onPressed: (){
                                  comment_(widget.eventId, commentEventsDpageController.text);
                                  setStaterow((){
                                    commentEventsDpageController.clear();
                                    commented = !commented;
                                  });
                                }, icon:const Icon(Icons.send,color: Colors.blue,))
                              ],
                            ) ),
                            Row(
                              children: [
                                Column(
                            children: [IconButton(onPressed: (){
                              likeEvent(widget.eventId);
                              setStaterow((){
                                liked = !liked;
                                liked? 
                                likes++:likes--;
                                 
                              });
                            }, //function to like / unlike the event
                            icon: Icon(Icons.favorite_sharp,color: liked?Colors.red:const Color.fromARGB(255, 74, 73, 73),)),
                            Text(likes.toString(),style: TextStyle(color:liked? Colors.white:const Color.fromARGB(255, 77, 75, 75)),)
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(onPressed: (){
                                setStaterow(() {
                                  commentsOpen = !commentsOpen;
                                  
                                });
                              }, icon: Icon(Icons.comment,color:
                               commented?Colors.blue:const Color.fromARGB(255, 76, 74, 74),)),
                               Text(comments.toString(),style: TextStyle(color: 
                               commented?Colors.white:const Color.fromARGB(255, 101, 98, 98)),)
                            ],
                          ),
                              ],
                            ),
                            ],
                          ),
                          Visibility(
                visible: commentsOpen,
                child: StreamBuilder(
                  stream: firestore_1.collection("Events").doc(widget.eventId).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(),);
                    }
                    Map<String,dynamic> comAll = snapshot.data!["Comments"];
                    
                    return InkWell(
                      onTap: (){},
                      splashColor: Colors.transparent,
                      child: Container(
                        constraints:const BoxConstraints(minHeight: 70,maxHeight: 200),
                        child:comAll.isEmpty?const Text("No comments yet",style: TextStyle(color: Colors.white),) :
                         ListView.builder(
                        shrinkWrap: true,
                        
                        itemCount: comAll.length,
                        itemBuilder: (BuildContext context, int index) {
                          List commentKeys = comAll.keys.toList();
                          String ownerOfComment = comAll[commentKeys[index]]["UserName"];
                          DateTime ttime = comAll[commentKeys[index]]["TimeStamp"].toDate();
                          String comContent = comAll[commentKeys[index]]["Comment"];
                          List LikesCom = comAll[commentKeys[index]]["Likes"];
                         
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding:const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                                                        
                                color: const Color.fromARGB(205, 14, 13, 13),
                                borderRadius: BorderRadius.circular(10)
                              
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [Text(ownerOfComment,style:const TextStyle(color: Colors.white),),
                                    const SizedBox(width: 10,),
                                    Text(period(ttime),style:const TextStyle(color: Colors.white),softWrap: true,)],
                                  ),
                                  StatefulBuilder(
                                    builder: (BuildContext context, setStatecom) {
                                      return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(comContent,style:const TextStyle(color: Colors.white),),
                                      Badge(
                                  backgroundColor: Colors.transparent,
                                  offset:const Offset(-5,20),
                                 // alignment: Alignment.bottomRight,
                                  label: Text(LikesCom.length.toString(),style:const TextStyle(color: Colors.white),),
                                  child: IconButton(onPressed: (){
                                    likecomment("Events", widget.eventId, commentKeys[index]);
                                    setStatecom(() {
                                      LikesCom.contains(user.uid)?
                                      LikesCom.remove(user.uid):
                                      LikesCom.add(user.uid);
                                      
                                    });
                                      
                                    
                                  }, icon: Icon(Icons.favorite,color:LikesCom.contains(user.uid)?Colors.red:
                                   Colors.white,size: 18,))),
                                      
                                    ],
                                  );
                                    },
                                  ),
                                  
                                ],
                              ),
                            ),
                          );
                        },
                                                              ),
                      ),
                    );
                  }
                ),)  
                        ],
                      );
                    },
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
                    child: Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.green,
                    borderRadius: BorderRadius.circular(10)),
                    child:const Center(child:  Text("RSVP",style: TextStyle(color: Colors.white),),),
                    ),
                  )),
                  const SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: InkWell(
                      enableFeedback: false,
                      splashColor: Colors.transparent,
                      onTap: (){},//Open the resources link 
                      child: Center(
                        child: Container(
                          padding:const EdgeInsets.only(right: 50),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.transparent,borderRadius: BorderRadius.circular(10)),
                          child:const Row(
                            children: [
                              Text("Club Resources",style: TextStyle(color: Colors.white),),
                              SizedBox(width: 20,)
                              ,Icon(Icons.book,color: Colors.white,)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(onPressed: ()async{
                    await Navigator.push(context, MaterialPageRoute(builder: (context)=>Dedicatedcommunitypage(clubId: comId_,)));
                  }, //community page
                  child: Text("About $CommName",style:const TextStyle(color: Colors.white),)),
                  const SizedBox(height: 10,),
                  TextButton(onPressed: ()async{
                   await Navigator.push(context, MaterialPageRoute(builder: (context)=> Events(filtername: CommName,)));
                  },//events from the club
                   child: Text("More events from $CommName",style:const TextStyle(color: Colors.white),)),
                  ListView.builder(
                    itemCount: contacts.length,
                    shrinkWrap: true,
                    physics:const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      String key_ = contacts.keys.toList()[index];
                      final Uri url = Uri.parse(contacts[key_]);
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onTap: (){
                            openUrl(url);
                          }, //go to the page of community
                          leading: getIcon(key_),
                          title: Text(key_,style:const TextStyle(color: const Color.fromARGB(215, 255, 255, 255)),),
                        ),
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
      ),
    );
  }
}