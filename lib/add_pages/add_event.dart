import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vora_mobile/dedicated/dedicatedEventPage.dart';
import 'package:vora_mobile/firebase_Resources/add_content.dart';
import 'package:vora_mobile/homepage.dart';
import 'package:vora_mobile/utils.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

TextEditingController _title = TextEditingController();
TextEditingController _description = TextEditingController();

TextEditingController _reg_link = TextEditingController();
TextEditingController _res_link = TextEditingController();
DateTime eventDate = DateTime.now();
List<String> others = List.empty(growable: true);
String cover_image = '';
TimeOfDay startTime = TimeOfDay(hour: 0, minute: 0);
TimeOfDay endTime = TimeOfDay(hour: 0, minute: 0);
bool startSet = false;
var week = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thusday",
  "Friday",
  "Saturday",
  "Sunday"
];
bool comm_drop = false;
String defatult_t = 'Select Community';

class _AddEventState extends State<AddEvent> {
  List<String> community1 = List.empty(growable: true);
  @override
  void initState() {
    super.initState();
    getcommunities();
    _title.clear();
    _description.clear();

    _reg_link.clear();
    _res_link.clear();
    cover_image = '';
    others.clear();
    defatult_t = 'Select Community';
  }

  void getcommunities() async {
    await store
        .collection("Communities")
        .where("Visibility", isEqualTo: true)
        .get()
        .then((val) {
      for (var snapshot in val.docs) {
        community1.add(snapshot.data()["Name"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double _widht = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
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
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Propose Event",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              const SizedBox(
                width: 10,
                height: 10,
              ),
              const Text(
                "Title",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color.fromARGB(255, 107, 105, 105))),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _title,
                  )),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Description",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Container(
                constraints:
                    BoxConstraints(maxHeight: _height / 1.5, minHeight: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color.fromARGB(255, 107, 105, 105))),
                child: TextField(
                  maxLines: null,
                  // expands: true,
                  style: const TextStyle(color: Colors.white),
                  controller: _description,
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
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color.fromARGB(255, 107, 105, 105))),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          setState(() {
                            comm_drop = !comm_drop;
                          });
                        },
                        trailing: const Icon(Icons.keyboard_arrow_down_rounded),
                        title: Text(
                          defatult_t,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Visibility(
                          visible: comm_drop,
                          child: ListView.builder(
                              itemCount: community1.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, index) {
                                return ListTile(
                                  onTap: () {
                                    setState(() {
                                      defatult_t = community1[index];
                                      comm_drop = !comm_drop;
                                    });
                                  },
                                  title: Text(
                                    community1[index],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              })),
                    ],
                  )),
              const SizedBox(
                height: 20,
              ),
              const Row(
                children: [
                  Text(
                    "Event Date ",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    "(yyyy-mm-dd)",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color.fromARGB(255, 107, 105, 105))),
                  child: InkWell(
                    onTap: () {
                      showDatePicker(
                        helpText: "Event Date",
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2040),
                      ).then((onValue) {
                        eventDate = onValue!;
                        setState(() {});
                      });
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "${week[eventDate.weekday-1]} - ${eventDate.year} - ${eventDate.month} - ${eventDate.day}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Event time",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              InkWell(
                onTap: () async {
                  for (var i = 0; i < 2; i++) {
                    await showTimePicker(
                            useRootNavigator: true,
                            helpText: i != 0 ? "End Time" : "Start Time",
                            context: context,
                            initialTime: TimeOfDay.now())
                        .then((onValue) {
                      if (i == 0) {
                        startTime = onValue!;
                      } else {
                        endTime = onValue!;
                      }
                      startSet = !startSet;
                    });
                  }
                  setState(() {});
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 110, 109, 109)),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "${startTime.format(context)} to ${endTime.format(context)}",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
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
                    color: Colors.white,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                          image: cover_image.isNotEmpty
                              ? DecorationImage(
                                  fit: BoxFit.contain,
                                  image: FileImage(File(cover_image)))
                              : null),
                      child: InkWell(
                        onTap: () async {
                          await Permission.accessMediaLocation
                              .onDeniedCallback(() async {
                            Permission.accessMediaLocation.request();
                            if (await Permission.accessMediaLocation.isDenied) {
                              showsnackbar(context, "Permission denied");
                            }
                            if (await Permission
                                .accessMediaLocation.isGranted) {
                              showsnackbar(context, 'Granted');
                            }
                          });
                          FilePickerResult? result = (await FilePicker.platform
                              .pickFiles(type: FileType.image));
                          if (result != null) {
                            cover_image = result.files.single.path!;
                            setState(() {});
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Registration Link",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color.fromARGB(255, 107, 105, 105))),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _reg_link,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Link Event Resources",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color.fromARGB(255, 107, 105, 105))),
                child: TextField(
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: Container(
                                      height: 120,
                                      width: 200,
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 119, 120, 123),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                "Add More Media",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  TextButton(
                                                      onPressed: () async {
                                                        FilePickerResult res =
                                                            await getimage(
                                                                context, true);
                                                        for (var i = 0;
                                                            i <
                                                                res.files
                                                                    .length;
                                                            i++) {
                                                          others.add(res
                                                              .files[i].path!);
                                                        }
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        "OK",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ))
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          },
                          icon: const Icon(Icons.add_a_photo_outlined)),
                      suffixIconColor: Colors.white),
                  style: const TextStyle(color: Colors.white),
                  controller: _res_link,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                children: List.generate(others.length, (index) {
                  print("grid ${others.length}");
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      alignment: Alignment.topRight,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image: FileImage(File(others[index])))),
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              others.removeAt(index);
                            });
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          )),
                    ),
                  );
                }),
              ),
              Center(
                child: InkWell(
                  onTap: () async {
                   List< String >state =List.empty(growable: true);
                    while (state.isEmpty) {
                      showcircleprogress(context);
                      if (_title.text.isNotEmpty &&
                          _description.text.isNotEmpty &&
                          cover_image != '' &&
                          _reg_link.text.isNotEmpty) {
                        state = await AddEvent_(
                            title: _title.text,
                            description: _description.text,
                            community: defatult_t,
                            image_path: cover_image,
                            time: eventDate,
                            reg_link: _reg_link.text,
                            rec_link: _res_link.text,
                            other_img: others);
                      }
                    }
                    if (state.first == "Success") {
                      showsnackbar(context, "Event Added successfully");
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  Dedicatedeventpage(eventId: state.last,)));
                    } else {
                      showsnackbar(context, state.first);
                    }
                  },
                  child: Container(
                    width: _widht / 2.2,
                    decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
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
