import 'package:flutter/material.dart';
import 'package:vora_mobile/homepage.dart';

class Announcemnts extends StatefulWidget {
  const Announcemnts({super.key});

  @override
  State<Announcemnts> createState() => _AnnouncemntsState();
}

class _AnnouncemntsState extends State<Announcemnts> {
  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Homepage()));
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
    ));
  }
}
