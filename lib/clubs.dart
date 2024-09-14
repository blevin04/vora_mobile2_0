import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vora_mobile/dedicated/dedicatedCommunityPage.dart';
import 'package:vora_mobile/firebase_Resources/add_content.dart';
import 'package:vora_mobile/homepage.dart';
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
        .where("Category", isEqualTo: "Technology")
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
        .where("Category", isEqualTo: "Arts")
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
        .where("Category", isEqualTo: "Religion")
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
        .where("Category", isEqualTo: "Music")
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
        .where("Category", isEqualTo: "Travel")
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
        .where("Category", isEqualTo: "Engineering")
        .get()
        .then((onValue) {
      for (var snap in onValue.docs) {
        communities_.add(snap["Uid"]);
      }
    });
        break;

      case "Member":
        
        break;
      
      case  "Non-Member":

        break;
    
      default:
    }
    
    return communities_;
  }
Future<Map<String,dynamic>> clubdata (String clubId)async{
  Map<String,dynamic> clubd_ = Map();

  await firestore.collection("Communities").doc(clubId).get().then((onValue){
    final name =<String,dynamic>{"Name":onValue.data()!["Name"]};
    final about =<String,dynamic>{"About":onValue.data()!["About"]};
    clubd_.addAll(name);
    clubd_.addAll(about);
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
  bool _search_vis = false;
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
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
              onPressed: () {},
              icon: const Badge(
                label: Text("12"),
                child: Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
              ))
        ],
      ),
      body: SingleChildScrollView(
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
            clubData.isEmpty || clubIds.isEmpty?
            FutureBuilder(
                future: get(dropdown_value),
                builder: (context, snpsht) {
                  if (snpsht.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(),);
                  }
                  if (snpsht.connectionState == ConnectionState.none) {
                                    return const Center(child: 
                                    Column(children: [Icon(Icons.wifi_off_rounded),
                                    Text("Offline...")],),);
                                  }
                  List<String> data_snap = snpsht.data!;
                  return ListView.builder(
                      itemCount: data_snap.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return SizedBox(
                           height: _height / 4.5,
                          child: FutureBuilder(
                             // initialData: img = AssetImage("lib/assets/dp.png"),
                              future: clubdata(data_snap[index]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator(),);
                                }
                                if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                                Uint8List c_image = snapshot.data!["Image"];
                                String C_name = snapshot.data!["Name"];
                                String C_about = snapshot.data!["About"];

                                return InkWell(
                                  onTap: () => Navigator.push(context,MaterialPageRoute(builder: 
                                  (context)=>  Dedicatedcommunitypage(clubId: data_snap[index],))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                     
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 46, 45, 45),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      width: _width,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      fit: BoxFit.contain,
                                                      image: MemoryImage(c_image)
                                                          ),
                                                  borderRadius:
                                                      BorderRadius.circular(20)),
                                              width: _width / 2.3,
                                            ),
                                          ),
                                          Container(
                                              width: _width / 2,
                                              alignment: Alignment.topCenter,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    C_name,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  ),
                                                   Padding(
                                                    padding:const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      C_about,
                                                      style:const TextStyle(
                                                          color: Colors.white),
                                                      maxLines: 3,
                                                      overflow: TextOverflow.fade,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  InkWell(
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
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            10.0),
                                                                        child:
                                                                            Text(
                                                                          "Join $C_name",
                                                                          style: const TextStyle(
                                                                              color:
                                                                                  Colors.white),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            20,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .spaceAround,
                                                                        children: [
                                                                          TextButton(
                                                                              onPressed:
                                                                                  () async{
                                                                                 String state=  await join(communId: data_snap[index]);
                                                                                      if (state == "Success") {
                                                                                        showsnackbar(context, "Successfully joined $C_name");
                                                                                      }
                                                                                      else{print(state);}
                                                                                      Navigator.pop(context);
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
                                                                                  Container(decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Padding(padding: EdgeInsets.all(10), child: Text("Cancel"))))
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
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          "Join Community",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {},
                                                      child: const Text(
                                                          "Clubs Events..."))
                                                ],
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        );
                      });
                })
                :ListView.builder(
                      itemCount: clubIds.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        String currentClubId = clubIds[index];
                        Map<String,dynamic> currentClubData = eventData[currentClubId]!;
                       Uint8List c_image = currentClubData["Image"];
                                String C_name = currentClubData["Name"];
                                String C_about = currentClubData["About"];
                        return SizedBox(
                           height: _height / 4.5,
                          child: 
                               
                                 InkWell(
                                  onTap: () => Navigator.push(context,MaterialPageRoute(builder: 
                                  (context)=>  Dedicatedcommunitypage(clubId: currentClubId,))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                     
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 46, 45, 45),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      width: _width,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      fit: BoxFit.contain,
                                                      image: MemoryImage(c_image)
                                                          ),
                                                  borderRadius:
                                                      BorderRadius.circular(20)),
                                              width: _width / 2.3,
                                            ),
                                          ),
                                          Container(
                                              width: _width / 2,
                                              alignment: Alignment.topCenter,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    C_name,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  ),
                                                   Padding(
                                                    padding:const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      C_about,
                                                      style:const TextStyle(
                                                          color: Colors.white),
                                                      maxLines: 3,
                                                      overflow: TextOverflow.fade,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  InkWell(
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
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            10.0),
                                                                        child:
                                                                            Text(
                                                                          "Join $C_name",
                                                                          style: const TextStyle(
                                                                              color:
                                                                                  Colors.white),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            20,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .spaceAround,
                                                                        children: [
                                                                          TextButton(
                                                                              onPressed:
                                                                                  () async{
                                                                                 String state=  await join(communId: currentClubId);
                                                                                      if (state == "Success") {
                                                                                        showsnackbar(context, "Successfully joined $C_name");
                                                                                      }
                                                                                      else{print(state);}
                                                                                      Navigator.pop(context);
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
                                                                                  Container(decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Padding(padding: EdgeInsets.all(10), child: Text("Cancel"))))
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
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          "Join Community",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {},
                                                      child: const Text(
                                                          "Clubs Events..."))
                                                ],
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        );
                      }),
          ],
        ),
      ),
    ));
  }
}
class feed extends StatefulWidget {
  const feed({super.key});

  @override
  State<feed> createState() => _feedState();
}

class _feedState extends State<feed> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}