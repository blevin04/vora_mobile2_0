import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vora_mobile/Accounts.dart';
import 'package:vora_mobile/dedicated/dedicatedEventPage.dart';
import 'package:vora_mobile/firebase_Resources/add_content.dart';

import 'package:vora_mobile/utils.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}
List<bool> viewComments = List.empty(growable: true);
final store = FirebaseStorage.instance.ref();
final firestore = FirebaseFirestore.instance;
Widget show =const Text(
  "Events",
  style: TextStyle(color: Colors.white),
);
var event_filter = [
  "all",
  "Registered",
  "not Registered",
  "From all clubs",
];
void getnewcomments(String evId)async{
  await firestore.collection("Events").doc(evId).get().then((onValue){
    var comm = onValue.data()!["Comments"];
    eventData[evId]!["Comments"]=comm;
  });
}
String event_value = "all";
bool events_vis = false;
TextEditingController commentText = TextEditingController();
TextEditingController _search_events = TextEditingController();
List<String> eventIds = List.empty(growable: true);
ValueNotifier<bool> Search_visible_ = ValueNotifier(false);
class _EventsState extends State<Events> {
  @override
  void initState() {
    if(eventIdsEventspage.isNotEmpty){
      for (var i = 0; i < eventIdsEventspage.length; i++) {
        viewComments.add(false);
      }
      
    }
    super.initState(); 
  }
  Future<void> getevents([String filter = "null"]) async {
    eventIds.clear();
    await firestore
        .collection("Events")
        .where("EventDate", isLessThan: Timestamp.now())
        .get()
        .then((onValue) {
      for (var snaps in onValue.docs) {
        eventIds.add(snaps["Uid"]);
        if (!eventIdsEventspage.contains(snaps["Uid"])) {
          eventIdsEventspage.add(snaps["Uid"]);
        }
        viewComments.add(false);
      }
    });
    
    // print(eventIds);
  }
  Future<Map<String,dynamic>> get_events(String eventId)async{
    Map<String,dynamic> even_m = Map();
    var comm_id;
    await firestore.collection("Events").doc(eventId).get().then((onValue){
      // final title = <String,dynamic>{"Title":onValue.data()!["Title"]};
     comm_id = onValue.data()!["Community"];
      // final date = <String,dynamic>{"EventDate":onValue.data()!["EventDate"]};
       var likes = onValue.data()!["Likes"];
      // final desc = <String,dynamic>{"Description":onValue.data()!["Description"]};
      even_m.addAll(onValue.data()!);
      try {
        var comments_ = onValue.data()!["Comments"];
      Map<String,dynamic>allComents = {"Comments":comments_};
      Map<String,dynamic>commentedalready = Map();
      if (comments_.contains(user.uid)) {
        commentedalready = {"Commented":true};
      }else{
        commentedalready = {"Commented":false};
      }
            even_m.addAll(commentedalready);
      
      } catch (e) {
        print(e.toString());
      }
      
      Map<String,dynamic> liked = Map();
      if (likes.contains(user.uid)){
        liked = {"Liked":true};
      }else{liked = {"Liked":false};}
     // even_m.addAll(title);
     // even_m.addAll(date);
      even_m.addAll(liked);
     // even_m.addAll(desc);
    });
    await firestore.collection("Communities").doc(comm_id).get().then((comN){
      final comname = <String,dynamic>{"EventClub":comN.data()!["Name"]};
      even_m.addAll(comname);
    });
    await firestore.collection("Communities").doc(comm_id).get().then((value){
      final comm_name = <String,dynamic>{"Club_Name":value.data()!["Name"]};
    even_m.addAll(comm_name);
    });

    await store.child("/communities/$comm_id/cover_picture").getData().then((value1){
      final c_images = <String,dynamic>{"Cover_Image":value1!};
      even_m.addAll(c_images);
    });
    await store.child("/events/$eventId/").list().then((onValue1)async{
      List<dynamic> imgs_ =List.empty(growable: true);
      
      for(var val in onValue1.items){
        var path = val.toString().split(":").last;
        path = path.split(")").first;
        path =path.split(":").last;
        path = path.split(" ").last;
       
         await store.child(path).getData().then((onValu){
          imgs_.add(onValu!);
        });
      }
      final img_paths = <String,dynamic>{"Images":imgs_};
      even_m.addAll(img_paths);
    });
    if (!eventData.containsKey(eventId)) {
      final curEvent = <String,Map<String,dynamic>>{eventId:even_m};
      eventData.addAll(curEvent);
    }
    return even_m;
  }

  late ListResult imgdir;
  Future<void> getimgs(int index) async {
    imgdir = await store.child("/events/${eventIds[index]}/").list();
  }

