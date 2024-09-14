import 'dart:async';

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vora_mobile/dedicated/DedicatedBlogPage.dart';

import 'package:vora_mobile/events.dart';

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

Future<List<String>> blogId()async{
  List<String> ids = List.empty(growable:true);
  firestore.collection("posts").where("UserId", isNotEqualTo: null).get().then((onValue){
    for(var id in onValue.docs){
      ids.add(id.id);
      if (!blogsPageIds.contains(id.id)) {
    blogsPageIds.add(id.id);
  }
    }
  });
  
  return ids;
}

Future<Map<String,dynamic>> getblogdata(String blogid)async{
  Map<String,dynamic> blogdata = Map();
String usern = "";
  await firestore.collection("posts").doc(blogid).get().then((onValue)async{
    blogdata.addAll(onValue.data()!);
    
    usern = onValue.data()!["UserId"];
  await firestore.collection("users").doc(usern).get().then((userd){
    final userna = <String,dynamic>{"UserName":userd.data()!["fullName"]};
    final nname = <String,dynamic>{"NickName":userd.data()!["nickname"]};
    blogdata.addAll(userna);
    blogdata.addAll(nname);
    
  });
  });
  await store3.child("/posts/$blogid/images").list().then((onValue)async{
    List imgsdata = List.empty(growable: true);
    for(var path in onValue.items){
      var val = path.toString().split("/");
      val = val[val.length-1].split(")");
      String dir = val.first;
      
      await store3.child("/posts/$blogid/images/$dir").getData().then((Imgdata){
        imgsdata.add(Imgdata!);
      });
    }
    final imgs = <String,dynamic>{"Images":imgsdata};
   
    blogdata.addAll(imgs);
  });

  await store3.child("posts/$blogid/docs").list().then((doclist)async{
    List docs = List.empty(growable: true);
    for (var doc in doclist.items){
      var val = doc.toString().split("/");
      val = val[val.length-1].split(")");
      String direct = val.first;
      
      await store3.child("posts/$blogid/docs/$direct").getData().then((doc){
        docs.add(doc!);
      });
    }
    final documents = <String,dynamic>{"Documents":docs};
    blogdata.addAll(documents);
  });
  await store3.child("/profile/$usern/dp.png").getData().then((dp){
    final userdp = <String,dynamic>{"UserDp":dp!};
    blogdata.addAll(userdp);
  });
  final blog = <String,Map<String,dynamic>>{blogid:blogdata};
  if (!blogsdata.containsKey(blogid)) {
      blogsdata.addAll(blog);
  }
  
  return blogdata;
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
            onPressed: () => Navigator.pop(context),
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
            blogsPageIds.isEmpty?
            FutureBuilder(
              future: blogId(),
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
                    itemCount: snapshot.data.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, postnum) {  
                      return Card(
                        color: const Color.fromARGB(255, 49, 47, 47),
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: 
                          (context)=>const Dedicatedblogpage())),
                          child: Container(
                            constraints:const BoxConstraints(minHeight: 200),
                            child: contents(snapshot.data![postnum])
                          ),
                        ),
                      );
                    });
              },
            ):ListView.builder(
                    shrinkWrap: true,
                    itemCount: blogsPageIds.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, postnum) {  
                      return Card(
                        color: const Color.fromARGB(255, 49, 47, 47),
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: 
                          (context)=>const Dedicatedblogpage())),
                          child: Container(
                            constraints:const BoxConstraints(minHeight: 200),
                            child: contents(blogsPageIds[postnum])
                          ),
                        ),
                      );
                    }),
          ],
        ),
      ),
    ));
  }
}

