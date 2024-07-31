import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:vora_mobile/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vora_mobile/utils.dart';

final storage =
    FirebaseStorage.instance.ref().child('/profile/${user.uid}/dp.png');
FirebaseFirestore store = FirebaseFirestore.instance;
User user = FirebaseAuth.instance.currentUser!;
var snap;

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

var img;

class _AccountsState extends State<Accounts> {
  @override
  void initState() {
    super.initState();
    snap = store.collection("users").doc(user.uid).get();
    getImagelnk();
  }

  void getImagelnk() async {
    img = await storage.getData();
  }

  @override
  Widget build(BuildContext context) {
    // double _width = MediaQuery.of(context).size.width;
    // double _height = MediaQuery.of(context).size.height;

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
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Homepage())),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          title: const Text(
            "My Profile",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                future: storage.getData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  Uint8List data_ = Uint8List(2);
                  if (snapshot.hasData) {
                    Uint8List data = snapshot.data;
                    data_ = data;
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 100,
                            backgroundColor: Colors.white,
                            backgroundImage: snapshot.hasData
                                ? MemoryImage(data_)
                                : const AssetImage('lib/assets/dp.png'),
                          ),
                          IconButton(
                              color: Colors.black,
                              onPressed: () async {
                                await Permission.accessMediaLocation
                                    .onDeniedCallback(() async {
                                  Permission.accessMediaLocation.request();
                                  if (await Permission
                                      .accessMediaLocation.isDenied) {
                                    showsnackbar(context, "Permission denied");
                                  }
                                  if (await Permission
                                      .accessMediaLocation.isGranted) {
                                    showsnackbar(context, 'Granted');
                                  }
                                });
                                FilePickerResult? result = (await FilePicker
                                    .platform
                                    .pickFiles(type: FileType.image));
                                if (result != null) {
                                  storage.delete();
                                  storage
                                      .putFile(File(result.files.single.path!));
                                  setState(() {});
                                }
                                if (result == null) {
                                  showsnackbar(context, 'no image chossen');
                                }
                              },
                              icon: const Icon(
                                Icons.camera_alt_sharp,
                                color: Color.fromARGB(255, 147, 132, 132),
                                size: 25,
                              ))
                        ],
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder(
                future: store.collection('users').doc(user.uid).get(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  Map<String, dynamic> data =
                      snapshot.data.data() as Map<String, dynamic>;

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          data['fullName'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          data['nickname'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Divider(
                          indent: 30,
                          endIndent: 30,
                          color: Color.fromARGB(160, 69, 69, 69),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
