import 'dart:async';

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:vora_mobile/events.dart';
import 'package:vora_mobile/homepage.dart';
import 'package:vora_mobile/utils.dart';

final store3 = FirebaseStorage.instance.ref();
final firestore = FirebaseFirestore.instance;

class Blogs extends StatefulWidget {
  const Blogs({super.key});

  @override
  State<Blogs> createState() => _BlogsState();
}
 var name;
                      Duration posttime = Duration();
                      String name_ = '';
                      String nick_name = '';
Widget blog_show = Text("Blogs");
TextEditingController search_blogs = TextEditingController();
List<String> blogIds = List.empty(growable: true);
bool _blogs_visi = false;
String postdata = '';
String timedif(Duration t){
  String tm ='';
  if (t.inSeconds>=60) {
    tm= t.inMinutes.toString();
  }
  if (t.inMinutes >=60) {
    tm = t.inHours.toString();
  }
  if (t.inHours >= 24) {
    tm = t.inDays.toString();

  }
  if (t.inDays >= 30) {
    tm = "> month";
  }
  return tm;

}

Future<Map<String,dynamic>> resolve( int postnum)async{

Map<String,dynamic> data =Map();
  await firestore
                          .collection("posts")
                          .doc(blogIds[postnum])
                          .get()
                          .then((onval)async {
                        name = onval.data()!["UserId"];
                        var then = onval.data()!["PostTime"].toDate();
                        
                      
                      final postd = <String, dynamic>{"BlogPost":onval.data()!["BlogPost"]};
                      final t = <String,dynamic>{"PostTime":then};
                      
                      data.addAll(postd);
                      data.addAll(t);
                      
                      await  firestore
                            .collection("users")
                            .doc(name)
                            .get()
                            .then((onValue) {
                          
                          final names = <String,dynamic>{"UserName":onValue.data()!["fullName"]};
                          final n_name = <String,dynamic>{"nick_name": onValue.data()!["nickname"]};
                          
                        data.addAll(names);
                        data.addAll(n_name);
                        });
                      });
        await store3.child("/posts/${blogIds[postnum]}/images").list().then((onValue)async{
          List<Uint8List> imgs = List.empty(growable: true);
          for(var val in onValue.items){
            var path = val.toString().split("/");
            path = path[path.length-1].split(")");
            String dir = path[0];
            await store3.child("/posts/${blogIds[postnum]}/images/$dir").getData().then((value){
              imgs.add(value!);
            });
          }

       //   print(onValue.items);
          final images = <String,dynamic>{"Images":imgs};
          data.addAll(images);

        });
        await store3.child("/posts/${blogIds[postnum]}/docs").list().then((doc)async{
        var path = doc.items.toString().split("/")[doc.items.toString().split("/").length-1];
        path = path.split(")")[0];
        await store3.child("/posts/${blogIds[postnum]}/docs/$path").getData().then((document){
            final docs =<String,dynamic>{"Document":document!};
            data.addAll(docs);
        });
          
        });
                      return data;

}
ValueNotifier<bool> visible_Search = ValueNotifier(false);
Future<String> getblogsid() async {
  blogIds.clear();

  await firestore
      .collection("posts")
      .where("PostId", isNotEqualTo: null)
      .get()
      .then((onValue) {
    for (var id in onValue.docs) {
      blogIds.add(id["PostId"]);
    }
  });
  return "ok";
}

late ListResult imgsdir;
Future<Map<String,dynamic>> getpostimg(int index) async {
  Map<String,dynamic> dat = Map();
  imgsdir = await store3.child("/posts/${blogIds[index]}").list();
 dat = await resolve(index);
  return dat;
}

class _BlogsState extends State<Blogs> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    //  double _height = MediaQuery.of(context).size.height;
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
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Homepage())),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: const Text(
          "Blogs & Articles",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () {
                
                  events_vis = !events_vis;
                visible_Search.value = !visible_Search.value;
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListenableBuilder(
              listenable: visible_Search,
              builder: (context,child) {
                return Visibility(
                  visible: events_vis,
                  child: Container(
                    width: _width - 100,
                    alignment: Alignment.center,
                    height: 50,
                    child: TextField(
                      controller: search_blogs,
                      decoration: const InputDecoration(
                          label: Icon(
                        Icons.search,
                        color: Colors.white,
                      )),
                    ),
                  ),
                );
              }
            ),
            
            FutureBuilder(
              future: getblogsid(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(),);
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(),);
                }
                if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: blogIds.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, postnum) {
                      print(blogIds.length);
                        // postdata ='';
                        //   name_ = '';
                        //   nick_name = '';
                        //   posttime =Duration.zero;
                        
                      return Card(
                        color: const Color.fromARGB(255, 49, 47, 47),
                        child: Container(
                          constraints:const BoxConstraints(minHeight: 200),
                          child: FutureBuilder(
                            future: getpostimg(postnum),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                          
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator(),);
                                  }
                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator(),);
                                  }
                                  if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                                 
                                  String names_ = snapshot.data["UserName"];
                                  String n_name = snapshot.data["nick_name"];
                                  DateTime postTime = snapshot.data["PostTime"];
                                  String blogPost = snapshot.data["BlogPost"];
                                  List<Uint8List> images_ = snapshot.data["Images"];
                                  Uint8List document = snapshot.data["Document"];
                                  String time = period(postTime);
                              return Column(
                                children: [
                                  Container(
                                    height: 50,
                                    child: Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(5),
                                          child: CircleAvatar(
                                            backgroundImage:
                                                AssetImage("lib/assets/dp.png"),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                "$n_name @$names_",
                                                style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        189, 255, 255, 255)),
                                              ),
                                              Text(
                                                 time,
                                                style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        174, 255, 255, 255)),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      constraints:const BoxConstraints(maxHeight: 100),
                                      child: Text(blogPost,style:const TextStyle(color: Colors.white),),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 180,
                                    child: GridView.count(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      crossAxisSpacing: 0,
                                      mainAxisSpacing: 1,
                                      crossAxisCount: 2,
                                      children: List.generate(images_.length, (imageindex){
                                        return Center(child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Container(
                                                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                                                             
                                                                              child: GridTile(
                                                                                child: Image.memory(fit: BoxFit.cover,images_[0]))
                                                                            ),
                                        ),);
                                      })
                                    ),
                                  ),
                                  
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    });
              },
            ),
          ],
        ),
      ),
    ));
  }
}
