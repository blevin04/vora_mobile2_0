import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vora_mobile/dedicated/dedicatedCommunityPage.dart';
import 'package:vora_mobile/firebase_Resources/add_content.dart';
import 'package:vora_mobile/homepage.dart';
import 'package:vora_mobile/utils.dart';

class Newcommunity extends StatefulWidget {
  const Newcommunity({super.key});
  @override
  State<Newcommunity> createState() => _NewcommunityState();
}

TextEditingController namecontroller = TextEditingController();
TextEditingController leadController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController aboutController = TextEditingController();
String drop_value = " ";
List<String> socials = [
  "Instagram",
  "Twitter",
  "LinkedIn",
  "Website",
  "Github",
  "WhatsApp",
  "Email",
  "YouTube",
  "Facebook"
];
List<String>categories = [
  "All",
  "Technology",
    "Arts",
    "Religion",
    "Music",
    "Travel",
    "Engineering",
    
];
List<bool> active_socials = [
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false
];
List<TextEditingController> socialsController = [
  TextEditingController(),
  TextEditingController(),
  TextEditingController(),
  TextEditingController(),
  TextEditingController(),
  TextEditingController(),
  TextEditingController(),
  TextEditingController(),
  TextEditingController(),
];
bool visibility = true;

class _NewcommunityState extends State<Newcommunity> {
  String cover_photo = '';
  String dropdownvalue = "Public";
  String dropdownvalue1 = "All";
  var visible = ["Private", "Public"];
  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "New community",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Community Name",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color:const Color.fromARGB(255, 86, 86, 86)),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: namecontroller,
                  style: const TextStyle(color: Colors.white),
                  decoration:const InputDecoration(
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 161, 159, 159))),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
             const Text(
              "About the new club",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color:const Color.fromARGB(255, 86, 86, 86)),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: aboutController,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Lead /Chairparson",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color:const Color.fromARGB(255, 86, 86, 86)),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: leadController,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Email Address",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color:const Color.fromARGB(255, 86, 86, 86)),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration:const InputDecoration(),
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              color: Colors.black,
              child: DropdownButton(
                borderRadius: BorderRadius.circular(10),
                dropdownColor: const Color.fromARGB(255, 57, 56, 56),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                value: dropdownvalue,
                icon: const Icon(Icons.keyboard_arrow_down_sharp),
                items: visible.map((String item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (newval) {
                  setState(() {
                    dropdownvalue = newval!;
                    if (dropdownvalue == "private") {
                      visibility = false;
                    } else {
                      visibility = true;
                    }
                  });
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              color: Colors.black,
              child: DropdownButton(
                borderRadius: BorderRadius.circular(10),
                dropdownColor: const Color.fromARGB(255, 57, 56, 56),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                value: dropdownvalue1,
                icon: const Icon(Icons.keyboard_arrow_down_sharp),
                items: categories.map((String item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (newval) {
                  if (newval != dropdownvalue1) {
                    setState(() {
                      dropdownvalue1 = newval!;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Cover Photo",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DottedBorder(
                dashPattern: const [4, 2],
                color: const Color.fromARGB(255, 240, 239, 239),
                radius: const Radius.circular(10),
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
                      cover_photo = result.files.single.path!;
                      setState(() {});
                    }
                    if (result == null) {
                      showsnackbar(context, 'no image chossen');
                    }
                  },
                  child: const Center(
                    child: Column(
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
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 86, 86, 86)),
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: const Text(
                    "Socials",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context, setState) {
                                  return Center(
                                      child: Dialog(
                                          alignment: Alignment.center,
                                          insetPadding:
                                              const EdgeInsets.all(10),
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            29,
                                            36,
                                            45,
                                          ),
                                          child: Container(
                                            height: 500,
                                            child: ListView.builder(
                                                itemCount: socials.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        index) {
                                                  return ListTile(
                                                    title: Text(
                                                      socials[index],
                                                      style:const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 17),
                                                    ),
                                                    leading: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          active_socials[
                                                                  index] =
                                                              !active_socials[
                                                                  index];
                                                        });
                                                      },
                                                      icon: Icon(active_socials[
                                                              index]
                                                          ? Icons
                                                              .check_box_outlined
                                                          : Icons
                                                              .check_box_outline_blank_rounded),
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                }),
                                          )));
                                },
                              );
                            }).whenComplete(() {
                          setState(() {});
                        });
                      },
                      icon: const Icon(Icons.keyboard_arrow_down_sharp)),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ListView.builder(
                itemCount: socials.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, index) {
                  return Visibility(
                      visible: active_socials[index],
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                socials[index],
                                style:const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color:const Color.fromARGB(255, 86, 86, 86)),
                                    borderRadius: BorderRadius.circular(10)),
                                child: TextField(
                                  style:const TextStyle(color: Colors.white),
                                  controller: socialsController[index],
                                ),
                              ),
                            )
                          ],
                        ),
                      ));
                }),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () async {
                    List<String> state = ['Error occured please try again'];
                    while(state[0] == 'Error occured please try again'){
                      showcircleprogress(context);
                        var fsocials_ =  <String, String>{};
                    if (namecontroller.text.isNotEmpty &&
                        cover_photo != '' &&
                        leadController.text.isNotEmpty &&
                        aboutController.text.isNotEmpty&&
                        emailController.text.isNotEmpty) {
                      for (var i = 0; i < socials.length; i++) {
                        if (socialsController[i].text.isNotEmpty) {
                         
                          var name = socials[i];
                          var link = socialsController[i];
                          final ok = <String, String>{name: link.text};
                          fsocials_.addEntries(ok.entries);
                        }
                      }
                      List<String> categ = List.empty(growable: true);
                      categ.add(dropdownvalue1);
                      state = await addcommunity(
                        aboutclub: aboutController.text,
                          name: namecontroller.text,
                          lead: leadController.text,
                          categories: categ,
                          socials: fsocials_,
                          Email: emailController.text,
                          visibility: visibility,
                          cover_pic: cover_photo
                          
                          );
                    }else{
                      state[0] = "Fill all the boxes";
                    }
                    }
                    
                    ;
                    if (state[0] == 'Success') {
                      showsnackbar(context, "Community added");
                     Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  Dedicatedcommunitypage(clubId: state.last,)));
                    }
                  },
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Center(
                        child: Text(
                          "Create",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
