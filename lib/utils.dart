//snackbar
// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:math';
import 'dart:typed_data';

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
    bool member = false;
  await store.collection("users").doc(user.uid).get().then((userd){
      member = userd.data()!["Communities"].contains(clubId);
  });
  final memberstatus = <String,dynamic>{"Member":member};
  clubd_.addAll(memberstatus);
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

//Mark announcement as read
Future<String>markAsRead([String announcementId = "",bool all = false])async{
  String state = "";
  try {
      if (all) {
    List announceCommunities = userData["Communities"];
    List commnames = [];
    for(var com in announceCommunities){
      await store.collection("Communities").doc(com).get().then((on){
        commnames.add(on.data()!["Name"]);
      });
    }
    for(var id in commnames){
      await store.collection("Announcements").where("Community",isEqualTo: id).get().then((onValue)async{
        for(var announcement1 in onValue.docs){
          List viewed = List.empty(growable: true);
          await store.collection("Announcements").doc(announcement1.id).get().then((announcedata){
             viewed = announcedata.data()!["Viewed"];
            viewed.add(user.uid);
          });
          await store.collection("Announcements").doc(announcement1.id).update({"Viewed":viewed});
        }
      });
    }
  }else{
    List viewed = List.empty(growable: true);
    await store.collection("Announcements").doc(announcementId).get().then((onValue){
       viewed = onValue.data()!["Viewed"];
      viewed.add(user.uid);
    });
    await store.collection("Announcements").doc(announcementId).update({"Viewed":viewed});
  }
  state = "Success";
  } catch (e) {
    state = e.toString();
  }
  return state;
}
//Get the number of unread announcements
Future<int>getannouncementnumber()async{
int announcenum = 0;
  List commsSubscribed = userData["Communities"];
  List comnames = List.empty(growable: true);
  for(var com in commsSubscribed){
    await store.collection("Communities").doc(com).get().then((onValue){
      comnames.add(onValue.data()!["Name"]);
    });
  }
  for(var comname in comnames){
    await store.collection("Announcements").where("Community", isEqualTo: comname).get().then((announcemntss)async{

      for(var ann in announcemntss.docs){
        await store.collection("Announcements").doc(ann.id).get().then((anndata){
          if (!anndata.data()!["Viewed"].contains(user.uid)) {
            announcenum +=1;
          }
        });
      }

    }); 
  }
return announcenum;
}


//Delete data
Future<String> deletedata(String postId)async{
  String state = "";
  print(postId);
  try {
     await store.collection("posts").doc(postId).delete();
    final pathsdocs = storageref.child("posts/$postId/docs");
    final pathimgs = storageref.child("posts/$postId/images");
    pathsdocs.listAll().then((onValue){
      onValue.items.forEach((item){
        item.delete();
      });
    });
    pathimgs.listAll().then((onValue){
      onValue.items.forEach((item){
        item.delete();
      });
    });
    state = "Success";
  } catch (e) {
   // state = e.toString();
  }
  print("tattatatat = $state");
  return state;
}