  Future<Uint8List?> getlocalimg(String path) async {
    var snap = await store.child(path).getData();
    return snap;
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
          255,
          29,
          36,
          45,
        ),
        leading: IconButton(
            onPressed: ()async {
              Navigator.pop(context);
            //  await Navigator.pushReplacement(context,
            //       MaterialPageRoute(builder: (context) => const Homepage()));
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: const Text(
          "Events",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () {
                
                  events_vis = !events_vis;
               Search_visible_.value = !Search_visible_.value;
              },
              icon: const Icon(
                Icons.search_sharp,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ListenableBuilder(
                  listenable: Search_visible_,
                  builder: (context,child) {
                    return Visibility(
                        visible: events_vis,
                        child: SizedBox(
                          width: 150,
                          child: TextField(
                            controller: _search_events,
                            decoration: const InputDecoration(
                                label: Icon(
                              Icons.search,
                              color: Colors.white,
                            )),
                          ),
                        ));
                  }
                ),
                const SizedBox(
                  width: 50,
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  child: DropdownButton(
                    dropdownColor: const Color.fromARGB(
                      255,
                      29,
                      36,
                      45,
                    ),
                    // Initial Value
                    value: event_value,

                    // Down Arrow Icon
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),

                    // Array list of items
                    items: event_filter.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(
                          items,
                          style:const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        event_value = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const Divider(
              color: Color.fromARGB(
                255,
                29,
                36,
                45,
              ),
            ),eventIdsEventspage.isEmpty?
            FutureBuilder(
                future: getevents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                  if (viewComments.isEmpty) {
                    for (var i = 0; i < eventIds.length; i++) {
                    viewComments.add(false);
                  }
                  }
                  
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: eventIds.length,
                      itemBuilder: (context, index2) {
                        
                        return eventData.containsKey(eventIds[index2])?
                        StatefulBuilder(
                          builder: (BuildContext context, setState_1) {
                             Uint8List C_image_comm = eventData[eventIds[index2]]!["Cover_Image"];
                            String Event_title = eventData[eventIds[index2]]!["Title"];
                            List<dynamic> event_imgs = eventData[eventIds[index2]]!["Images"];
                            DateTime time = eventData[eventIds[index2]]!["EventDate"].toDate();
                            String C_name = eventData[eventIds[index2]]!["Club_Name"];
                            String eventId_ = eventIds[index2];
                            String description = eventData[eventIds[index2]]!["Description"];
                            bool liked = eventData[eventIds[index2]]!["Liked"];
                            Map<String,dynamic> allComments = eventData[eventIds[index2]]!["Comments"];
                            bool commented = false;
                            return content(context, eventId_, C_image_comm, Event_title, time, C_name, event_imgs, liked, commented, _width, description,viewComments[index2],allComments);
                          },
                        )
                        
                        :
                        FutureBuilder(
                          future: get_events(eventIds[index2]),
                          
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return  Center(child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(decoration: BoxDecoration(color: const Color.fromARGB(255, 99, 94, 94),borderRadius: BorderRadius.circular(12)),height: 200,
                                child:const Center(child: CircularProgressIndicator(color: Colors.blue,),),
                                ),
                              ),);
                            }
                            if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                            if (!snapshot.hasData) {
                              return const Center(child: Text("Unable to fetch Events...",style: TextStyle(color: Colors.white),),);
                            }
                            Uint8List C_image_comm = snapshot.data!["Cover_Image"];
                            String Event_title = snapshot.data!["Title"];
                            List<dynamic> event_imgs = snapshot.data!["Images"];
                            DateTime time = snapshot.data!["EventDate"].toDate();
                            String C_name = snapshot.data!["Club_Name"];
                            String eventId_ = eventIds[index2];
                            String description = snapshot.data!["Description"];
                            bool liked = snapshot.data!["Liked"];
                            Map<String,dynamic> allComments = snapshot.data!["Comments"];
                            bool commented = false;
                            return content(context, eventId_, C_image_comm, Event_title, time, C_name, event_imgs, liked, commented, _width, description,viewComments[index2],allComments);
                          },
                        );
                        
                      });
                }):ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: homepageEvents.length,
                      itemBuilder: (context, index2) {
                        if (viewComments.isEmpty) {
                          for (var i = 0; i < homepageEvents.length; i++) {
                          viewComments.add(false);
                        }
                        }
                        
                        
                        return eventData.containsKey(homepageEvents[index2])?
                        StatefulBuilder(
                          builder: (BuildContext context, setState_1) {
                             Uint8List C_image_comm = eventData[homepageEvents[index2]]!["Cover_Image"];
                            String Event_title = eventData[homepageEvents[index2]]!["Title"];
                            List<dynamic> event_imgs = eventData[homepageEvents[index2]]!["Images"];
                            DateTime time = eventData[homepageEvents[index2]]!["EventDate"].toDate();
                            String C_name = eventData[homepageEvents[index2]]!["Club_Name"];
                            String eventId_ = homepageEvents[index2];
                            String description = eventData[homepageEvents[index2]]!["Description"];
                            bool liked = eventData[homepageEvents[index2]]!["Liked"];
                            Map<String,dynamic> allComments = eventData[homepageEvents[index2]]!["Comments"];
                            bool commented = false;
                            return content(context, eventId_, C_image_comm, Event_title, time, C_name, event_imgs, liked, commented, _width, description,viewComments[index2],allComments);
                          },
                        )
                        
                        :
                        FutureBuilder(
                          future: get_events(homepageEvents[index2]),
                          
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return  Center(child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(decoration: BoxDecoration(color: const Color.fromARGB(255, 99, 94, 94),borderRadius: BorderRadius.circular(12)),height: 200,
                                child:const Center(child: CircularProgressIndicator(color: Colors.blue,),),
                                ),
                              ),);
                            }
                            if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                            if (!snapshot.hasData) {
                              return const Center(child: Text("Unable to fetch Events...",style: TextStyle(color: Colors.white),),);
                            }
                            Uint8List C_image_comm = snapshot.data!["Cover_Image"];
                            String Event_title = snapshot.data!["Title"];
                            List<dynamic> event_imgs = snapshot.data!["Images"];
                            DateTime time = snapshot.data!["EventDate"].toDate();
                            String C_name = snapshot.data!["Club_Name"];
                            String eventId_ = homepageEvents[index2];
                            String description = snapshot.data!["Description"];
                            bool liked = snapshot.data!["Liked"];
                            Map<String,dynamic> allComments = snapshot.data!["Comments"];
                            bool commented = false;
                            return content(context, eventId_, C_image_comm, Event_title, time, C_name, event_imgs, liked, commented, _width, description,viewComments[index2],allComments);
                          },
                        );
                        
                      })
          ],
        ),
      ),
    ));
  }
}
Widget content(BuildContext context,
                String eventId_,
                Uint8List C_image_comm,
                String Event_title,
                DateTime time,
                String C_name,
                List<dynamic> event_imgs,
                bool liked,
                bool commented,
                double _width,
                String description,
                bool viewComments,
                Map<String,dynamic> commentsAll
                ){
  return Padding(
                            padding: const EdgeInsets.all(2),
                            child: Card(
                              color: const Color.fromARGB(86, 82, 81, 81),
                              elevation: 10,
                              child: InkWell(
                                onTap:()=> Navigator.push(context,MaterialPageRoute(builder: 
                                (context)=> Dedicatedeventpage(eventId:eventId_ ,))),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                           Padding(
                                            padding:const EdgeInsets.all(5),
                                            child: CircleAvatar(
                                              backgroundImage: MemoryImage(C_image_comm)
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  Event_title,
                                                  style: const TextStyle(
                                                      color: Colors.blue,fontSize: 18),
                                                ),
                                                Text(
                                                  period(time),
                                                  style:const TextStyle(
                                                      color: Color.fromARGB(
                                                          174, 255, 255, 255)),
                                                )
                                              ],
                                            ),
                                          ),
                                         const   SizedBox(width: 30,),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text("by $C_name ",style:const TextStyle(color: Colors.white,fontSize: 12),),
                                          ),
                                          const SizedBox(width: 50,),
                                          TextButton(onPressed: (){
                                            showDialog(context: context, builder: (context){
                                              return Dialog(
                                                alignment: Alignment.center,
                                                elevation: 10,
                                                child: Container(height: 150,width: 100,
                                                decoration: BoxDecoration(color:const Color.fromARGB(255, 19, 18, 18),borderRadius: BorderRadius.circular(15)),
                                                child:Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    Padding(padding:const EdgeInsets.all(10),child: 
                                                    Text("RSVP to $Event_title by $C_name ",style:const TextStyle(color: Color.fromARGB(188, 215, 212, 212)),),),
                                                    Padding(padding:const EdgeInsets.all(10),
                                                    child:Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        TextButton(onPressed: ()async{
                                                        String state = await  rsvp(eventId: eventId_);
                                                        if (state == "Success") {
                                                          showsnackbar(context, "Successfully rsvp'd to $Event_title");
                                                        }
                                                        Navigator.pop(context);
                                                        }, child:const Text("YES",style: TextStyle(color:  Color.fromARGB(144, 255, 255, 255)),)),
                                                        TextButton(onPressed: (){
                                                          Navigator.pop(context);
                                                        }, child:const Text("Cancel",style: TextStyle(color:  Color.fromARGB(144, 255, 255, 255)),))
                                                      ],
                                                    ) ,)
                                                  ],
                                                ) ,
                                                ),
                                              );
                                            });
                                          }, child: Container(decoration: BoxDecoration(color: Colors.blue,
                                          borderRadius: BorderRadius.circular(8)
                                          ),
                                          child:const Padding(
                                            padding:  EdgeInsets.all(8.0),
                                            child: Text("RSVP",style: TextStyle(color: Colors.white,fontSize: 16,fontStyle: FontStyle.italic,),),
                                          ),
                                          )
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 250,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: event_imgs.length,
                                          itemBuilder: (context, imgno) {
                                           Uint8List E_img = event_imgs[imgno];
                                                return Container(
                                                  padding:
                                                    const  EdgeInsets.all(5),
                                                 child: Image(image: MemoryImage(E_img)),
                                                );
                                             
                                          }),
                                    ),
                                    StatefulBuilder(
                                      builder: (BuildContext context, setStateAll) {
                                        return Column(
                                        children: [
                                          Container(
                                            height: 50,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  height: 60,
                                                  padding:const EdgeInsets.all(5),
                                                  child:viewComments?SizedBox(height: 40,width: _width/2,child:
                                                  
                                                  TextField(
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
                                                    controller: commentText,
                                                     ),
                                                  ): 
                                                  
                                                   Padding(
                                                     padding: const EdgeInsets.all(8.0),
                                                     child: Text(commentsAll.isEmpty?"Be first to leave a comment":commentsAll[commentsAll.keys.first]["Comment"] ,style: TextStyle(color: Colors.white),
                                                                                                       maxLines: 2,overflow: TextOverflow.fade,),
                                                   ),
                                                ),
                                                Visibility(
                                                  visible: viewComments,
                                                  child:IconButton(onPressed: ()async{
                                                  String  state = "Error occured";
                                                  state = await comment_(eventId_, commentText.text);
                                                  if (state == "Success") {
                                                    print("Comment added");
                                                    commentText.clear();
                                                    setStateAll((){
                                                      getnewcomments(eventId_);
                                                    });

                                                  }
                                                  }, icon:
                                                  const Icon(Icons.send,color: Colors.blueAccent,)) ),
                                                Row(
                                                  children: [
                                                     //like button
                                                    StatefulBuilder(
                                                  builder: (BuildContext context, setStateL) {
                                                    return IconButton(
                                                      onPressed: ()async {
                                                        print(commentsAll);
                                                        String state = "Unsuccesfull";
                                                          setStateL((){
                                                            liked = !liked;
                                                          });
                                                       state = await likeEvent(eventId_);
                                                       if (state == "Success") {
                                                         showsnackbar(context, "Liked");
                                                       }else{print(state);}
                                                                                                
                                                      },
                                                      icon:  Icon(
                                                        Icons.thumb_up_alt_outlined,
                                                        color:liked?Colors.blue :const Color.fromARGB(
                                                            255, 108, 105, 105),
                                                      ));
                                                  },
                                                ),
                                                    //comment field
                                                
                                                IconButton(
                                                    onPressed: () async{
                                                      setStateAll((){
                                                        viewComments = !viewComments;
                                                      });
                                                      
                                                    },
                                                    icon:  Icon(
                                                      Icons.comment,
                                                      color:commented?Colors.blue:const Color.fromARGB(
                                                          255, 99, 95, 95),
                                                    ))
                                                  ],
                                                ),
                                               
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                        visible:viewComments,
                                        child:Padding(padding: EdgeInsets.all(10),
                                        child: Container(
                                          constraints: BoxConstraints(maxHeight: 200,),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: commentsAll.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              var comId = commentsAll.keys.toList();
                                             DateTime tstamp = commentsAll[comId[index]]["TimeStamp"].toDate();
                                             String comOwner = commentsAll[comId[index]]["UserName"].toString();
                                             String commentdata = commentsAll[comId[index]]["Comment"];
                                             List likesall = commentsAll[comId[index]]["Likes"];
                                              return Container(
                                                decoration: BoxDecoration(color: const Color.fromARGB(236, 16, 16, 16),borderRadius: BorderRadius.circular(10)),
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      leading: Text(comOwner,style:const TextStyle(color: Colors.white,fontSize: 16),),
                                                      title: Text(period(tstamp),style:const TextStyle(color: Colors.white,fontSize: 10),),
                                                      trailing: Badge(
                                                        label: Text(likesall.length.toString(),style:const TextStyle(color: Colors.white),),
                                                        child: IconButton(onPressed: (){}, icon:const Icon(Icons.favorite))),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.all(5),
                                                      alignment: Alignment.bottomLeft,
                                                      child: Text(commentdata,style:const TextStyle(color: Colors.white),)),
                                                    
                                                  ],
                                                ),
                                              ) ;
                                            },
                                          ),
                                        ),
                                        ) ),
                                        ],
                                      );
                                      },
                                    ),
                                    
                                    Container(
                                      alignment: Alignment.bottomLeft,
                                      padding:const EdgeInsets.all(10),
                                      child:  Text(
                                        description,
                                        style:const TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ));
}