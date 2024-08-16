//snackbar
import 'dart:math';

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
String period(DateTime time){
 Duration duration = time.difference(DateTime.now());
 int days = duration.inDays;
 days = sqrt(days*days).ceil();
 int hrs = duration.inHours;
 hrs = sqrt(hrs*hrs).ceil();
 int sec = duration.inSeconds;
 sec = sqrt(sec*sec).ceil();
  int min = duration.inMinutes;
  min = sqrt(min*min).ceil();
  
bool status = duration.isNegative;
String retrn = "";

 if (hrs> 0 && days<0 ) {
  if (status) {
    retrn = "$hrs h ago";
  }else{
    retrn = "in $hrs h";
  }
   
 }
 if (days>0 ) {
  if (status) {
    retrn = "$days days ago";
  }
   else{
    retrn = "in $days days";
   }
 }
 if (sec>0 && min<0 ) {
  if (status) {
    retrn = "$sec seconds ago";
  }
  else{
    retrn = "in $sec seconds";
  }
 }
 if (min>0 && hrs<0) {
  if (status) {
     retrn = "$min minutes ago";
  }else{
    retrn = "in $min minutes ";
  }
 }
  return retrn;

}