//Get the blog data
Future<Map<String,dynamic>> getblogdatautil(String blogid)async{
  Map<String,dynamic> blogdata = Map();
String usern = "";
  await store.collection("posts").doc(blogid).get().then((onValue)async{
    blogdata.addAll(onValue.data()!);
    List likesall = onValue.data()!["Likes"];
     Map<String,dynamic> comAll = onValue.data()!["Comments"];
     Map<String,dynamic> comED = Map();
     comAll.forEach((k, v){
      if (v.containsValue(user.uid)) {
        comED = {"Commented":true};
        
      }else{
       
        if(comED.isEmpty){
          comED = {"Commented":false};
         
        }
      }
     });
     if (comAll.isEmpty) {
       comED = {"Commented":false};
     }
    Map<String,dynamic> likeD = {};
    if (likesall.contains(user.uid)) {
      likeD = {"Liked":true};
    }else{
      likeD = {"Liked":false};
    }
    
    usern = onValue.data()!["UserId"];
  await store.collection("users").doc(usern).get().then((userd){
    final userna = <String,dynamic>{"UserName":userd.data()!["fullName"]};
    final nname = <String,dynamic>{"NickName":userd.data()!["nickname"]};
    blogdata.addAll(userna);
    blogdata.addAll(nname);
    blogdata.addAll(likeD);
    blogdata.addAll(comED);
    
  });
  });
  await storageref.child("/posts/$blogid/images").list().then((onValue)async{
    List imgsdata = List.empty(growable: true);
    for(var path in onValue.items){
      var val = path.toString().split("/");
      val = val[val.length-1].split(")");
      String dir = val.first;
      
      await storageref.child("/posts/$blogid/images/$dir").getData().then((Imgdata){
        imgsdata.add(Imgdata!);
      });
    }
    final imgs = <String,dynamic>{"Images":imgsdata};
   
    blogdata.addAll(imgs);
  });

  await storageref.child("posts/$blogid/docs").list().then((doclist)async{
    List docs = List.empty(growable: true);
    for (var doc in doclist.items){
      var val = doc.toString().split("/");
      val = val[val.length-1].split(")");
      String direct = val.first;
      
      await storageref.child("posts/$blogid/docs/$direct").getData().then((doc){
        docs.add(doc!);
      });
    }
    final documents = <String,dynamic>{"Documents":docs};
    blogdata.addAll(documents);
  });
  await storageref.child("/profile/$usern/dp.png").getData().then((dp){
    final userdp = <String,dynamic>{"UserDp":dp!};
    blogdata.addAll(userdp);
  });
  final blog = <String,Map<String,dynamic>>{blogid:blogdata};
  if (!blogsdata.containsKey(blogid)) {
      blogsdata.addAll(blog);
  }
  return blogdata;
}

bool checkevent(String eventid1){
  bool state = true;
  if (eventData[eventid1] == null) {
    state = false;
  }

if (state) {
  Map<String,dynamic> checkmap = {
    "Comments":{},
    "Community":"com",
    "Description":"desc",
    "EventDate":Timestamp.now(),
    "Likes":[],
    "Regestration":"reg",
    "Resorces":"res",
    "Title":"title",
    "Uid":"uniq",
    "EventCover": Uint8List,
    "Images":[],
    "Liked":false,
    "Cover_Image":Uint8List,

  };
    checkmap.forEach((key,value){
    if (!eventData[eventid1]!.containsKey(key)) {
      state = false;
    }
  });
}
  return state;
}

bool checkClubdata(String clubid1){
  bool state = true;
  if (clubData[clubid1]==null) {
    state = false;
  }

  if (state) {
      Map<String,dynamic> checkmap = {
    "About":"abo",
    "Category":[],
    "Email":"em",
    "Lead":"lead",
    "Name":"nm",
    "Numbers":{},
    "Uid":"uniq",
    "Visibility":true,
    "events":[],
    "Image":Uint8List,
    "Member":true,
  };
      checkmap.forEach((key,value){
    if (!clubData[clubid1]!.containsKey(key)) {
      state = false;
    }
  });
  }
  return state;
}

bool checkpostdata(String postid1){
  bool state =true;
  if (blogsdata[postid1]==null) {
    state = false;
  }

  if (state) {
    
    Map<String,dynamic> checkpost = {
      "BlogPost":"pos",
      "Comments":{},
      "Likes":[],
      "PostId":"pos",
      "PostTime":Timestamp.now(),
      "Title":"ttl",
      "UserId":"nciq",
      "Images":[],
      "UserName":"dd",
      "NickName":"wd",
      "UserDp":Uint8List,
      "Documents":[],
    };

    checkpost.forEach((key,value){
      if (!blogsdata[postid1]!.containsKey(key)) {
        state = false;
      }
    });
  }
  return state;
}

//delete a club:
Future<String> deleteclub(String clubid2)async{
  String state = "";
  print(clubid2);
  try {
     await store.collection("Communities").doc(clubid2).delete();
   
    final pathimgs = storageref.child("communities/$clubid2/covercover_picture").delete();
    state = "Success";
    clubData.remove(clubid2);
  } catch (e) {
   // state = e.toString();
  }
  print("tattatatat = $state");
  return state;
}
