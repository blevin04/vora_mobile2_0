import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:vora_mobile/homepage.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

final store = FirebaseStorage.instance.ref();
final firestore = FirebaseFirestore.instance;
Widget show = Text(
  "Events",
  style: TextStyle(color: Colors.white),
);
var event_filter = [
  "all",
  "Registered",
  "not Registered",
  "From all clubs",
];
String event_value = "all";
bool events_vis = false;
TextEditingController _search_events = TextEditingController();
List<String> eventIds = List.empty(growable: true);

class _EventsState extends State<Events> {
  @override
  void initState() {
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
        //  print(snaps);
      }
    });
    // print(eventIds);
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
    // double _width = MediaQuery.of(context).size.width;
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
                setState(() {
                  events_vis = !events_vis;
                });
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
                Visibility(
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
                    )),
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
            ),
            FutureBuilder(
                future: getevents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: eventIds.length,
                      itemBuilder: (context, index2) {
                        String name = '';
                        Timestamp time_ = Timestamp.now();
                        firestore
                            .collection("Events")
                            .doc(eventIds[index2])
                            .get()
                            .then(
                          (value) {
                            name = value["Title"];
                            time_ = value["EventDate"];
                          },
                        );

                        // print("imgno = ${imgno}");
                        return Padding(
                            padding: const EdgeInsets.all(2),
                            child: Card(
                              color: const Color.fromARGB(86, 82, 81, 81),
                              elevation: 10,
                              child: InkWell(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(5),
                                            child: CircleAvatar(
                                              backgroundImage: AssetImage(
                                                  "lib/assets/dp.png"),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          189, 255, 255, 255)),
                                                ),
                                                Text(
                                                  time_.toDate().toString(),
                                                  style:const TextStyle(
                                                      color: Color.fromARGB(
                                                          174, 255, 255, 255)),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 250,
                                      child: FutureBuilder(
                                        future: getimgs(index2),
                                        // initialData: InitialData,
                                        builder: (BuildContext context,
                                            AsyncSnapshot snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                          var data;
                                          return ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: imgdir.items.length,
                                              itemBuilder: (context, imgno) {
                                                var dir = imgdir.items[imgno]
                                                    .toString();
                                                dir = dir.split("/")[
                                                    dir.split("/").length - 1];
                                                dir = dir.split(")")[
                                                    dir.split(")").length - 2];
                                                dir =
                                                    "/events/${eventIds[index2]}/$dir";
                                                return FutureBuilder(
                                                  future: store
                                                      .child(dir)
                                                      .getData(),
                                                  // initialData: InitialData,
                                                  builder: (BuildContext
                                                          context,
                                                      AsyncSnapshot snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                      );
                                                    }

                                                    if (snapshot.hasData) {
                                                      data = snapshot.data;
                                                    }
                                                    return Container(
                                                      padding:
                                                        const  EdgeInsets.all(5),
                                                      child: Image(
                                                          image: snapshot
                                                                  .hasData
                                                              ? MemoryImage(
                                                                  data)
                                                              :const AssetImage(
                                                                  "lib/assets/dp.png")),
                                                    );
                                                  },
                                                );
                                              });
                                        },
                                      ),
                                    ),
                                    Container(
                                      height: 50,
                                      child: Row(
                                        children: [
                                          //like button
                                          IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.thumb_up_alt_outlined,
                                                color: Color.fromARGB(
                                                    255, 108, 105, 105),
                                              ))
                                          //comment field
                                          ,
                                          IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.comment,
                                                color: Color.fromARGB(
                                                    255, 99, 95, 95),
                                              ))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomLeft,
                                      child: const Text(
                                        "About the event .....",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ));
                      });
                })
          ],
        ),
      ),
    ));
  }
}
