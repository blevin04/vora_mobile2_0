//snackbar
// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'package:vora_mobile/Accounts.dart';

FirebaseFirestore store = FirebaseFirestore.instance;
final storageref = FirebaseStorage.instance.ref();
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
            color:const Color.fromARGB(84, 50, 50, 50),
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
  List<String> communities = List.empty(growable: true);
  await store
      .collection("Communities")
      .where("Visibility", isEqualTo: true)
      .get()
      .then((val) {
    for (var snapshot in val.docs) {
      // print("${snapshot.id} => ${snapshot.data()["Numbers"]}");
      communities.add(snapshot.data()["Name"]);
    }
  });

  return communities;
}

Future getimage(BuildContext context, bool multiple) async {
   Permission.accessMediaLocation.onDeniedCallback(() async {
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

 if (hrs> 0 && days<=0 ) {
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
 if (sec>0 && min<=0 ) {
  if (status) {
    retrn = "$sec seconds ago";
  }
  else{
    retrn = "in $sec seconds";
  }
 }
 if (min>0 && hrs<=0) {
  if (status) {
     retrn = "$min minutes ago";
  }else{
    retrn = "in $min minutes ";
  }
 }

  return retrn;
}

Map<String,Map<String,dynamic>> eventData = {};
//values include but not limited to :
  //EventCoverImage
  //EventTitle
  //EventClub
  //EventDate

Map<String,Map<String,dynamic>> clubData = {};
//values include but not limited to:
  //Club id as the key to the first map
  //Name
  //About
  //Image

Map<String,Map<String,dynamic>> announcementData = {};
Map<String,dynamic> more = {};
List<String> eventIdsEventspage = List.empty(growable: true);
List<String> clubIds = List.empty(growable: true);
List<bool> viewEventComments = List.empty(growable: true);
Map<String,dynamic> userData = {};
//This stores the users data like the 
  ///name
  ///nickname
  ///profile picture
  ///
List<String> homepageEvents = List.empty(growable: true);
Map<String,Map<String,dynamic>> blogsdata = {};
List<String> blogsPageIds = List.empty(growable: true);
//caries the blog data with variables like:


List<bool> commentsOpenBlogPage = List.empty(growable: true);
List<bool> commentsOpenEventsPage = List.empty(growable: true);


Icon getIcon(String name){
  Icon icon_ =const Icon(Icons.group);
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
  List likes;
  List<String> likes_ = List.empty(growable: true);
  try {
     await store.collection("Events").doc(ContentId).get().then((onValue)async{
     likes = onValue.data()!["Likes"];
     
    if (likes.isEmpty) {
      
      likes_.add(user.uid);
    }
    else{
    
      if (likes.contains(user.uid)) {
        likes.remove(user.uid);
       
      }else{
        likes.add(user.uid);
      
      }
      for(var id in likes){
        likes_.add(id);
      }
    }
  });
     Map<String,List<String>> data = {"Likes":likes_};

     eventData[ContentId]!.remove("Likes");
     eventData[ContentId]!.addAll(data);
    bool lik = eventData[ContentId]!["Liked"];
    eventData[ContentId]!.remove("Liked");
    eventData[ContentId]!.addAll({"Liked":!lik});
    await store.collection("Events").doc(ContentId).update(data);
    state = "Success";
  } catch (e) {
    state = e.toString();
  }
  return state;
}
Future<String> comment_(String contentId,String comment)async{
  String state ="Error occured";
Map<String,dynamic> commented = {};
String username = '';
await store.collection("users").doc(user.uid).get().then((name){
username = name.data()!["nickname"];
});
final com = <String,dynamic>{"UserName":username,"TimeStamp":DateTime.now(),"Comment":comment,"Likes":[]};
var uuid =const Uuid().v1();
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
    eventData[contentId]!.update("Comments", (value){commented;});
    await store.collection("Events").doc(contentId).update(acomm);
    state = "Success";
} catch (e) {
  state = e.toString();
}
  
  return state;
}

Future<String> commentpost(String contentId,String comment)async{
  String state ="Error occured";
Map<String,dynamic> commented = {};
String username = '';
await store.collection("users").doc(user.uid).get().then((name){
username = name.data()!["nickname"];
});
final com = <String,dynamic>{"UserName":username,"TimeStamp":DateTime.now(),"Comment":comment,"Likes":[]};
var uuid =const Uuid().v1();
final commentWritten = <String,dynamic>{uuid:com};
try {
  await store.collection("posts").doc(contentId).get().then((onValue){
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
    blogsdata[contentId]!.remove("Comments");
    blogsdata[contentId]!.addAll(acomm);
    await store.collection("posts").doc(contentId).update(acomm);
    state = "Success";
} catch (e) {
  state = e.toString();
}
  return state;
}

Future<String> likePost (String ContentId)async{
  String state = "Error Ocured";
  List likes;
  List<String> likes_ = List.empty(growable: true);
  try {
     await store.collection("posts").doc(ContentId).get().then((onValue)async{
     likes = onValue.data()!["Likes"];
     
    if (likes.isEmpty) {
      
      likes_.add(user.uid);
    }
    else{
    
      if (likes.contains(user.uid)) {
        likes.remove(user.uid);
        
      }else{
        likes.add(user.uid);
        
      }
      for(var id in likes){
        likes_.add(id);
      }
    }
  });
     Map<String,List<String>> data = {"Likes":likes_};
     blogsdata[ContentId]!.remove("Likes");
     blogsdata[ContentId]!.addAll(data);
    bool lik = blogsdata[ContentId]!["Liked"];
    blogsdata[ContentId]!.remove("Liked");
    blogsdata[ContentId]!.addAll({"Liked":!lik});
    await store.collection("posts").doc(ContentId).update(data);
    state = "Success";
  } catch (e) {
    state = e.toString();
  }
  return state;
}


Future<Map<String,dynamic>> getclubdatas (String clubId)async{
  Map<String,dynamic> clubd_ = {};

  await store.collection("Communities").doc(clubId).get().then((onValue){
    clubd_.addAll(onValue.data()!);
  });
  await storageref.child("/communities/$clubId/cover_picture").getData().then((onValue1){
    final cover_pic =<String,dynamic>{"Image":onValue1!};
    clubd_.addAll(cover_pic);
  });
  final Sdata = <String,Map<String,dynamic>>{clubId:clubd_};
  if (!clubData.containsKey(clubId)) {
    clubData.addAll(Sdata);
  }
  return clubd_;
}

///Get events data from database
  Future<Map<String,dynamic>> geteventsData(String eventId)async{
    Map<String,dynamic> even_m = {};
    String comm_id = "";
    await store.collection("Events").doc(eventId).get().then((onValue){
      // final title = <String,dynamic>{"Title":onValue.data()!["Title"]};
     comm_id = onValue.data()!["Community"];
      // final date = <String,dynamic>{"EventDate":onValue.data()!["EventDate"]};
       var likes = onValue.data()!["Likes"];
      // final desc = <String,dynamic>{"Description":onValue.data()!["Description"]};
      even_m.addAll(onValue.data()!);
      Map<String,dynamic> liked = {};
      if (likes.contains(user.uid)){
        liked = {"Liked":true};
      }else{liked = {"Liked":false};}
     // even_m.addAll(title);
     // even_m.addAll(date);
      even_m.addAll(liked);
     // even_m.addAll(desc);
    });
    await store.collection("Communities").doc(comm_id).get().then((comN){
      final comname = <String,dynamic>{"EventClub":comN.data()!["Name"]};
      even_m.addAll(comname);
    });
    await store.collection("Communities").doc(comm_id).get().then((value){
      final comm_name = <String,dynamic>{"Club_Name":value.data()!["Name"]};
    even_m.addAll(comm_name);
    });

    await storageref.child("/communities/$comm_id/cover_picture").getData().then((value1){
      final c_images = <String,dynamic>{"Cover_Image":value1!};
      even_m.addAll(c_images);
    });
    await storageref.child("/events/$eventId/").list().then((onValue1)async{
      List<dynamic> imgs_ =List.empty(growable: true);
      
      for(var val in onValue1.items){
        var path = val.toString().split(":").last;
        path = path.split(")").first;
        path =path.split(":").last;
        path = path.split(" ").last;
       
         await storageref.child(path).getData().then((onValu){
          imgs_.add(onValu!);
        });
      }
      final img_paths = <String,dynamic>{"Images":imgs_};
      even_m.addAll(img_paths);
    });
    if (!eventData.containsKey(eventId)) {
      final curEvent = <String,Map<String,dynamic>>{eventId:even_m};
      eventData.addAll(curEvent);
    }
    return even_m;
  }

//Focus Image
PageView showimage(
  BuildContext context,
  List<dynamic> imgs,
  double hhh,
){
  List<Widget> screens = List.empty(growable: true);
  for(var image in imgs){
    Widget screen = Image(image: MemoryImage(image));
    screens.add(screen);
  }
  return PageView(
    scrollDirection: Axis.horizontal,
    children: screens
    
  );
}
//Like comment
Future<void> likecomment(String content,String contentId,String commentId)async{
  await store.collection(content).doc(contentId).get().then((onValue)async{
   Map<String,dynamic> comment = onValue.data()!["Comments"];
   print(comment);
   print(commentId);
   print(comment[commentId]);
   
   if (comment[commentId]["Likes"].isNotEmpty) {
     comment[commentId]["Likes"].contains(user.uid)?
     comment[commentId]["Likes"].remove(user.uid):
     comment[commentId]["Likes"].add(user.uid);
   }else{
    comment[commentId]["Likes"].add(user.uid);
   }
    final comments = <String,dynamic>{"Comments":comment};
    await store.collection(content).doc(contentId).update(comments);
    print(comment);
  });
  print("success");
  
}

///Launch url
Future<void> openUrl(Uri _url)async{
 if (! await launchUrl(_url)) {
   throw Exception("Could not launch $_url");
 }
}

//Share the post
