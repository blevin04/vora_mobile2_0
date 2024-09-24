// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vora_mobile/utils.dart';


final firestore_2 = FirebaseFirestore.instance;
final firestorage_2 = FirebaseStorage.instance.ref();
class Dedicatedcommunitypage extends StatefulWidget {
final  String clubId;
 const  Dedicatedcommunitypage({super.key, required this.clubId});

  @override
  State<Dedicatedcommunitypage> createState() => _DedicatedcommunitypageState();
}

class _DedicatedcommunitypageState extends State<Dedicatedcommunitypage> {
Future<Map<String,dynamic>> clubdata()async{
  Map<String,dynamic> cData = {};

  await firestore_2.collection("Communities").doc(widget.clubId).get().then((onValue){
    final comdata = onValue.data()!;
    cData.addAll(comdata);
  });
  await firestorage_2.child("/communities/${widget.clubId}/cover_picture").getData().then((cover){
    final coverImg = <String,dynamic>{"CoverImg":cover!};
    cData.addAll(coverImg);
  });

return cData;
}

Future<String> coName ()async{
  String cName = '';

  await firestore_2.collection("Communities").doc(widget.clubId).get().then((onValue){
    cName = onValue.data()!["Name"];
  });
  return cName;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(onPressed: ()=> Navigator.pop(context), 
        icon:const Icon(Icons.arrow_back,color: Colors.white,size: 22,)),
        title:FutureBuilder(
          future: coName(),
          initialData: "Club",
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            String clubName = snapshot.data.toString();
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(),);
            }
            return Text(clubName,style:const TextStyle(color: Colors.white,fontSize: 20),);
          },
        ),

      ),
      body: RefreshIndicator(
        onRefresh: ()async {
          setState(() {
            
          });
        },
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: clubdata(),
          //  initialData: Map(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(child: Container(),);
              }
              String aboutClub = snapshot.data!["About"];
              Uint8List CoverImg = snapshot.data!["CoverImg"];
              Map<String,dynamic> numbers = snapshot.data!["Numbers"];
              if (snapshot.connectionState==ConnectionState.waiting) {
                return const Center(child:CircularProgressIndicator());
              }
              return Column(
                children: [
                  Container(
                    padding:const EdgeInsets.all(20),
                    child: Image(image: MemoryImage(CoverImg)),
                  ),
                  const SizedBox(height: 10,),
                  const Divider(),
                  Text(aboutClub,style:const TextStyle(color: Colors.white),),
                  const SizedBox(height: 10,),
        
                  ListView.builder(
                    itemCount: numbers.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context,index){
                      List keys_ = numbers.keys.toList(growable: true);
                      final Uri _url = Uri.parse(numbers[keys_[index]]);
                     return ListTile(
                      onTap:()async=> openUrl(_url),
                      contentPadding:const EdgeInsets.all(20),
                      leading: getIcon(keys_[index]),
                      title: Text("Visit ${keys_[index]} page",
                      style:const TextStyle(color: Colors.white),),
                     );
                  })
        
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}