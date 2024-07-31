//import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';
//import 'package:flutter/material.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vora_mobile/models/models.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

AssetImage img = AssetImage("lib/assets/Default_Profile_Picture.png");

Future<File> getLocalFileFromAsset(String assetPath, String fileName) async {
  // Load the asset
  final byteData = await rootBundle.load(assetPath);

  // Get the local path
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');

  // Write the file
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  return file;
}

final _storage = FirebaseStorage.instance.ref();

class AuthMethods {
  // firebase
  final FirebaseAuth _auth = FirebaseAuth.instance; // auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // firestore

  // create user account
  Future<String> createAccount({
    required String email,
    required String password,
    required String fullName,
    required String nickname,
    required String title,
  }) async {
    // final root = await getApplicationDocumentsDirectory();
    String res = "Some error occured!";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          fullName.isNotEmpty &&
          title.isNotEmpty &&
          nickname.isNotEmpty) {
        // create a user with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        // unique id for the user
        final userId = cred.user!.uid;

        // user model
        UserModel user = UserModel(
            fullName: fullName,
            email: email,
            title: title,
            nickname: nickname,
            uid: userId);

        //send data to cloud firestore
        await _firestore.collection("users").doc(userId).set(user.toJson());
        await adddp(userId);
        res = "success";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //sign in
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    String res = "Some error occured!";
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // reset password
  Future<String> resetPassword({required String email}) async {
    String res = "Please try again later";
    try {
      // send the verification link to the user
      await _auth.sendPasswordResetEmail(email: email);

      res = "success";
    } catch (e) {
      res = e.toString();
    }

    return res;
  }
}

Future<void> adddp(
  String userId,
) async {
  final path = await getLocalFileFromAsset("lib/assets/dp.png", 'dp.png');
  //File img = await File(path.path).create();
  await _storage.child("/profile/$userId/dp.png").putFile(File(path.path));
}

Future<void> deleteStaff() async {}
