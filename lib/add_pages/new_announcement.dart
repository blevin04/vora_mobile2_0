import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:vora_mobile/firebase_Resources/add_content.dart';
import 'package:vora_mobile/homepage.dart';
import 'package:vora_mobile/utils.dart';

class NewAnnouncement extends StatefulWidget {
  const NewAnnouncement({super.key});

  @override
  State<NewAnnouncement> createState() => _NewAnnouncementState();
}

FirebaseFirestore store = FirebaseFirestore.instance;
TextEditingController title_ = TextEditingController();
TextEditingController decription = TextEditingController();
TextEditingController community = TextEditingController();
String image_path = '';

class _NewAnnouncementState extends State<NewAnnouncement> {
  List<String> communities = List.empty(growable: true);
  @override
  void initState() {
    super.initState();
    communities.clear;
    getcommunities();
  }

  bool comm_drop = false;
  String drop_val1 = 'Select Community';
  void getcommunities() async {
    await store
        .collection("Communities")
        .where("Visibility", isEqualTo: true)
        .get()
        .then((val) {
      for (var snapshot in val.docs) {
        print("${snapshot.id} => ${snapshot.data()["Numbers"]}");
        communities.add(snapshot.data()["Name"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    // double _height = MediaQuery.of(context).size.height;

    return Scaffold(
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
              Navigator.pop(context,
                  MaterialPageRoute(builder: (context) => const Homepage()));
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "New Announcement",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Title",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: title_,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Description",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: decription,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Community",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      ListTile(
                          title: Text(
                            drop_val1,
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Icon(Icons.keyboard_arrow_down_rounded),
                          onTap: () {
                            setState(() {
                              comm_drop = !comm_drop;
                            });
                          }),
                      Visibility(
                          visible: comm_drop,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: communities.length,
                              itemBuilder: (BuildContext context, index) {
                                return ListTile(
                                  onTap: () {
                                    setState(() {
                                      drop_val1 = communities[index];
                                      comm_drop = !comm_drop;
                                    });
                                  },
                                  title: Text(
                                    communities[index],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }))
                    ],
                  )),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Cover Image",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DottedBorder(
                    radius: const Radius.circular(10),
                    color: Colors.white,
                    child: InkWell(
                      onTap: () async {
                        await Permission.accessMediaLocation
                            .onDeniedCallback(() async {
                          Permission.accessMediaLocation.request();
                          if (await Permission.accessMediaLocation.isDenied) {
                            showsnackbar(context, "Permission denied");
                          }
                          if (await Permission.accessMediaLocation.isGranted) {
                            showsnackbar(context, 'Granted');
                          }
                        });
                        FilePickerResult? result = (await FilePicker.platform
                            .pickFiles(type: FileType.image));
                        if (result != null) {
                          image_path = result.files.single.path!;
                        }
                        if (result == null) {
                          showsnackbar(context, 'no image chossen');
                        }
                      },
                      child: const Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_sharp,
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Click to upload...",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            )
                          ],
                        ),
                      ),
                    )),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: InkWell(
                  onTap: () async {
                    String state = "An Error Occured";
                    while (state == "An Error Occured") {
                      showcircleprogress(context);
                      if (title_.text.isNotEmpty &&
                          decription.text.isNotEmpty &&
                          drop_val1 != 'Select Community') {
                        state = await AddAnnouncement(
                          title: title_.text,
                          description: decription.text,
                          community: drop_val1,
                          imagepath: image_path,
                        );
                      }
                      if (title_.text.isEmpty) {
                        showsnackbar(context, "Empty Title");
                      }
                      if (drop_val1 == 'Select Community') {
                        showsnackbar(context, "Select a community");
                      }
                    }

                    if (state == "success") {
                      showsnackbar(context, "Announcement Added...");
                      Navigator.pop(context);
                      Navigator.pop(
                          context,
                          (MaterialPageRoute(
                              builder: (context) => const Homepage())));
                    } else {
                      showsnackbar(context, state);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    margin: const EdgeInsets.all(0),
                    width: _width / 2.2,
                    decoration: BoxDecoration(
                      border:Border.all(color:Colors.transparent),
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(10)),
                    child: const OutlinedButton(
                      onPressed: null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.publish,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Publish",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
