import 'package:flutter/material.dart';

class Dedicatedblogpage extends StatelessWidget {
  const Dedicatedblogpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(onPressed: ()async=> Navigator.pop, 
        icon:const Icon(Icons.arrow_back,color: Colors.white,)),
        title:const Text("Blog Title",style: TextStyle(color: Colors.white),),

      ),
      body: Column(),
    );
  }
}