// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vora_mobile/Accounts.dart';
import 'package:vora_mobile/firebase_Resources/add_content.dart';
import 'package:vora_mobile/homepage.dart';
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
  try {
      await firestore_2.collection("Communities").doc(widget.clubId).get().then((onValue){
    final comdata = onValue.data()!;
    cData.addAll(comdata);
  });
  await firestorage_2.child("/communities/${widget.clubId}/cover_picture").getData().then((cover){
    final coverImg = <String,dynamic>{"CoverImg":cover!};
    cData.addAll(coverImg);
  });
  } catch (e) {
    print(e.toString());
  }

return cData;
}
Future<String> coName ()async{
  String cName = '';

  if (clubData[widget.clubId] == null) {
   await getclubdatas(widget.clubId);
   // await Future.delayed(const Duration(seconds: 2));
    print("doneee");
  }
  try {
      await firestore_2.collection("Communities").doc(widget.clubId).get().then((onValue){

    cName = onValue.data()!["Name"];
  });
  } catch (e) {
    print(e.toString());
  }

  return cName;
}
Future<String> elsee()async{
  await Future.delayed(const Duration(seconds: 1));
  return "okk";
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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(),);
            }
            if(!snapshot.hasData || !snapshot.data.isNotEmpty){
              print("emptyyyyyyyy");
              return const Text("club",style: TextStyle(color: Colors.white,fontSize: 20),);
            }
            String clubName = snapshot.data;
            //print("club name = $clubName");
            return Text(clubName,style:const TextStyle(color: Colors.white,fontSize: 20),);
          },
        ),
        actions: [
          FutureBuilder(
            future: !checkClubdata(widget.clubId)? getclubdatas(widget.clubId):elsee(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (!snapshot.hasData) {
                print("okkkok");
                return Container();
              }
              return TextButton(
            onPressed: ()async{
            // print(widget.clubId);
            // print(clubData.keys.toList());
          String state = await joinleave(communId: widget.clubId);
           
          if(state == "Success"){
            setState(() {
              clubData[widget.clubId]!["Member"] = !clubData[widget.clubId]!["Member"];
            });
            //showsnackbar(context, "Welcome to ${clubData["Name"]}");
          }
          }, 
          child: Container(
            padding:const EdgeInsets.all(10),
            width: 70,
            decoration: BoxDecoration(
              color:clubData[widget.clubId]!["Member"]? Colors.grey:Colors.lightBlue,borderRadius: BorderRadius.circular(10)),
            child: Center(child: 
            clubData[widget.clubId]!["Lead"] != user.uid?
             Text(clubData[widget.clubId]!["Member"]?"Leave":"Join",
             style:const TextStyle(color: Colors.white),)
             :IconButton(onPressed: ()async{
             String state = await deleteclub(widget.clubId);
              if(state == "Success"){
                Navigator.pop(context);
              }
             }, icon:const Icon(Icons.delete_sharp,color: Colors.white,))
             )
             
             ,
          ));
            },
          ),
          
        ],

      ),
      body: RefreshIndicator(
        onRefresh: ()async {
          setState(() {});
        },
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: clubdata(),
          //  initialData: Map(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
             
              if (snapshot.connectionState==ConnectionState.waiting) {
                return  Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: const Color.fromARGB(177, 91, 88, 88)),
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  child:const Center(child:CircularProgressIndicator()),
                );
              }
               if (!snapshot.hasData || !snapshot.data.isNotEmpty) {
                print("emptyheeeerrrr");
                return Center(child: Container(),);
              }
              
               String aboutClub = snapshot.data!["About"];
              Uint8List CoverImg = snapshot.data!["CoverImg"];
              Map<String,dynamic> numbers = snapshot.data!["Numbers"];
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