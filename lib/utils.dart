//snackbar
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

FirebaseFirestore store = FirebaseFirestore.instance;
showsnackbar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}

showcircleprogress(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 120,
            width: 120,
            color: Color.fromARGB(84, 50, 50, 50),
            child: const Center(
              child: CircularProgressIndicator(
                backgroundColor: Color.fromARGB(131, 128, 124, 124),
                color: Colors.lightBlueAccent,
              ),
            ),
          ),
        );
      });
}

Future<List<String>> getcommunities() async {
  var communities;
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

  return communities;
}

Future getimage(BuildContext context, bool multiple) async {
  await Permission.accessMediaLocation.onDeniedCallback(() async {
    Permission.accessMediaLocation.request();
    if (await Permission.accessMediaLocation.isDenied) {
      showsnackbar(context, "Permission denied");
    }
    if (await Permission.accessMediaLocation.isGranted) {
      showsnackbar(context, 'Granted');
    }
  });
  FilePickerResult? result = (await FilePicker.platform
      .pickFiles(type: FileType.image, allowMultiple: multiple));
  if (result != null) {
    return result;
  }
  if (result == null) {
    showsnackbar(context, 'no image chossen');
  }
}
