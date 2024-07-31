import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vora_mobile/homepage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    "Engineering"
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

  List<String> communities_ = List.empty(growable: true);
  String dropdown_value = "all";
  @override
  void initState() {
    super.initState();
  }

  Future<void> get() async {
    communities_.clear();
    await firestore
        .collection("Communities")
        .where("Visibility", isEqualTo: true)
        .get()
        .then((onValue) {
      for (var snap in onValue.docs) {
        communities_.add(snap["Uid"]);
      }
    });
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
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const Homepage(),
              ));
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
                setState(() {
                  _search_vis = !_search_vis;
                });
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
                  Visibility(
                    visible: _search_vis,
                    child: SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _search,
                        decoration: const InputDecoration(
                            label: Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.white,
                        )),
                      ),
                    ),
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
                      setState(() {
                        dropdown_value = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
            FutureBuilder(
                future: get(),
                builder: (context, snpsht) {
                  return ListView.builder(
                      itemCount: communities_.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        //  Map<String, dynamic> numbers = {};
                        var name = '';
                        var img;
                        firestore
                            .collection("Communities")
                            .doc(communities_[index])
                            .get()
                            .then((value) {
                          name = value.data()!["Name"];
                          //  numbers = value.data()!["Numbers"];
                        });
                        return FutureBuilder(
                            initialData: img = AssetImage("lib/assets/dp.png"),
                            future: store1
                                .child(
                                    "/communities/${communities_[index]}/cover_picture")
                                .getData()
                                .then((onValue) {
                              // print(onValue);
                              img = onValue!;
                            }),
                            builder: (context, snapshot) {
                              return InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    height: _height / 4.5,
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
                                                    image: img ==
                                                            const AssetImage(
                                                                "lib/assets/dp.png")
                                                        ? img
                                                        : MemoryImage(img)),
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
                                                  name,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "About...",
                                                    style: TextStyle(
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
                                                                        "Join $name",
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
                                                                                () {},
                                                                            child: Container(
                                                                                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                                                                                child: const Padding(
                                                                                  padding: EdgeInsets.all(10.0),
                                                                                  child: Text(
                                                                                    "Yes",
                                                                                    style: TextStyle(color: Colors.white),
                                                                                  ),
                                                                                ))),
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {},
                                                                            child:
                                                                                Container(decoration: BoxDecoration(color: Colors.deepPurpleAccent, borderRadius: BorderRadius.circular(10)), child: Padding(padding: EdgeInsets.all(10), child: Text("Cancel"))))
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
                            });
                      });
                }),
          ],
        ),
      ),
    ));
  }
}
