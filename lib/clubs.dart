// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vora_mobile/Accounts.dart';
import 'package:vora_mobile/announcemnts.dart';
import 'package:vora_mobile/dedicated/dedicatedCommunityPage.dart';
import 'package:vora_mobile/events.dart';
import 'package:vora_mobile/firebase_Resources/add_content.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vora_mobile/utils.dart';

late MemoryImage img1;

class Clubs extends StatefulWidget {
  const Clubs({super.key});

  @override
  State<Clubs> createState() => _ClubsState();
}

void getimg1(String path) async {
  var data = await store1.child("/communities/$path/cover_picture").getData();
  img1 = MemoryImage(data!);
}

final store1 = FirebaseStorage.instance.ref();
final firestore = FirebaseFirestore.instance;
TextEditingController _search = TextEditingController();

class _ClubsState extends State<Clubs> {
  final List<String> filter = <String>[
    "all",
    "Technology",
    "Arts",
    "Religion",
    "Music",
    "Travel",
    "Engineering",
    "Member",
    "Non-Member"
  ];
  FaIcon Ausomicons(String name) {
    FaIcon icon;
    switch (name) {
      case "LinkedIn":
        icon = const FaIcon(
          size: 15,
          FontAwesomeIcons.linkedin,
          color: Colors.white,
        );
        break;
      case "Twitter":
        icon = const FaIcon(
          size: 15,
          FontAwesomeIcons.twitter,
          color: Colors.white,
        );
        break;
      case "Instagram":
        icon = const FaIcon(
          size: 15,
          FontAwesomeIcons.instagram,
          color: Colors.white,
        );
        break;

      case "YouTube":
        icon = const FaIcon(
          size: 15,
          FontAwesomeIcons.youtube,
          color: Colors.white,
        );
        break;
      case "Email":
        icon = const FaIcon(
          size: 15,
          FontAwesomeIcons.envelope,
          color: Colors.white,
        );
        break;
      case "Facebook":
        icon = const FaIcon(
          size: 15,
          FontAwesomeIcons.facebook,
          color: Colors.white,
        );
        break;
      default:
        icon = const FaIcon(
          size: 15,
          FontAwesomeIcons.icons,
          color: Colors.white,
        );
    }
    return icon;
  }
ValueNotifier<bool> search_visible = ValueNotifier(false);

void _visibleChanged(){}
  
  String dropdown_value = "all";
  @override
  void initState() {
    super.initState();
    search_visible.addListener(_visibleChanged);
    clubScale = 0.97;
  }

