// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/services.dart";
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vora_mobile/Accounts.dart';

import 'package:vora_mobile/dedicated/dedicatedEventPage.dart';
import 'package:vora_mobile/firebase_Resources/add_content.dart';
import 'package:vora_mobile/homepage.dart';

import 'package:vora_mobile/utils.dart';

class Events extends StatefulWidget {
  final String filtername;
  const Events({super.key,required this.filtername});

  @override
  State<Events> createState() => _EventsState();
}

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
  "Member clubs",
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
  if (!event_filter.contains(widget.filtername)) {
      event_filter.add(widget.filtername);
    }
    if (event_value != widget.filtername) {
      eventIdsEventspage.clear();
    }
    event_value = widget.filtername;
    if(eventIdsEventspage.isNotEmpty){
      for (var i = 0; i < eventIdsEventspage.length; i++) {
        viewEventComments.add(false);
      }
    }
    super.initState(); 
  }
  Future<void> getevents(String filter) async {
    eventIds.clear();
    await firestore.collection("users").doc(user.uid).get().then((comnum)async{
      List com = comnum.data()!["Communities"];
     String nity = "";
      for(var mun in com){
        if (eventData.containsKey(mun)) {
           nity = eventData[mun]!["Name"];
          
        }else{
          await firestore.collection("Communities").doc(mun).get().then((nam){
             nity = nam.data()!["Name"];
          });
        }
        if (!event_filter.contains(nity)) {
            event_filter.add(nity);
          }
      }
    });
    if (filter == "all") {
      await firestore
        .collection("Events")
        .where("Title", isNotEqualTo: null)
        .get()
        .then((onValue) {
          
      for (var snaps in onValue.docs) {
        eventIds.add(snaps["Uid"]);
        if (!eventIdsEventspage.contains(snaps["Uid"])) {
          eventIdsEventspage.add(snaps["Uid"]);
        }
        viewEventComments.add(false);
      }
    });
    }
    else{
      switch (filter) {
        case "Registered":
        eventIdsEventspage.clear();
          await firestore.collection("users").doc(user.uid).get().then((rsvped){
            for(var evids in rsvped.data()!["Events"]){
              eventIds.add(evids);
              eventIdsEventspage.add(evids);
            }
          });
          
          break;
        case "not Registered":
          
          List rsvped = List.empty(growable: true);
          await firestore.collection("users").doc(user.uid).get().then((rsvpd){
            rsvped = rsvpd.data()!["Events"];
            for(var vp in rsvped){
              if (eventIdsEventspage.contains(vp)) {
               
                eventIdsEventspage.remove(vp);
                eventIds.remove(vp);
              }
            }
          });
          break;
        case "Member clubs":
        eventIdsEventspage.clear();
        eventIds.clear();
        List mclubs = List.empty(growable: true);
          await firestore.collection("users").doc(user.uid).get().then((mclubss)async{
            for(var mclub in mclubss.data()!["Communities"]){
              mclubs.add(mclub);
              await firestore.collection("Events").where("Community", isEqualTo: mclub).get().then((memberclubevents){
                for(var evenid in memberclubevents.docs){
                  eventIdsEventspage.add(evenid.id);
                  eventIds.add(evenid.id);
                }
              });
            }
          });
          break;
        
        default:
       
          eventIdsEventspage.clear();
          eventIds.clear();
          await firestore.collection("Communities").where("Name", isEqualTo: filter).get().then((onValue)async{
            for(var comm in onValue.docs){
              await firestore.collection("Events").where("Community", isEqualTo: comm.id).get().then((events){
                for(var eve in events.docs){
                  eventIdsEventspage.add(eve.id);
                  eventIds.add(eve.id);
                }
              });
            }
          });
          
      }
    }
  }
  Future<Map<String,dynamic>> get_events(String eventId)async{
    Map<String,dynamic> even_m = {};
    String comm_id = "";
    await firestore.collection("Events").doc(eventId).get().then((onValue){
      // final title = <String,dynamic>{"Title":onValue.data()!["Title"]};
     comm_id = onValue.data()!["Community"];
      // final date = <String,dynamic>{"EventDate":onValue.data()!["EventDate"]};
       var likes = onValue.data()!["Likes"];
      // final desc = <String,dynamic>{"Description":onValue.data()!["Description"]};
      even_m.addAll(onValue.data()!);
      try {
        var comments_ = onValue.data()!["Comments"];
  
      Map<String,dynamic>commentedalready = {};
      if (comments_.contains(user.uid)) {
        commentedalready = {"Commented":true};
      }else{
        commentedalready = {"Commented":false};
      }
            even_m.addAll(commentedalready);
      
      } catch (e) {
        print(e.toString());
      }
      
      Map<String,dynamic> liked = {};
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
    await store.child("/events/$eventId/cover").getData().then((eventcove){
      final eventcover = <String,dynamic>{"EventCover":eventcove!};
      even_m.addAll(eventcover);
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
    double windowWidth= MediaQuery.of(context).size.width;
    double windowheight = MediaQuery.of(context).size.height;
   // double eventScale = 0.96;
    return SafeArea(
        child: Scaffold(
          // floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
          // floatingActionButton: Padding(
          //   padding: const EdgeInsets.only(top: 46),
          //   child: Container(
          //     decoration: BoxDecoration(color: const Color.fromARGB(210, 0, 0, 0),
          //     border: Border.all(width: 2,color: const Color.fromARGB(118, 255, 255, 255)),
          //     borderRadius: BorderRadius.circular(10)
          //     ),
              
              
          //     child: ListenableBuilder(
          //           listenable: Search_visible_,
          //           builder: (context,child) {
          //             return Visibility(
          //                 visible: events_vis,
          //                 child: SizedBox(
          //                   width: 200,
          //                   height: 45,
          //                   child: TextField(
          //                     onChanged: (value)async {
          //                      await searchfnxn(value);
          //                     },
          //                     style:const TextStyle(color: Colors.white),
          //                     controller: _search_events,
          //                     decoration: const InputDecoration(
          //                         label: Icon(
          //                       Icons.search,
          //                       color: Colors.white,
          //                     )),
          //                   ),
          //                 ));
          //           }
          //         ),
          //   ),
          // ),
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
                showsnackbar(context, "Search events coming soon");
                  events_vis = !events_vis;
               Search_visible_.value = !Search_visible_.value;
              },
              icon: const Icon(
                Icons.search_sharp,
                color: Colors.white,
              ))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ()async {
          await getevents(event_value);
          setState(() {
            
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                  onChanged: (String? newValue) async{
                    event_value = newValue!;
                   eventIdsEventspage.clear();
                    setState(() {
                    });
                    
                  },
                ),
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
                  future: getevents(event_value),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return  Center(child: SizedBox(
                        height: windowheight ,
                        child: const Center(child: CircularProgressIndicator(),),
                      ));
                    }
                    if (snapshot.connectionState == ConnectionState.none) {
                                      return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                    }
                    if (viewEventComments.isEmpty) {
                      for (var i = 0; i < eventIds.length; i++) {
                      viewEventComments.add(false);
                    }
                    }
                    
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: eventIds.length,
                        itemBuilder: (context, index2) {
                          
                          return checkevent(eventIds[index2])?
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
                              allComments.forEach((key,value){
                                print(value);
                                if (value.containsValue(userData["nickname"])) {
                                  commented = true;
                                }
                              });
                              int likenum = eventData[eventIds[index2]]!["Likes"].length;
                             String regLink = eventData[eventIds[index2]]!["Regestration"];
                              
                             return content(context, eventId_, C_image_comm, Event_title, time, C_name, 
                              event_imgs, liked, commented, windowWidth,windowheight , description,viewEventComments[index2],
                              allComments,likenum,index2,regLink);
                            },
                          )
                          
                          :
                          FutureBuilder(
                            future: get_events(eventIds[index2]),
                            
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return  StatefulBuilder(
                                      builder: (BuildContext context, setStateev) {
                                        return  Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(210, 91, 90, 90),
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                                            height: 200,
                                            child: const Center(child: CircularProgressIndicator(),),
                                            ),
                                        );
                                      },
                                    );
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
                              allComments.forEach((key,value){
                                print(value);
                                if (value.containsValue(userData["nickname"])) {
                                  commented = true;
                                }
                              });
                              int likenum = snapshot.data!["Likes"].length;
                              String regLink = snapshot.data!["Regestration"];
                              return content(context, eventId_, C_image_comm, Event_title, time, C_name, event_imgs, liked, commented, windowWidth,windowheight , description,viewEventComments[index2],allComments,likenum,index2,regLink);
                            },
                          );
                          
                        });
                  }):ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: eventIdsEventspage.length,
                        itemBuilder: (context, index2) {
                          if (viewEventComments.isEmpty) {
                            for (var i = 0; i < eventIdsEventspage.length; i++) {
                            viewEventComments.add(false);
                          }
                          }
                          
                          
                          return !checkevent(eventIdsEventspage[index2])?
                          StatefulBuilder(
                            builder: (BuildContext context, setState_1) {
                               Uint8List C_image_comm = eventData[eventIdsEventspage[index2]]!["Cover_Image"];
                              String Event_title = eventData[eventIdsEventspage[index2]]!["Title"];
                              List<dynamic> event_imgs = eventData[eventIdsEventspage[index2]]!["Images"];
                              DateTime time = eventData[eventIdsEventspage[index2]]!["EventDate"].toDate();
                              String C_name = eventData[eventIdsEventspage[index2]]!["Club_Name"];
                              String eventId_ = eventIdsEventspage[index2];
                              String description = eventData[eventIdsEventspage[index2]]!["Description"];
                              bool liked = eventData[eventIdsEventspage[index2]]!["Liked"];
                              Map<String,dynamic> allComments = eventData[eventIdsEventspage[index2]]!["Comments"];
                              int likenum = eventData[eventIdsEventspage[index2]]!["Likes"].length;
                              bool commented = false;
                              allComments.forEach((key,value){
                                print(value);
                                if (value.containsValue(userData["nickname"])) {
                                  commented = true;
                                }
                              });
                              String regLink = eventData[eventIdsEventspage[index2]]!["Regestration"];
                              return content(context, eventId_, C_image_comm, Event_title, time, C_name, event_imgs, liked, commented, windowWidth,windowheight , description,viewEventComments[index2],allComments,likenum,index2,regLink);
                            },
                          )
                          
                          :
                          FutureBuilder(
                            future: get_events(eventIdsEventspage[index2]),
                            
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(210, 91, 90, 90),
                                                borderRadius: BorderRadius.circular(10)
                                              ),
                                              height: 200,
                                              child: const Center(child: CircularProgressIndicator(),),
                                              ),
                                    );
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
                              String eventId_ = eventIdsEventspage[index2];
                              String description = snapshot.data!["Description"];
                              bool liked = snapshot.data!["Liked"];
                              Map<String,dynamic> allComments = snapshot.data!["Comments"];
                              bool commented = false;
                              allComments.forEach((key,value){
                                print(value);
                                if (value.containsValue(userData["nickname"])) {
                                  commented = true;
                                }
                              });
                              int likenum = snapshot.data!["Likes"].length;
                              String regLink = snapshot.data!["Regestration"];
                              return content(context, eventId_, C_image_comm, Event_title, time, C_name, event_imgs, liked, commented, windowWidth,windowheight , description,viewEventComments[index2],allComments,likenum,index2,regLink);
                            },
                          );
                          
                        })
            ],
          ),
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
                double windowWidth,
                double windowheight ,
                String description,
                bool viewComments,
                Map<String,dynamic> commentsAll,
                int likesNum,
                int index,
                String registrationLink
                ){
  return Padding(
  padding: const EdgeInsets.all(2),
  child: Card(
    color: const Color.fromARGB(50, 82, 81, 81),
    elevation: 10,
    child: InkWell(
      enableFeedback: false,
      splashColor: Colors.transparent,
      onTap:()=> Navigator.push(context,MaterialPageRoute(builder: 
      (context)=> Dedicatedeventpage(eventId:eventId_ ,))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                const   SizedBox(width: 20,),
                
                Visibility(
                  visible: time.isAfter(DateTime.now()),
                  child: TextButton(onPressed: (){
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
                  }, child:
                    Container(decoration: BoxDecoration(color: const Color.fromARGB(255, 24, 23, 23),
                      borderRadius: BorderRadius.circular(8)
                          ),
                      child:const Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: Text("RSVP",style: TextStyle(color: Color.fromARGB(255, 3, 20, 200),fontSize: 16,),),
                  ),
                  )
                  ),
                ),
                Builder(
                  builder: (context) {
                    bool dottedopen = false;
                    return StatefulBuilder(
                      builder: (BuildContext context, setStatedotted) {
                        return   InkWell(
                      onTap: () {
                        setStatedotted((){
                          dottedopen = !dottedopen;
                        });
                        
                      },
                      child:  Padding(
                        padding:const  EdgeInsets.all(8.0),
                        child: dottedopen?Row(children: [
                          IconButton(onPressed: (){
                            String copytext = "$User_Name invites you to the event $Event_title hosted by $C_name on the ${time.day}/${time.month}/${time.year} starting at ${time.hour} regester at $registrationLink se you there!!!";
                            Clipboard.setData(ClipboardData(text: copytext));
                            showsnackbar(context, "Message copied to clipboard");
                          }, icon:const Icon(Icons.share,color: Colors.white,),),
                          IconButton(onPressed: (){}, icon: const Icon(Icons.block,color: Colors.white,)),
                          IconButton(onPressed: (){
                            setStatedotted((){
                              dottedopen = !dottedopen;
                            });
                          }, icon:const Icon(FontAwesomeIcons.x,size: 18,color: Colors.white,))
                        ],) :const Icon(Icons.more_vert,color: Colors.white,),
                      ),
                    );
                      },
                    );
                  }
                ),
              
                
              ],
            ),
          ),
          Padding(
                  padding: const EdgeInsets.only(left: 20.0,top: 5,bottom: 5),
                  child: Text("by $C_name ",style:const TextStyle(color: Colors.white,fontSize: 12),softWrap: true,),
                ),
          SizedBox(
            height: 250,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: event_imgs.length,
                itemBuilder: (context, imgno) {
                  Uint8List E_img = event_imgs[imgno];
                      return InkWell(
                        onTap: (){
                          showDialog(context: context, builder: (context){
                            return SizedBox(
                              
                              child: showimage(context, event_imgs,windowheight ));
                          });
                        },
                        child: Container(
                          padding:
                            const  EdgeInsets.all(5),
                          child: Image(image: MemoryImage(E_img)),
                        ),
                      );
                    
                }),
          ),
          
          
          Container(
            alignment: Alignment.bottomLeft,
            padding:const EdgeInsets.all(10),
            child:  Text(
              description,
              style:const TextStyle(color: Colors.white),
            ),
          ),StatefulBuilder(
            builder: (BuildContext context, setStateAll) {
              return Container(
                decoration: BoxDecoration(border: Border.all(color: const Color.fromARGB(187, 107, 104, 104),
                ),
                borderRadius: BorderRadius.circular(10)),
                child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 60,
                          padding:const EdgeInsets.all(5),
                          child:viewComments?
                          SizedBox(height: 40,
                          width: 160,
                          child:
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
                              child: Text(commentsAll.isEmpty?"Be first to leave a comment":commentsAll[commentsAll.keys.first]["Comment"] ,
                              style:const TextStyle(color: Colors.white),
                                                                                maxLines: 2,overflow: TextOverflow.fade,),
                            ),
                        ),
                        Visibility(
                          visible: viewComments,
                          child:IconButton(onPressed: ()async{
                          String  state = "Error occured";
                          state = await comment_(eventId_, commentText.text);
                          if (state == "Success") {
                            
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
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: ()async {
                                    //showsnackbar(context, C_name.characters.toList().toString());
                                      setStateL((){
                                        liked = !liked;
                                        liked?likesNum++:likesNum--;
                                        likeEvent(eventId_);
                                      });
                                    
                                                                            
                                  },
                                  icon:  Icon(
                                    Icons.thumb_up_alt_outlined,
                                    color:liked?Colors.blue :const Color.fromARGB(
                                        255, 108, 105, 105),
                                  )),
                                  Text(likesNum.toString(),style:const TextStyle(color: Colors.white),)
                              ],
                            );
                          },
                        ),
                            //comment field
                        
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0,right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () async{
                                    setStateAll((){
                                      viewComments = !viewComments;
                                      viewEventComments[index] = viewComments;
                                    });
                                  },
                                  icon:  Icon(
                                    Icons.comment,
                                    color:commented?Colors.blue:const Color.fromARGB(
                                        255, 99, 95, 95),
                                  )),
                                  Text(commentsAll.length.toString(),style:const TextStyle(color: Colors.white),)
                            ],
                          ),
                        )
                          ],
                        ),
                        
                      ],
                    ),
                  ),
                  Visibility(
              visible: viewComments,
              child: StreamBuilder(
                stream: firestore.collection("Events").doc(eventId_).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(),);
                  }
                  Map<String,dynamic> commentsAll = snapshot.data!["Comments"];
                  
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: 
                    Container(
                    constraints:const BoxConstraints(maxHeight: 200,),
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          decoration: BoxDecoration(color: const Color.fromARGB(164, 65, 65, 66),borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Text(comOwner,style:const TextStyle(color: Colors.white,fontSize: 16),),
                                title: Text(period(tstamp),style:const TextStyle(color: Colors.white,fontSize: 10),),
                                trailing: Badge(
                                  backgroundColor: Colors.transparent,
                                  offset:const Offset(-5,20),
                                 // alignment: Alignment.bottomRight,
                                  label: Text(likesall.length.toString(),style:const TextStyle(color: Colors.white),),
                                  child: IconButton(onPressed: (){}, icon:const Icon(Icons.favorite,color: Colors.white,size: 18,))),
                              ),
                              Container(
                                padding:const EdgeInsets.only(left: 10,bottom: 8,right: 10),
                                alignment: Alignment.bottomLeft,
                                child: Text(commentdata,style:const TextStyle(color: Colors.white),)),
                              
                            ],
                          ),
                        ),
                      ) ;
                    },
                                      ),
                                    ),
                  );
                }
              ),)  ,
              
                //   Visibility(
                // visible:viewComments,
                // child:Padding(padding:const EdgeInsets.all(10),
                // child: Container(
                //   constraints:const BoxConstraints(maxHeight: 200,),
                //   child: ListView.builder(
                //     shrinkWrap: true,
                //     physics: const NeverScrollableScrollPhysics(),
                //     itemCount: commentsAll.length,
                //     itemBuilder: (BuildContext context, int index) {
                //       var comId = commentsAll.keys.toList();
                //       DateTime tstamp = commentsAll[comId[index]]["TimeStamp"].toDate();
                //       String comOwner = commentsAll[comId[index]]["UserName"].toString();
                //       String commentdata = commentsAll[comId[index]]["Comment"];
                //       List likesall = commentsAll[comId[index]]["Likes"];
                //       return Container(
                //         decoration: BoxDecoration(color: const Color.fromARGB(164, 65, 65, 66),borderRadius: BorderRadius.circular(10)),
                //         child: Column(
                //           children: [
                //             ListTile(
                //               leading: Text(comOwner,style:const TextStyle(color: Colors.white,fontSize: 16),),
                //               title: Text(period(tstamp),style:const TextStyle(color: Colors.white,fontSize: 10),),
                //               trailing: Badge(
                //                 backgroundColor: Colors.transparent,
                //                 offset:const Offset(-5,20),
                //                // alignment: Alignment.bottomRight,
                //                 label: Text(likesall.length.toString(),style:const TextStyle(color: Colors.white),),
                //                 child: IconButton(onPressed: (){}, icon:const Icon(Icons.favorite,color: Colors.white,size: 18,))),
                //             ),
                //             Container(
                //               padding:const EdgeInsets.only(left: 10,bottom: 8,right: 10),
                //               alignment: Alignment.bottomLeft,
                //               child: Text(commentdata,style:const TextStyle(color: Colors.white),)),
                            
                //           ],
                //         ),
                //       ) ;
                //     },
                //   ),
                // ),
                // ) ),
                ],
                                                      ),
              );
            },
          ),
        ],
      ),
    ),
  ));
}