Widget contents(
  String blodsid
){
  return 
  blogsdata[blodsid] == null?
  FutureBuilder(
                              future: getblogdata( blodsid),
                              builder:
                                  (BuildContext context, AsyncSnapshot snapshot2) {
                            
                                    if (snapshot2.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator(),);
                                    }
                                    if (!snapshot2.hasData) {
                                      return const Center(child: Text("error"),);
                                    }
                                    if (snapshot2.connectionState == ConnectionState.none) {
                                      return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                    }
                                   
                                    String names_ = snapshot2.data["UserName"];
                                   
                                    String n_name = snapshot2.data["NickName"];
                                    print(n_name);
                                    DateTime postTime = snapshot2.data["PostTime"].toDate();
                                    
                                    String blogPost = snapshot2.data["BlogPost"];
                                    print(blogPost);
                                    List<dynamic> images_ = snapshot2.data["Images"];
                                    List document = snapshot2.data["Documents"];
                                    
                                    Uint8List UserDp = snapshot2.data["UserDp"];
                                    
                                    String time = period(postTime);
                                    
                                return Column(
                                  children: [
                                    Container(
                                      height: 50,
                                      child: Row(
                                        children: [
                                           Padding(
                                            padding:const EdgeInsets.all(5),
                                            
                                            child: CircleAvatar(
                                              backgroundImage:
                                                  MemoryImage(UserDp),
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
                                     Container(
                                      height: 70,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("This here is the first comment...",style: TextStyle(color: Colors.white,),maxLines: 2,
                                          overflow: TextOverflow.fade,
                                          ),
                                          Row(
                                            children: [
                                              StatefulBuilder(
                                                builder: (BuildContext context, setStatelike) {
                                                  return Badge(
                                                    backgroundColor: Colors.transparent,
                                                    
                                                    textStyle: TextStyle(color: Colors.white),
                                                    
                                                  child: IconButton(onPressed: (){}, icon:const Icon(Icons.thumb_up,color: Colors.blue,)),
                                                );
                                                },
                                              ),
                                              StatefulBuilder(
                                                builder: (BuildContext context, setStatecom) {
                                                  return Badge(
                                                    backgroundColor: Colors.transparent,
                                                    label: Container(color: Colors.transparent,),
                                                    textStyle:const TextStyle(color: Color.fromARGB(255, 21, 1, 66)),
                                                    child: IconButton(onPressed: (){}, icon:const Icon(Icons.comment))
                                                    );
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              },
                            )
                            :Builder(
                              builder: (context) {
                                 String names_ = blogsdata[blodsid]!["UserName"];
                                    String n_name = blogsdata[blodsid]!["NickName"];
                                    DateTime postTime = blogsdata[blodsid]!["PostTime"].toDate();
                                    String blogPost = blogsdata[blodsid]!["BlogPost"];
                                    List<dynamic> images_ = blogsdata[blodsid]!["Images"];
                                   List document = blogsdata[blodsid]!["Documents"];
                                    Uint8List UserDp = blogsdata[blodsid]!["UserDp"];
                                    String time = period(postTime);
                                return Column(
                                      children: [
                                        Container(
                                          height: 50,
                                          child: Row(
                                            children: [
                                               Padding(
                                                padding:const EdgeInsets.all(5),
                                                child: CircleAvatar(
                                                  backgroundImage: MemoryImage(UserDp),
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
                                        Container(
                                      height: 70,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("This here is the first comment...",style: TextStyle(color: Colors.white,),maxLines: 2,
                                          overflow: TextOverflow.fade,
                                          ),
                                          Row(
                                            children: [
                                              StatefulBuilder(
                                                builder: (BuildContext context, setStatelike) {
                                                  return Badge(
                                                    backgroundColor: Colors.transparent,
                                                  child: IconButton(onPressed: (){}, icon:const Icon(Icons.thumb_up,color: Colors.blue,)),
                                                );
                                                },
                                              ),
                                              StatefulBuilder(
                                                builder: (BuildContext context, setStatecom) {
                                                  return Badge(
                                                    backgroundColor: Colors.transparent,
                                                    label: Container(color: Colors.transparent,),
                                                    textStyle:const TextStyle(color: Color.fromARGB(255, 21, 1, 66)),
                                                    child: IconButton(onPressed: (){}, icon:const Icon(Icons.comment))
                                                    );
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                        
                                      ],
                                    );
                              }
                            );
}