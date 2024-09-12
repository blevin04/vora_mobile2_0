import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vora_mobile/utils.dart';


final firestore_2 = FirebaseFirestore.instance;
final firestorage_2 = FirebaseStorage.instance.ref();
class Dedicatedcommunitypage extends StatelessWidget {
final  String clubId;
 const  Dedicatedcommunitypage({super.key, required this.clubId});

Future<Map<String,dynamic>> clubdata()async{
  Map<String,dynamic> Cdata = Map();

  await firestore_2.collection("Communities").doc(clubId).get().then((onValue){
    final comdata = onValue.data()!;
    Cdata.addAll(comdata);
  });
  await firestorage_2.child("/communities/$clubId/cover_picture").getData().then((cover){
    final CoverImg = <String,dynamic>{"CoverImg":cover!};
    Cdata.addAll(CoverImg);
  });

return Cdata;
}
Future<String> CoName ()async{
  String Cname = '';

  await firestore_2.collection("Communities").doc(clubId).get().then((onValue){
    Cname = onValue.data()!["Name"];
  });
  return Cname;
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
          future: CoName(),
          initialData: "Club",
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            String ClubName = snapshot.data.toString();
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(),);
            }
            return Text(ClubName,style:const TextStyle(color: Colors.white,fontSize: 20),);
          },
        ),

      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: clubdata(),
          initialData: "Error",
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            String aboutClub = snapshot.data!["About"];
            Uint8List CoverImg = snapshot.data!["CoverImg"];
            List<String> numbers = snapshot.data!["Numbers"];
            if (snapshot.connectionState==ConnectionState.waiting) {
              return const Center(child:CircularProgressIndicator());
            }
            return Column(
              children: [
                Container(
                  padding:const EdgeInsets.all(20),
                  child: Image(image: MemoryImage(CoverImg)),
                ),
                const SizedBox(height: 20,),
                const Divider(),
                Text(aboutClub,style:const TextStyle(color: Colors.white),),
                const SizedBox(height: 10,),
                ListView.builder(
                  itemCount: numbers.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context,index){
                   return ListTile(
                    contentPadding:const EdgeInsets.all(20),
                    leading: getIcon(numbers[index]),
                    title: Text(numbers[index],style:const TextStyle(color: Colors.white),),
                   );
                })

              ],
            );
          },
        ),
      ),
    );
  }
}