  Future<List<String>> get(String filter) async {
    List<String> communities_ = List.empty(growable: true);
    switch (filter) {
      case "all":
        await firestore
        .collection("Communities")
        .where("Visibility", isEqualTo: true)
        .get()
        .then((onValue) {
      for (var snap in onValue.docs) {
        communities_.add(snap["Uid"]);
      }
    });
        break;

      case "Technology":
        await firestore
        .collection("Communities")
        .where("Category", arrayContains: "Technology")
        .get()
        .then((onValue) {
      for (var snap in onValue.docs) {
        communities_.add(snap["Uid"]);
      }
    });
        break;
      case "Arts": 
      await firestore
        .collection("Communities")
        .where("Category", arrayContains: "Arts")
        .get()
        .then((onValue) {
      for (var snap in onValue.docs) {
        communities_.add(snap["Uid"]);
      }
    });
        break;
      case "Religion":
        await firestore
        .collection("Communities")
        .where("Category", arrayContains: "Religion")
        .get()
        .then((onValue) {
      for (var snap in onValue.docs) {
        communities_.add(snap["Uid"]);
      }
    });
        break;

      case "Music":
        await firestore
        .collection("Communities")
        .where("Category", arrayContains: "Music")
        .get()
        .then((onValue) {
      for (var snap in onValue.docs) {
        communities_.add(snap["Uid"]);
      }
    });
        break;

      case "Travel":
        await firestore
        .collection("Communities")
        .where("Category", arrayContains: "Travel")
        .get()
        .then((onValue) {
      for (var snap in onValue.docs) {
        communities_.add(snap["Uid"]);
      }
    });
        break;
    
      case "Engineering":
        await firestore
        .collection("Communities")
        .where("Category", arrayContains: "Engineering")
        .get()
        .then((onValue) {
      for (var snap in onValue.docs) {
        communities_.add(snap["Uid"]);
      }
    });
        break;

      case "Member":
        await firestore.collection("users").doc(user.uid).get().then((onValue){
          for(var com in onValue.data()!["Communities"]){
            communities_.add(com);
          }
        });
        break;
      
      case  "Non-Member":
        await firestore.collection("users").doc(user.uid).get().then((onValue)async{
          List membercoms = onValue.data()!["Communities"];
          await firestore.collection("Communities").where("Visibility", isEqualTo: true).get().then((all){
            for(var one in all.docs){
              communities_.add(one.id);
            }
          });
          for (var i = 0; i < membercoms.length; i++) {
            if (communities_.contains(membercoms[i])) {
              communities_.remove(membercoms[i]);
            }
          }
        });

        break;
    
      default:
    }
    
    return communities_;
  }
Future<Map<String,dynamic>> clubdata (String clubId)async{
  Map<String,dynamic> clubd_ = {};
  bool member = false;
  await firestore.collection("users").doc(user.uid).get().then((userd){
      member = userd.data()!["Communities"].contains(clubId);
  });
  final memberstatus = <String,dynamic>{"Member":member};
  clubd_.addAll(memberstatus);
  await firestore.collection("Communities").doc(clubId).get().then((onValue){
    clubd_.addAll(onValue.data()!);
  });
  await store1.child("/communities/$clubId/cover_picture").getData().then((onValue1){
    final cover_pic =<String,dynamic>{"Image":onValue1!};
    clubd_.addAll(cover_pic);
  });
  final Sdata = <String,Map<String,dynamic>>{clubId:clubd_};
  if (!clubData.containsKey(clubId)) {
    clubData.addAll(Sdata);
  }
  return clubd_;
}
 double clubScale = 0.96;
  bool _search_vis = false;
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
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigator.of(context).pop(MaterialPageRoute(
              //   builder: (context) => const Homepage(),
              // ));
            },
            icon: const Icon(
              Icons.arrow_back_sharp,
              color: Colors.white,
            )),
        title: const Text(
          "Clubs and societies",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _search_vis = !_search_vis;
                search_visible.value = !search_visible.value;
              },
              icon: const Icon(
                Icons.search_sharp,
                color: Colors.white,
              )),
          IconButton(
              onPressed: ()async {
                await Navigator.push(context, MaterialPageRoute(builder: (context)=>const Announcemnts()));
              },
              icon:  Badge(
                label: FutureBuilder(
                  future: getannouncementnumber(),
                  initialData: 0,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    
                    return Text(snapshot.data.toString());
                  },
                ),

                child:const Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
              ))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ()async{
          get(dropdown_value);
        },
        child: SingleChildScrollView(
          physics:const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StatefulBuilder(
                      builder: (context,setstate2) {
                        return ListenableBuilder(
                          listenable: search_visible,
                          builder: (context, child) {
                            return Visibility(
                            visible: _search_vis,
                            child: SizedBox(
                              width: 120,
                              child: TextField(
                                controller: _search,
                                decoration: const InputDecoration(
                                    labelText:"Search" ,
                                    labelStyle: TextStyle(color: Colors.white)
                                    ),
                              ),
                            ),
                                                );
                          }
                        );
                      },
                      
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    DropdownButton(
                      borderRadius: BorderRadius.circular(8),
                      value: dropdown_value,
                      dropdownColor: const Color.fromARGB(
                        255,
                        29,
                        36,
                        45,
                      ),
                      // Down Arrow Icon
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
        
                      // Array list of items
                      items: filter.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(
                            items,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
        
                      onChanged: (String? newValue) {
                        if (newValue != dropdown_value) {
                          setState(() {
                          dropdown_value = newValue!;
                        });
                        }
                        
                      },
                    ),
                  ],
                ),
              ),
              
              FutureBuilder(
                  future: get(dropdown_value),
                  builder: (context, snpsht) {
                    if (snpsht.connectionState == ConnectionState.waiting) {
                      return  Center(child: SizedBox(
                        height: windowheight-100,
                        child:const Center(child: CircularProgressIndicator(color: Colors.blue,),),
                      ),);
                    }
                    if (snpsht.connectionState == ConnectionState.none) {
                                      return const Center(child: 
                                      Column(children: [Icon(Icons.wifi_off_rounded),
                                      Text("Offline...")],),);
                                    }
                    List<String> data_snap = snpsht.data!;
                    
                    return 
                    ListView.builder(
                        itemCount: data_snap.length,
                        shrinkWrap: true,
                        physics:const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return SizedBox(
                             height: windowheight / 4.1,
                            child:clubData[data_snap[index]]==null?
                             FutureBuilder(
                               // initialData: img = AssetImage("lib/assets/dp.png"),
                                future: clubdata(data_snap[index]),
                                builder: (context, snapshot) {
                                  
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    clubScale = 0.95;
                                    return   Padding(
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
                                  Uint8List c_image = snapshot.data!["Image"];
                                  String C_name = snapshot.data!["Name"];
                                  String C_about = snapshot.data!["About"];
                                  bool memberstatus = snapshot.data!["Member"];
                                  return showcontent(context, data_snap[index], windowWidth, c_image, C_name, C_about,memberstatus);
                                }):
                                showcontent(context, data_snap[index], windowWidth, clubData[data_snap[index]]!["Image"], 
                                clubData[data_snap[index]]!["Name"], clubData[data_snap[index]]!["About"],clubData[data_snap[index]]!["Member"]),
                          );
                        });
                  })
            ],
          ),
        ),
      ),
    ));
  }
}
Widget showcontent(
  BuildContext context,
  String clubId,
  double windowWidth,
  Uint8List coverImage,
  String Clubname,
  String aboutclub,
  bool member,
){
  return StatefulBuilder(
    builder: (BuildContext context, setState1) {
      
      return InkWell(
        enableFeedback: false,
        splashColor: Colors.transparent,
                onTap: () => Navigator.push(context,MaterialPageRoute(builder: 
                (context)=>  Dedicatedcommunitypage(clubId: clubId,))),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Card(
                    margin:const EdgeInsets.all(0),
                    elevation: 10,
                    shadowColor: const Color.fromARGB(96, 45, 44, 44),
                    color: Colors.transparent,
                    child: Container(
                     
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(0, 46, 45, 45),
                          border: Border.all(color: const Color.fromARGB(55, 61, 60, 60)),
                          borderRadius:
                              BorderRadius.circular(10)),
                      width: windowWidth,
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: MemoryImage(coverImage)
                                          ),
                                  borderRadius:
                                      BorderRadius.circular(20)),
                              width: windowWidth/ 2.3,
                            ),
                          ),
                          Container(
                              width: windowWidth/ 2,
                              alignment: Alignment.topCenter,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Clubname,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20),
                                  ),
                                    Padding(
                                    padding:const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      aboutclub,
                                      style:const TextStyle(
                                          color: Colors.white),
                                      maxLines: 3,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                  
                                  Visibility(
                                    visible:!member,
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Center(
                                                child: Dialog(
                                                  insetPadding:
                                                      const EdgeInsets
                                                          .all(10),
                                                  backgroundColor:
                                                      const Color
                                                          .fromARGB(
                                                          255,
                                                          51,
                                                          52,
                                                          53),
                                                  child: SizedBox(
                                                    height: 120,
                                                    width: 170,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .all(
                                                              10.0),
                                                          child:
                                                              Text(
                                                            "Join $Clubname",
                                                            style: const TextStyle(
                                                                color:
                                                                    Colors.white),
                                                          ),
                                                        ),
                                                       
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            TextButton(
                                                                onPressed:
                                                                    () async{
                                                                      showcircleprogress(context);
                                                                    String state=  await join(communId: clubId);
                                                                        if (state == "Success") {
                                                                          member = true;
                                                                          showsnackbar(context, "Successfully joined $Clubname");

                                                                        }
                                                                        // else{
                                                                        //   print(state);}
                                                                        Navigator.pop(context);
                                                                        Navigator.pop(context);
                                                                        setState1((){});
                                                                    },
                                                                child: Container(
                                                                    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10)),
                                                                    child: const Padding(
                                                                      padding: EdgeInsets.all(10.0),
                                                                      child: Text(
                                                                        "Yes",
                                                                        style: TextStyle(color: Colors.white),
                                                                      ),
                                                                    ))),
                                                            TextButton(
                                                                onPressed:
                                                                    () {
                                                                      Navigator.pop(context);
                                                                    },
                                                                child:
                                                                    Container(decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10)), 
                                                                    child:const Padding(padding: EdgeInsets.all(10), child: Text("Cancel"))))
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      enableFeedback: true,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.blueAccent,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(10)),
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.all(5.0),
                                          child: Text(
                                            "Join Community",
                                            style: TextStyle(
                                                color:
                                                    Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                      onPressed: ()async {
                                        await Navigator.push(context, MaterialPageRoute(builder: (context)=>  Events(filtername: Clubname)));
                                      },
                                      child:  Text(
                                          "$Clubname Events...",style:const TextStyle(color: Colors.white),))
                                ],
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
              );
    }
  );
}