// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:vora_mobile/Accounts.dart';
import 'package:vora_mobile/add_pages/add_event.dart';
import 'package:vora_mobile/add_pages/new_announcement.dart';
import 'package:vora_mobile/add_pages/new_post.dart';

import 'package:vora_mobile/add_pages/newcommunity.dart';
import 'package:vora_mobile/announcemnts.dart';
import 'package:vora_mobile/blogs.dart';
import 'package:vora_mobile/calender.dart';
import 'package:vora_mobile/clubs.dart';
import 'package:vora_mobile/dedicated/dedicatedEventPage.dart';
import 'package:vora_mobile/events.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart' ;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vora_mobile/utils.dart';

final firestore_ = FirebaseFirestore.instance;
final store_1 = FirebaseStorage.instance.ref();

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}
User user_ = FirebaseAuth.instance.currentUser!;

String User_Name = "";
Future<String> userget()async{
  String userNickname ="";
  await firestore_.collection("users").doc(user_.uid).get().then((onValue)async{
    userNickname =await onValue.data()!["nickname"];
    userData.addAll(onValue.data()!);
  });

    if (!userData.containsKey("Dp")) {

           await storage_1.child("/profile/${user.uid}/dp.png").getData().then((dp){
    final dpimg = <String,dynamic>{"Dp":dp!};
    if (dp.isNotEmpty) {
      
    }
    userData.addAll(dpimg);
  });
    }
   
    //gs://voramobile-70ba7.appspot.com/profile/k2iu5JK5fOb5jra5644thq9OQ4d2

  
 
  return userNickname;
}

Future<Map<String,dynamic>> getcontent(String eventId)async{
  Map<String,dynamic> functionData ={};
await firestore_.collection("Events").doc(eventId).get().then((onValue)async{
  var comn = onValue.data()!["Community"];

  
  await firestore_.collection("Communities").doc(comn).get().then((onvalue1){
    final comm = <String,dynamic>{"EventClub":onvalue1.data()!["Name"]};
    functionData.addAll(comm);
  });
  
  final evdate =<String,dynamic>{"EventDate":onValue.data()!["EventDate"]};
  final ttle = <String,dynamic>{"EventTitle":onValue.data()!["Title"]};
  functionData.addAll(evdate);
  functionData.addAll(ttle);

});

await store_1.child("/events/$eventId/cover").getData().then((value){
  final imgs = <String,dynamic>{"EventCoverImage":value!};
  functionData.addAll(imgs);
});


  
  return functionData;
}
Future<Map<String,dynamic>> getclubsAndEvents()async{
Map<String,dynamic> ret = {};
await firestore_.collection("users").doc(user.uid).get().then((onValue)async{
  List<dynamic> vals = onValue.data()!["Events"];
  List<dynamic> val2 = onValue.data()!["Communities"];
  final clubno =<String,dynamic>{"C_num":val2.length};
  final eventsno = <String,dynamic>{"E_num":vals.length};
  final cludMember =<String,dynamic>{"ClubsAttended":val2};
  final Eventsattended =<String,dynamic>{"EventsAttended":vals};
  userData.addAll(cludMember);
  userData.addAll(Eventsattended);
  ret.addAll(eventsno);
  ret.addAll(clubno);
});
return ret;
}
  List<String> events_Ids = List.empty(growable: true);
