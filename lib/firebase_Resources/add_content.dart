// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vora_mobile/Accounts.dart';

import 'package:vora_mobile/models/models.dart';
import 'package:uuid/uuid.dart';
import 'package:vora_mobile/utils.dart';

final firestore = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance.ref();
User user_ = FirebaseAuth.instance.currentUser!;
Future<List<String>> addcommunity(
    {required String name,
    
    required Map<String, String> socials,
    required String Email,
    required bool visibility,
    required List<String> categories,
    required String aboutclub,
    required String cover_pic}) async {
  String state = "some Error occured";
  String communityId =const Uuid().v1();
  List<String> eventsIds = List.empty();
  communityModel community = communityModel(
    Lead: user.uid,
    eventsId: eventsIds,
    name: name,
    Email: Email,
    numbers: socials,
    uid: communityId,
    visibility: visibility,
    category: categories,
    about: aboutclub,
  );

  try {
    await firestore
        .collection("Communities")
        .doc(communityId)
        .set(community.tojson());
    await storage
        .child("/communities/$communityId/cover_picture")
        .putFile(File(cover_pic));
    state = 'Success';

    
  } catch (e) {
    state = e.toString();
  }
  List<String> statuss = [state,communityId];
  return statuss;
}

Future<List<String>> AddEvent_(
    {required String title,
    required String description,
    required String community,
    required String image_path,
    required DateTime time,
    required String reg_link,
    String rec_link = '',
    List<String> other_img = const []}) async {
      String communityIdn = "";
      await firestore.collection("Communities").where("Name",isEqualTo: community).get().then((onValue){
        for(var id in onValue.docs){
          communityIdn = id.id;
        }
      });

  String state = "Some Error Occured";
  String EventId = const Uuid().v1();
  Map<String,dynamic> comms ={};
  eventmodel event = eventmodel(
      title: title,
      description: description,
      community: communityIdn,
      cover_image: image_path,
      eventdate: time,
      reg_link: reg_link,
      resorce_link: rec_link,
      other_images: other_img,
      Uid: EventId,
      Likes: List.empty(growable: true),
      comments: comms,
      );
  try {
    await firestore.collection("Events").doc(EventId).set(event.toJson());
    await storage.child("/events/$EventId/cover").putFile(File(image_path));
    for (var i = 0; i < other_img.length; i++) {
      var names = other_img[i].split("/");
      String name = names[names.length - 1];
      await storage.child("/events/$EventId/$name").putFile(File(other_img[i]));

      state = "Success";
    }
  } catch (e) {
    state = e.toString();
  }
  List<String> statuss = [state,EventId];
  return statuss;
}

Future<String> AddAnnouncement({
  required String title,
  required String description,
  required String community,
  String imagepath = '',
}) async {
  String announcemntId =const Uuid().v1();
  announcementModel announcement = announcementModel(
      UserId: user_.uid,
      announceTime: DateTime.now(),
      ImagePath: imagepath,
      community: community,
      description: description,
      title: title,
      AnnouncentId: announcemntId);

  String state = 'Some Error Occured...';

  try {
    await firestore
        .collection("Announcements")
        .doc(announcemntId)
        .set(announcement.tojson());
    if (imagepath.isNotEmpty) {
      await storage
          .child("/announcemnts/$announcemntId/img")
          .putFile(File(imagepath));
    }

    state = "success";
  } catch (e) {
    state = e.toString();
  }

  return state;
}

Future<List> Addpost({
  required String desc,
  List<String> images = const [],
  String docs = '',
  required String title,
}) async {
  List state = ["Some Error Occured..."];
  String postId =const Uuid().v1();

  postmodel post = postmodel(
      blog: desc,
      images: images,
      postId: postId,
      UserId: user_.uid,
      posttime: DateTime.now(),
      title: title,
      Likes: List.empty(growable: true),
      comments_: {},
      );
  try {
    await firestore.collection("posts").doc(postId).set(post.tojson());
    if (images.isNotEmpty) {
      for (var i = 0; i < images.length; i++) {
        var names = images[i].split("/");
        String name = names[names.length - 1];
        await storage
            .child("/posts/$postId/images/$name")
            .putFile(File(images[i]));
      }
    }
    if (docs.isNotEmpty) {
      await storage.child("/posts/$postId/docs/doc1").putFile(File(docs));
    }
    state[0] = "Success";
  } catch (e) {
    state[0] = e.toString();
  }
  state.add(postId);
  return state;
}

Future<String> rsvp({
  required String eventId,
}) async {
  String state = "Some Error Occured...";

  try {
      List<String> original = List.empty(growable: true);
  await firestore.collection("users").doc(user_.uid).get().then((val){
    var d = val.data()!["Events"];
    print(d);
    for(var x in d){
      original.add(x);
    }
  });
  if (!original.contains(eventId)) {
    original.add(eventId);
  }
  rsvpmodel model = rsvpmodel(rsvps: original);
    await firestore.collection("users").doc(user_.uid).update(model.tojson());
    state = "Success";
  } catch (e) {
    state = e.toString();
  }

  return state;
}
Future<String> joinleave({
  required String communId,

})async{
  String state = "Some Error occured...";
  try{
    List<String> origin = List.empty(growable: true);
    await firestore.collection("users").doc(user_.uid).get().then((onValue){
      var nums_ = onValue.data()!["Communities"];
      for(var ids in nums_){
        origin.add(ids);
      }
    });
    if (!origin.contains(communId)) {
      origin.add(communId);
    }else{
      origin.remove(communId);
    }
    
    joincomModel joins = joincomModel(comm: origin);
    await firestore.collection("users").doc(user_.uid).update(joins.tojson());
    state = "Success";
    clubData[communId]!["Member"] = true;

  }
  catch(e){
    state = e.toString();
  }
  print(clubData[communId]!["Member"]);
  return state;
}