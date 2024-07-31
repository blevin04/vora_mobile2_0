import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:vora_mobile/models/models.dart';
import 'package:uuid/uuid.dart';

final firestore = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance.ref();
User user_ = FirebaseAuth.instance.currentUser!;
Future<String> addcommunity(
    {required String name,
    required String lead,
    required Map<String, String> socials,
    required String Email,
    required bool visibility,
    required String cover_pic}) async {
  String state = "some Error occured";
  String communityId = Uuid().v1();
  List<String> eventsIds = List.empty();
  communityModel community = communityModel(
    Lead: lead,
    eventsId: eventsIds,
    name: name,
    Email: Email,
    numbers: socials,
    uid: communityId,
    visibility: visibility,
  );

  try {
    await firestore
        .collection("Communities")
        .doc(communityId)
        .set(community.tojson());
    await storage
        .child("/communities/$communityId/cover_picture")
        .putFile(File(cover_pic));
    state = 'Succes';
  } catch (e) {
    state = e.toString();
  }

  return state;
}

Future<String> AddEvent_(
    {required String title,
    required String description,
    required String community,
    required String image_path,
    required DateTime time,
    required String reg_link,
    String rec_link = '',
    List<String> other_img = const []}) async {
  String state = "Some Error Occured";
  String EventId = const Uuid().v1();
  eventmodel event = eventmodel(
      title: title,
      description: description,
      community: community,
      cover_image: image_path,
      eventdate: time,
      reg_link: reg_link,
      resorce_link: rec_link,
      other_images: other_img,
      Uid: EventId);
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

  return state;
}

Future<String> AddAnnouncement({
  required String title,
  required String description,
  required String community,
  String imagepath = '',
}) async {
  String announcemntId = Uuid().v1();
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

Future<String> Addpost({
  required String desc,
  List<String> images = const [],
  String docs = '',
}) async {
  String state = "Some Error Occured...";
  String postId = Uuid().v1();

  postmodel post = postmodel(
      blog: desc,
      images: images,
      postId: postId,
      UserId: user_.uid,
      posttime: DateTime.now());
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
    state = "Success";
  } catch (e) {
    state = e.toString();
  }

  return state;
}

Future<String> rsvp({
  required String eventId,
}) async {
  String state = "Some Error Occured...";
  rsvpmodel model = rsvpmodel(eventid: eventId);
  try {
    await firestore.collection("users").doc(user_.uid).update(model.tojson());
    state = "Success";
  } catch (e) {
    state = e.toString();
  }

  return state;
}