Future<int> getevents()async{
 int eventsno = 0;
  await firestore_.collection("Events").where("EventDate", isLessThan: Timestamp.now()).get().then((onValue)async{
    eventsno = onValue.docs.length;
    for(var val1 in onValue.docs){
      if(!homepageEvents.contains(val1.id)){
        homepageEvents.add(val1.id);
      }
      if (!events_Ids.contains(val1.id)) {
        events_Ids.add(val1.id);
      }
    }
  });
  return eventsno;
}
List<DayEvent> events = [
  DayEvent( name: "Art exibition" ,value: "Art Club", start: DateTime(2024,DateTime.now().month,DateTime.now().day,8),end:DateTime(2024,DateTime.now().month,DateTime.now().day,8).add(const Duration(hours: 4))),
  DayEvent(name: "Drama practice" ,value: "Drama Club", 
  start: DateTime(2024,DateTime.now().month,DateTime.now().day,14),
  end: DateTime(2024,DateTime.now().month,DateTime.now().day,16)),
];
class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  late AnimationController _drawercontroller;
  late AnimationController _animationController;
  bool addvisible = false;
  Future<File> getLocalFileFromAsset(String assetPath, String fileName) async {
    // Load the asset
    final byteData = await rootBundle.load(assetPath);

    // Get the local path
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    // Write the file
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  @override
  void initState() {
    super.initState();
    _drawercontroller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _drawercontroller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool _isDrawerOpen() {
    return _drawercontroller.value == 1.0;
  }

  bool _isDrawerOpening() {
    return _drawercontroller.status == AnimationStatus.forward;
  }

  bool _isDrawerClosed() {
    return _drawercontroller.value == 0.0;
  }
ImageFilter blur_ = ImageFilter.blur(sigmaX: 0,sigmaY: 0);
  void openicons() {
    addvisible

        ?{ _animationController.reverse(),blur_=ImageFilter.blur()}
        : {_animationController.forward(),blur_ = ImageFilter.blur(sigmaX: 3.0,sigmaY: 3.0)}; 
  }
  // var imglist = [
  //   'lib/assets/1.png',
  //   'lib/assets/2.png',
  //   'lib/assets/3.png',
  //   'lib/assets/art.png',
  //   'lib/assets/art1.png',
  //   'lib/assets/cover.jpg'
  // ];
  void _toggleDrawer() {
    if (_isDrawerOpen() || _isDrawerOpening()) {
      _drawercontroller.reverse();
    } else {
      _drawercontroller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    double windowWidth= MediaQuery.of(context).size.width;
    double windowheight = MediaQuery.of(context).size.height;
       
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

          title: SvgPicture.asset(
            'lib/assets/vora.svg',
            semanticsLabel: 'VORA',
            height: 40,
            width: 60,
          ),
          //check if logged in
          actions: [
            
                InkWell(
                  onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Center(
                          child: Dialog(
                            insetPadding: const EdgeInsets.all(10),
                            backgroundColor: const Color.fromARGB(
                              255,
                              29,
                              36,
                              45,
                            ),
                            child: SizedBox(
                              height: 150,
                              child: Column(
                                children: [
                                  TextButton(
                                      onPressed: ()async {
                                       
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Accounts()));
                                      },
                                      child: const Text(
                                        "Account",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                  TextButton(
                                      onPressed: () async {},
                                      child: const Text(
                                        "Edit Account",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                  TextButton(
                                      onPressed: ()async {
                                        var appDir = (await getTemporaryDirectory()).path;
                                         Directory(appDir).delete(recursive: true);
                                        FirebaseAuth.instance.signOut();
                                        
                                        
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Log Out",
                                        style: TextStyle(color: Colors.white),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                },
                  child: userData["Dp"] == null?
                    FutureBuilder(
                      future: userget(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircleAvatar(backgroundColor: Colors.white,),);
                        }
                        if (!snapshot.hasData) {
                          return const CircleAvatar(
                            backgroundImage: AssetImage('lib/assets/dp.jpg'),
                          );
                        }
                        
                        Uint8List dpimg = userData["Dp"];
                        return CircleAvatar(
                          backgroundImage: MemoryImage(dpimg),
                        );
                      },
                    ):CircleAvatar(
                          backgroundImage: MemoryImage(userData["Dp"]),
                        ),
                ),
               const SizedBox(width: 40,),
            AnimatedBuilder(
              animation: _drawercontroller,
              builder: (context, child) {
                return IconButton(
                  onPressed:() {
                    if (_isDrawerClosed()) {
                        _toggleDrawer();
                    }
                  },
                  icon: _isDrawerOpen() || _isDrawerOpening()
                      ? const Icon(
                        size: 32,
                          Icons.clear,
                          color: Colors.white,
                        )
                      : const Icon(
                        size: 28,
                          Icons.menu,
                          color: Colors.white,
                        ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Stack(children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Padding(padding: EdgeInsets.all(3)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: StatefulBuilder(
                      builder: (context,setstate_head){
                        return  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 8, left: 8),
                              alignment: Alignment.center,
                              height: 140,
                              //width: windowWidth/ 2,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                  255,
                                  29,
                                  36,
                                  45,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child:  Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:!userData.containsKey("nickname")? 
                                FutureBuilder(
                                  initialData: "User",
                                  future: userget(),
                                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    
                                    if (snapshot.connectionState == ConnectionState.waiting){
                                      return const Text(
                                    "Hello \n welcome to vora",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                    ),
                                  );
                                    }
                                    if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: 
                                    Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                                  if (!snapshot.hasData) {
                                    return const Text(
                                    "Hello \n welcome to vora",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                    ),
                                  );
                                  }
                                 
                                 
                                    return Text(
                                    "Hello ${snapshot.data} \n welcome to vora",
                                    style:const TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                    ),
                                  );
                                  },
                                ):Builder(
                                  builder: (context) {
                                    
                                    return Text(
                                        "Hello ${userData["nickname"]} \n welcome to vora",
                                        style:const TextStyle(
                                          color: Colors.white,
                                          fontSize: 21,
                                        ),
                                      );
                                  }
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5.0, bottom: 3.0, right: 5.0, left: 5),
                            child: Container(
                              height: 140,
                              width: 110,
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    29,
                                    36,
                                    45,
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              child:  InkWell(
                                onTap: ()async=>await Navigator.push(context,MaterialPageRoute(builder: (context)=> const Clubs())),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                   const Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child:  Column(
                                        children: [
                                          Text(
                                            "CLUBS",
                                            style: TextStyle(
                                                color: Colors.white, fontSize: 15),                         
                                          ),
                                          Divider(thickness: 5,color: Colors.blue,indent: 10,endIndent: 10,)
                                        ],
                                      ),
                                    ),
                                    
                                    Padding(
                                      padding:const EdgeInsets.only(bottom: 8.0),
                                      child: Column(
                                        children: [
                                          !userData.containsKey("ClubsAttended")?
                                          FutureBuilder(
                                            future: getclubsAndEvents(),
                                            initialData: 0,
                                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return  Center(child: Container(),);
                                              }
                                              if (snapshot.connectionState == ConnectionState.none) {
                                      return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                    }
                                              var c_numb =snapshot.data!["C_num"];
                                              
                                              return  Text(
                                              c_numb==null? "Offline": c_numb.toString(), 
                                                style:const TextStyle(color: Colors.white,fontSize: 30));
                                            },
                                          ):Text(
                                              userData["ClubsAttended"].length.toString(), 
                                                style:const TextStyle(color: Colors.white,fontSize: 30)),
                                        const  Divider(thickness: 5,color: Colors.red,indent: 10,endIndent: 10,)
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5, right: 5),
                            child: InkWell(
                              onTap:()async=>await Navigator.push(context,MaterialPageRoute(builder: (context)=> const Events(filtername: "all",))),
                              child: Container(
                                height: 140,
                                width: windowWidth/ 4,
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      29,
                                      36,
                                      45,
                                    ),
                                    borderRadius: BorderRadius.circular(10)),
                                child:  Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                   const Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Column(
                                        children: [
                                          Text("EVENTS",
                                              style: TextStyle(color: Colors.white)),
                                              Divider(thickness: 5,color: Colors.blue,indent: 10,endIndent: 10,),
                                        ],
                                      ),
                                    ),
                                        
                                    Padding(
                                      padding:const EdgeInsets.only(bottom: 8.0),
                                      child: Column(
                                        children: [
                                          !userData.containsKey("EventsAttended")?
                                          FutureBuilder(
                                            future: getclubsAndEvents(),
                                            initialData: 0,
                                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return  Center(child: Container(),);
                                              }
                                              if (snapshot.connectionState == ConnectionState.none) {
                                      return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                    }
                                              var E_numb = snapshot.data!["E_num"];
                                              return Text(
                                             E_numb==null?"Offline...": E_numb.toString(), 
                                              style:const TextStyle(color: Colors.white,fontSize: 30)
                                              );
                                            },
                                          ):Text(
                                             userData["EventsAttended"].length.toString(), 
                                              style:const TextStyle(color: Colors.white,fontSize: 30)
                                              ),
                                         const Divider(thickness: 5,color: Colors.red,indent: 10,endIndent: 10,)
                                        ],
                                      ),
                                    ),
                                   // SizedBox(height: 1,)
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                      },
                    )
                  ),
                  const SizedBox(height: 5,),
                  carosel(windowheight,windowWidth),
                  
                  const Divider(),
                 CalendarDayView.overflow(
                  renderRowAsListView: true,
                  dividerColor: const Color.fromARGB(158, 193, 230, 255),
                  overflowItemBuilder: (context, constraints, itemIndex, event) {
                    return Container(
                      decoration: BoxDecoration(color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(10)
                      ),
                      padding:const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(event.name.toString()),
                          Text(event.value.toString()),
                        ],
                      ),
                    );
                  },
                  timeTextStyle:const TextStyle(color: Colors.white),
                  currentTimeLineColor: Colors.blue,
                  endOfDay:const TimeOfDay(hour: 21,minute: 0),
                  showCurrentTimeLine: true,
                  timeGap: 60,
                  events: events, 
                  startOfDay:const TimeOfDay(hour: 7, minute: 0),
                 currentDate: DateTime.now()),
                 
                 
                ]),
            AnimatedBuilder(
              animation: _drawercontroller,
              builder: (context, child) {
                return FractionalTranslation(
                  translation: Offset(1.2, -1.0 + _drawercontroller.value),
                  child: _isDrawerClosed()
                      ? const SizedBox()
                      : BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0,sigmaY: 5.0),
                        
                        child: StatefulBuilder(
                          builder: (context, setstate2) {
                            return TapRegion(
                            onTapOutside: (tap){
                              if (_drawercontroller.value == 1) {
                                setstate2(() {
                              _toggleDrawer();
                            });
                              }
                              },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: _isDrawerOpen()
                                        ? const Color.fromARGB(255, 29, 29, 29)
                                        : Colors.black,
                                    borderRadius: BorderRadius.circular(10)),
                                //height: 220,
                                width: 190,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        "Account",
                                        style: TextStyle(
                                            color: _isDrawerOpen()
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      onTap: () async {
                                       // Navigator.pop(context);
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Accounts()));
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        "clubs & Communities",
                                        style: TextStyle(
                                            color: _isDrawerOpen()
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      onTap: () async {
                                      //  Navigator.pop(context);
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const Clubs()));
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Events",
                                        style: TextStyle(
                                            color: _isDrawerOpen()
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      onTap: () async {
                                      //  Navigator.pop(context);
                                        await Navigator.push(context,MaterialPageRoute(builder: (context)=> const Events(filtername: "all",)));
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Posts & Blogs",
                                        style: TextStyle(
                                            color: _isDrawerOpen()
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      onTap: () async {
                                      //  Navigator.pop(context);
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const Blogs()));
                                      },
                                    ),
                                    ListTile(
                                      title: Badge(
                                        label: const Text("9"),
                                        child: Text(
                                          "Announcements",
                                          style: TextStyle(
                                              color: _isDrawerOpen()
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                      ),
                                      onTap: () async {
                                       // Navigator.pop(context);
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Announcemnts()));
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        "My Callender",
                                        style: TextStyle(
                                            color: _isDrawerOpen()
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      //takes you to the callender page
                                      onTap: () async{
                                      //  Navigator.pop(context);
                                       await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Calender()));
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
              },
            ),
          ]),
        ),
        floatingActionButton: BackdropFilter(
          filter: blur_,
          child: StatefulBuilder(
            builder: (context, setstate1) {
              return TapRegion(
              onTapOutside:(tap){
                if (addvisible) {
                  openicons();
                  setstate1((){
                     addvisible = !addvisible;
                  });
                }
              },
              child: 
                 Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Visibility(
                        visible: addvisible,
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor:const Color.fromARGB(255, 73, 74, 74),
                          child: IconButton(
                            onPressed: () {
                              openicons();
                              setstate1(() {
                  addvisible = !addvisible;
                });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Newcommunity()));
                              
                            },
                            icon: const Icon(
                              Icons.group_sharp,
                              size: 28,
                            ),
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    Visibility(
                      visible: addvisible,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor:const Color.fromARGB(255, 73, 74, 74),
                        child: IconButton(
                          onPressed: () {
                            openicons();
                            setstate1(() {
                  addvisible = !addvisible;
                });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const NewPost()));
                            
                          },
                          icon: const Icon(
                            Icons.post_add,
                            size: 28,
                          ),
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Visibility(
                      visible: addvisible,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color.fromARGB(255, 73, 74, 74),
                        child: IconButton(
                          onPressed: () {
                            openicons();
                            setstate1(() {
                  addvisible = !addvisible;
                });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const NewAnnouncement()));
                            
                          },
                          icon: const Icon(Icons.announcement_sharp),
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Visibility(
                      visible: addvisible,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color.fromARGB(255, 73, 74, 74),
                        child: IconButton(
                          onPressed: () {
                             openicons();
                             setstate1(() {
                  addvisible = !addvisible;
                });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddEvent()));
                           
                          },
                          icon: const Icon(Icons.celebration),
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color.fromARGB(255, 73, 74, 74),
                        child: InkWell(
                          onTap: () {
                            openicons();
                            setstate1(() {
                  addvisible = !addvisible;
                });
                          },
                          child: AnimatedIcon(
                              icon: AnimatedIcons.add_event,
                              color: Colors.white,
                              progress: _animationController),
                        )),
                  ],
                )
               
            );
            },
             
          ),
        ),
      ),
    );
  }
}
Widget carosel(double windowheight,double windowWidth){
  return StatefulBuilder(
                    builder: (context, st2){
                      return Container(
                      height: windowheight / 3.7,
                      alignment: Alignment.bottomLeft,
                      child:FutureBuilder(
                        future: getevents(),
                        
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(),);
                          }
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator(),);
                          }
                          return CarouselSlider(
                          options: CarouselOptions(
                              autoPlay: true,
                              viewportFraction: 0.9,
                              autoPlayInterval: const Duration(seconds: 4)),
                          items:events_Ids
                              .map((item) =>!eventData.containsKey(item)? FutureBuilder(
                                future: getcontent(item),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==ConnectionState.waiting) {
                                    return  Center(child: Container(),);
                                  }
                                  if (!snapshot.hasData) {
                                    return const Center(child: Text("Upcoming Events"),);
                                  }
                                  if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                                  
                                  Uint8List im = snapshot.data["EventCoverImage"];
                                  String EventTitle = snapshot.data["EventTitle"];
                                  String club = snapshot.data["EventClub"];
                                  DateTime date = snapshot.data["EventDate"].toDate();
                                  
                                  return InkWell(
                                    onTap: ()async=>Navigator.push(context,MaterialPageRoute(builder: 
                                    (context)=> Dedicatedeventpage(eventId: item))),
                                    child: Container(
                                      width: windowWidth,
                                      height: 20,
                                      decoration: BoxDecoration(
                                          image:
                                              DecorationImage(image: MemoryImage(im))),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: windowheight / 6,
                                          ),
                                          Expanded(
                                            child: Container(
                                                color: const Color.fromARGB(
                                                    250, 32, 33, 36),
                                                width: windowWidth,
                                                child:  Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                        const  EdgeInsets.only(left: 30.0),
                                                      child: Text(
                                                        EventTitle,
                                                        style:const TextStyle(
                                                            fontSize: 22,
                                                            fontWeight: FontWeight.w800,
                                                            color: Colors.white),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                        const  EdgeInsets.only(left: 20.0),
                                                      child: Text(
                                                        club,
                                                        style:const TextStyle(
                                                            color: Colors.white),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                      const  Padding(
                                                            padding: EdgeInsets.only(
                                                                left: 25)),
                                                        Text(
                                                         period(date),
                                                          style:const TextStyle(
                                                              color: Color.fromARGB(255, 255, 255, 255)),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                )),
                                          )
                                        ],
                                      )),
                                  );
                                },
                              ):InkWell(
                                    onTap: ()async=>Navigator.push(context,MaterialPageRoute(builder: 
                                    (context)=> Dedicatedeventpage(eventId: item))),
                                    child: Container(
                                      width: windowWidth,
                                      height: 20,
                                      decoration: BoxDecoration(
                                          image:
                                              DecorationImage(image: MemoryImage(eventData[item]!["Cover_Image"] as Uint8List))),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: windowheight / 6,
                                          ),
                                          Expanded(
                                            child: Container(
                                                color: const Color.fromARGB(
                                                    250, 32, 33, 36),
                                                width: windowWidth,
                                                child:  Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                        const  EdgeInsets.only(left: 30.0),
                                                      child: Text(
                                                        //Title for event
                                                        eventData[item]!["Title"],
                                                        style:const TextStyle(
                                                            fontSize: 22,
                                                            fontWeight: FontWeight.w800,
                                                            color: Colors.white),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                        const  EdgeInsets.only(left: 20.0),
                                                      child: Text(
                                                        //Club hosting the event
                                                        eventData[item]!["EventClub"],
                                                        style:const TextStyle(
                                                            color: Colors.white),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                      const  Padding(
                                                            padding: EdgeInsets.only(
                                                                left: 25)),
                                                        Text(
                                                          //Date the event is to happen
                                                         period(eventData[item]!["EventDate"].toDate()),
                                                          style:const TextStyle(
                                                              color: Color.fromARGB(255, 255, 255, 255)),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                )),
                                          )
                                        ],
                                      )),
                                  )
                              )
                              .toList(),
                         );
                        },
                      ),
                      
                    );
                  }, 
              );
}