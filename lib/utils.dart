//snackbar
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';


import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'package:vora_mobile/Accounts.dart';

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

Map<String,Map<String,dynamic>> eventData = Map();
//values include but not limited to :
  //EventCoverImage
  //EventTitle
  //EventClub
  //EventDate

Map<String,Map<String,dynamic>> clubData = Map();
//values include but not limited to:
  //Club id as the key to the first map
  //Name
  //About
  //Image

Map<String,Map<String,dynamic>> announcementData = Map();
Map<String,dynamic> more = Map();
List<String> eventIdsEventspage = List.empty(growable: true);
List<String> clubIds = List.empty(growable: true);
Map<String,dynamic> userData = Map();
List<String> homepageEvents = List.empty(growable: true);
Map<String,Map<String,dynamic>> blogsdata = Map();
List<String> blogsPageIds = List.empty(growable: true);
//caries the blog data with variables like:



Icon getIcon(String name){
  Icon icon_ = Icon(Icons.group);
  switch (name) {
    case "Instagram":
      icon_ =const Icon(FontAwesomeIcons.instagram,color:  Color.fromARGB(226, 255, 255, 255),);
      
      break;

    case "LinkedIn":
      icon_ =const Icon(FontAwesomeIcons.linkedinIn,color:  Color.fromARGB(226, 255, 255, 255));
      break;

    case "Twitter":
      icon_ =const Icon(FontAwesomeIcons.twitter,color:  Color.fromARGB(226, 255, 255, 255));
      break;
    
    case "Facebook":
      icon_ = const Icon(FontAwesomeIcons.facebook,color:  Color.fromARGB(226, 255, 255, 255));
      break;

    default:
      icon_ = const Icon(Icons.group,color:  Color.fromARGB(226, 255, 255, 255));
      break;
  }

  return icon_;
}

Future<String> likeEvent (String ContentId)async{
  String state = "Error Ocured";
  var likes;
  List<String> likes_ = List.empty(growable: true);
  try {
     await store.collection("Events").doc(ContentId).get().then((onValue)async{
     likes = onValue.data()!["Likes"];
     
    if (likes == null) {
      
      likes_.add(user.uid);
    }
    else{
      List lk = List.empty(growable: true);
      if (likes.contains(user.uid)) {
        likes.remove(user.uid);
        print(likes);
      }else{
        likes.add(user.uid);
        print(likes);
      }
      for(var id in likes){
        likes_.add(id);
      }
    }
  });
     Map<String,List<String>> data = {"Likes":likes_};
    await store.collection("Events").doc(ContentId).update(data);
    state = "Success";
  } catch (e) {
    state = e.toString();
  }
  return state;
}
Future<String> comment_(String contentId,String comment)async{
  String state ="Error occured";
Map<String,dynamic> commented = Map();
String username = '';
await store.collection("users").doc(user.uid).get().then((name){
username = name.data()!["nickname"];
});
final com = <String,dynamic>{"UserName":username,"TimeStamp":DateTime.now(),"Comment":comment,"Likes":[]};
var uuid = Uuid().v1();
final commentWritten = <String,dynamic>{uuid:com};

try {
  await store.collection("Events").doc(contentId).get().then((onValue){
    var coments = onValue.data()!["Comments"];
    if (coments == null) {
      
      commented.addAll(commentWritten);
    }
    else{
      commented = onValue.data()!["Comments"];
      commented.addAll(commentWritten);
       
    }
  });
    final acomm =<String,dynamic>{"Comments":commented};
    await store.collection("Events").doc(contentId).update(acomm);
    state = "Success";
} catch (e) {
  state = e.toString();
}
  
  return state;
}

