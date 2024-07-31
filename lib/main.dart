import 'package:flutter/material.dart';
import 'package:vora_mobile/homepage.dart';
import 'package:vora_mobile/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vora_mobile/utils.dart';

void main() async {
  // Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // initialize app for web

  // initialize app for mobile devices
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyAPveHrKRFX6Yj7szdR_Cvg7Mo5qGcIWRc",
    appId: "1:809694032755:android:50389af14da3a7a8f58b06",
    messagingSenderId: "809694032755",
    projectId: "voramobile-70ba7",
    storageBucket: "voramobile-70ba7.appspot.com",
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return const Homepage();
          } else if (snapshot.hasError) {
            return showsnackbar(context, "${snapshot.error}");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Login();
        },
      ),
    );
  }
}
