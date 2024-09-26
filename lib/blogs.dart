// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vora_mobile/Accounts.dart';

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

Duration posttime =const Duration();
String name_ = '';
String nick_name = '';
Widget blog_show =const Text("Blogs");
TextEditingController search_blogs = TextEditingController();
List<String> blogIds = List.empty(growable: true);

String postdata = '';

Future<List<String>> blogId()async{
  List<String> ids = List.empty(growable:true);
  commentsOpenBlogPage.clear();

 await firestore.collection("posts").where("UserId", isNotEqualTo: null).get().then((onValue){
    for(var id in onValue.docs){
      ids.add(id.id);
     
      if (!blogsPageIds.contains(id.id)) {
    blogsPageIds.add(id.id);
  }
    }
  });
    for (var i = 0; i < ids.length; i++) {
    commentsOpenBlogPage.add(false);
    
  }
  return ids;
}
TextEditingController BlogcommentText = TextEditingController();
Future<Map<String,dynamic>> getblogdata(String blogid)async{
  Map<String,dynamic> blogdata = Map();
String usern = "";
  await firestore.collection("posts").doc(blogid).get().then((onValue)async{
    blogdata.addAll(onValue.data()!);
    List likesall = onValue.data()!["Likes"];
     Map<String,dynamic> comAll = onValue.data()!["Comments"];
     Map<String,dynamic> comED = Map();
     comAll.forEach((k, v){
      if (v.containsValue(user.uid)) {
        comED = {"Commented":true};
        
      }else{
       
        if(comED.isEmpty){
          comED = {"Commented":false};
         
        }
      }
     });
     if (comAll.isEmpty) {
       comED = {"Commented":false};
     }
    Map<String,dynamic> likeD = {};
    if (likesall.contains(user.uid)) {
      likeD = {"Liked":true};
    }else{
      likeD = {"Liked":false};
    }
    
    usern = onValue.data()!["UserId"];
  await firestore.collection("users").doc(usern).get().then((userd){
    final userna = <String,dynamic>{"UserName":userd.data()!["fullName"]};
    final nname = <String,dynamic>{"NickName":userd.data()!["nickname"]};
    blogdata.addAll(userna);
    blogdata.addAll(nname);
    blogdata.addAll(likeD);
    blogdata.addAll(comED);
    
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


// Future<Map<String,dynamic>> resolve( int postnum)async{

// Map<String,dynamic> data =Map();
//   await firestore
//                           .collection("posts")
//                           .doc(blogIds[postnum])
//                           .get()
//                           .then((onval)async {
//                         name = onval.data()!["UserId"];
//                         var then = onval.data()!["PostTime"].toDate();
                        
                      
//                       final postd = <String, dynamic>{"BlogPost":onval.data()!["BlogPost"]};
//                       final t = <String,dynamic>{"PostTime":then};
                      
//                       data.addAll(postd);
//                       data.addAll(t);
                      
//                       await  firestore
//                             .collection("users")
//                             .doc(name)
//                             .get()
//                             .then((onValue) {
                          
//                           final names = <String,dynamic>{"UserName":onValue.data()!["fullName"]};
//                           final n_name = <String,dynamic>{"nick_name": onValue.data()!["nickname"]};
                          
//                         data.addAll(names);
//                         data.addAll(n_name);
//                         });
//                       });
//         await store3.child("/posts/${blogIds[postnum]}/images").list().then((onValue)async{
//           List<Uint8List> imgs = List.empty(growable: true);
//           for(var val in onValue.items){
//             var path = val.toString().split("/");
//             path = path[path.length-1].split(")");
//             String dir = path[0];
//             await store3.child("/posts/${blogIds[postnum]}/images/$dir").getData().then((value){
//               imgs.add(value!);
//             });
//           }

//        //   print(onValue.items);
//           final images = <String,dynamic>{"Images":imgs};
//           data.addAll(images);

//         });
//         await store3.child("/posts/${blogIds[postnum]}/docs").list().then((doc)async{
//         var path = doc.items.toString().split("/")[doc.items.toString().split("/").length-1];
//         path = path.split(")")[0];
//         await store3.child("/posts/${blogIds[postnum]}/docs/$path").getData().then((document){
//             final docs =<String,dynamic>{"Document":document!};
//             data.addAll(docs);
//         });
          
//         });
//                       return data;

// }
ValueNotifier<bool> visible_Search = ValueNotifier(false);
// late ListResult imgsdir;
// Future<Map<String,dynamic>> getpostimg(int index) async {
//   Map<String,dynamic> dat = Map();
//   imgsdir = await store3.child("/posts/${blogIds[index]}").list();
//  dat = await resolve(index);
//   return dat;
// }


class _BlogsState extends State<Blogs> {
  @override
  Widget build(BuildContext context) {
    double windowWidth = MediaQuery.of(context).size.width;
      double windowheight = MediaQuery.of(context).size.height;
      double clubScale = 0.96;
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
      body: RefreshIndicator(
        onRefresh: ()async{
          await blogId();
          setState(() {
            
          });
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListenableBuilder(
                listenable: visible_Search,
                builder: (context,child) {
                  return Visibility(
                    visible: events_vis,
                    child: Container(
                      width: windowWidth - 100,
                      alignment: Alignment.center,
                      height: 50,
                      child: TextField(
                        
                        style:const TextStyle(color: Colors.white),
                        controller: search_blogs,
                        decoration:  InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:const BorderSide(color: Color.fromARGB(151, 255, 255, 255)),
                            borderRadius: BorderRadius.circular(10)
                          ) ,
                            label:const Icon(
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
                    return  SizedBox(
                      height: windowheight-100,
                        child: const Center(child: CircleAvatar(),),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text("An error occured please refresh the page"),);
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
                          color: const Color.fromARGB(112, 49, 47, 47),
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: 
                            (context)=> Dedicatedblogpage(blogId:  snapshot.data![postnum]))),
                            child: Container(
                              constraints:const BoxConstraints(minHeight: 200),
                              child: contents(snapshot.data![postnum],commentsOpenBlogPage[postnum],windowheight,clubScale,postnum)
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
                        // if (commentsOpenBlogPage.length != blogsPageIds.length) {
                        //   commentsOpenBlogPage.clear();
                        //   for (var i = 0; i < blogsPageIds.length; i++) {
                        //     commentsOpenBlogPage.add(false);
                        //   }
                        // }
                        return Card(
                          color: const Color.fromARGB(112, 49, 47, 47),
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: 
                            (context)=> Dedicatedblogpage(blogId: blogsPageIds[postnum],))),
                            child: Container(
                              color:  Colors.transparent,
                              constraints:const BoxConstraints(minHeight: 200),
                              child: contents(blogsPageIds[postnum],commentsOpenBlogPage[postnum],windowheight,clubScale,postnum)
                            ),
                          ),
                        );
                      }),
            ],
          ),
        ),
      ),
    ));
  }
}

Widget contents(
  String blodsid,
  bool commentOpen,
  double windowheight,
  double clubScale,
  int index1,
){
  
  return 
  !checkpostdata(blodsid)?
  FutureBuilder(
    future: getblogdata( blodsid),
    builder:
        (BuildContext context, AsyncSnapshot snapshot2) {
         
          
          if (snapshot2.connectionState == ConnectionState.waiting) {
            return   Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(210, 91, 90, 90),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        height: 180,
                        child:const Center(child:  CircularProgressIndicator(color: Color.fromARGB(202, 33, 66, 227),)),
                        );
          }
          if (!snapshot2.hasData) {
            return const Center(child: Text("error"),);
          }
          if (snapshot2.connectionState == ConnectionState.none) {
            return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
          }
          
          String names_ = snapshot2.data["UserName"];
          
          String n_name = snapshot2.data["NickName"];
          
          DateTime postTime = snapshot2.data["PostTime"].toDate();
          
          String blogPost = snapshot2.data["BlogPost"];
          
          List<dynamic> images_ = snapshot2.data["Images"];
         // List document = snapshot2.data["Documents"];
          
          Uint8List UserDp = snapshot2.data["UserDp"];
          
          String time = period(postTime);
          bool liked =  snapshot2.data["Liked"];
          bool commenteD = snapshot2.data["Commented"];
          Map<String,dynamic> AllComments = snapshot2.data["Comments"];
          int likedNum = snapshot2.data["Likes"].length;
      return Column(
        children: [
          SizedBox(
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
                            child: InkWell(
                              onTap: (){
                                    showDialog(context: context, builder: (context){
                                      return showimage(context, images_, windowheight);
                                    });
                                  },
                              child: Image.memory(fit: BoxFit.cover,images_[0])))
                        ),
                ),);
              })
            ),
          ),
          StatefulBuilder(
            builder: (BuildContext context, setStateintaractive) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:commentOpen? SizedBox(height: 60,
                    width: 160,
                      child: TextField(
                        onTapOutside: (event) => FocusScope.of(context).requestFocus(FocusNode()) ,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:  const BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                            labelText: "Add comment",
                            labelStyle: const TextStyle(
                                color: Color.fromARGB(255, 161, 159, 159))),
                        controller: BlogcommentText,
                          ),
                    ): Text(AllComments.isNotEmpty? AllComments["Comment"].toString():"Be first to comments",style:const TextStyle(color: Colors.white,),maxLines: 2,
                    overflow: TextOverflow.fade,
                    ),
                  ),
                  Visibility(
                    visible: commentOpen,
                    child: IconButton(onPressed: ()async{
                        String state = "";
                    state = await commentpost(blodsid, BlogcommentText.text);
                      if (state == "Success") {
                        BlogcommentText.clear();
                      }
                  
                    }, icon:const Icon(Icons.send,color: Color.fromARGB(211, 255, 255, 255),))),
                  Row(
                    children: [
                      StatefulBuilder(
                        builder: (BuildContext context, setStatelike) {
                          return Row(
                            children: [
                              IconButton(onPressed: ()async{
                                // String state= "";
                  
                               // state = await likePost(blodsid);
                                
                                 setStatelike((){
                                  liked = !liked;
                                  liked?likedNum++:likedNum--;
                                  likePost(blodsid);
                                });
                                
                              }, 
                              icon: Icon(Icons.thumb_up,color:liked? Colors.blue:const Color.fromARGB(149, 255, 255, 255),),),
                              Text(likedNum.toString(),style:const TextStyle(color: Colors.white),),
                            ],
                          );
                        },
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.only(right:5.0),
                        child: Row(
                          children: [
                            IconButton(onPressed: (){
                              setStateintaractive((){
                                commentOpen = !commentOpen;
                                commentsOpenBlogPage[index1] = commentOpen;
                              });
                            }, icon: Icon(Icons.comment,color:commenteD?Colors.blue:const Color.fromARGB(184, 255, 255, 255) ,)),
                            Text(AllComments.length.toString(),style:const TextStyle(color: Colors.white),),
                          ],
                        ),
                      ),
                    ],
                  )
                                    ],
                                    ),
                Visibility(
              visible: commentOpen,
              child: StreamBuilder(
                stream: firestore.collection("posts").doc(blodsid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return  Center(child: Container(),);
                  }
                  Map<String,dynamic> comAll = snapshot.data!["Comments"];
                  
                  return Container(
                    constraints:const BoxConstraints(minHeight: 70,maxHeight: 200),
                    child:comAll.isEmpty?const Text("No comments yet",style: TextStyle(color: Colors.white),) : ListView.builder(
                    shrinkWrap: true,
                    
                    itemCount: comAll.length,
                    itemBuilder: (BuildContext context, int index) {
                      List commentKeys = comAll.keys.toList();
                      String ownerOfComment = comAll[commentKeys[index]]["UserName"];
                      DateTime ttime = comAll[commentKeys[index]]["TimeStamp"].toDate();
                      String comContent = comAll[commentKeys[index]]["Comment"];
                      List LikesCom = comAll[commentKeys[index]]["Likes"];
                  
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding:const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                                                                    
                            color: const Color.fromARGB(205, 14, 13, 13),
                            borderRadius: BorderRadius.circular(10)
                          
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [Text(ownerOfComment,style:const TextStyle(color: Colors.white),),
                                const SizedBox(width: 10,),
                                Text(period(ttime),style:const TextStyle(color: Colors.white),softWrap: true,)],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(comContent,style:const TextStyle(color: Colors.white),),
                                  IconButton(onPressed: (){}, icon: Icon(Icons.favorite
                                  ,color:LikesCom.contains(user.uid)?Colors.red:const Color.fromARGB(207, 172, 170, 170) ,
                                  ))
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                                                          ),
                  );
                }
              ),)  

                ],
              );
            },
            
          ),
            
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
         // List document = blogsdata[blodsid]!["Documents"];
          Uint8List UserDp = blogsdata[blodsid]!["UserDp"];
          bool liked = blogsdata[blodsid]!["Liked"];
          
          bool commenteD = blogsdata[blodsid]!["Commented"];
          
          Map<String,dynamic> AllComments = blogsdata[blodsid]!["Comments"];
          String time = period(postTime);
        int likesNum =  blogsdata[blodsid]!["Likes"].length;
       
      return Column(
            children: [
              SizedBox(
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
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  crossAxisCount: 2,
                  children: List.generate(images_.length, (imageindex){
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(5.0),
                    child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                              
                              child: GridTile(
                                child: InkWell(
                                  onTap: (){
                                    showDialog(context: context, builder: (context){
                                      return showimage(context, images_, windowheight);
                                    });
                                  },
                                  child: Image.memory(fit: BoxFit.cover,images_[imageindex])))
                            ),
                    ),);
                  })
                ),
              ),
              StatefulBuilder(
            builder: (BuildContext context, setStateintaractive) {
              return Column(
                children: [
                  Container(
                    padding:const EdgeInsets.all(8),
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:commentOpen? SizedBox(height: 60,width: 200,
                        child: TextField(
                          onTapOutside: (event) => FocusScope.of(context).requestFocus(FocusNode()) ,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:  const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                              labelText: "Add comment",
                              labelStyle: const TextStyle(
                                  color: Color.fromARGB(255, 161, 159, 159))),
                          controller: BlogcommentText,
                            ),
                      ): Text(AllComments.isNotEmpty? AllComments[AllComments.keys.first]["Comment"].toString():"Be first to comments",style:const TextStyle(color: Colors.white,),maxLines: 2,
                      overflow: TextOverflow.fade,
                      ),
                    ),
                    Visibility(
                      visible: commentOpen,
                      child: IconButton(onPressed: ()async{
                        String state = "";
                      state = await commentpost(blodsid, BlogcommentText.text);
                        if (state == "Success") {
                          BlogcommentText.clear();
                          setStateintaractive((){});
                        }
                      }, icon:const Icon(Icons.send,color: Color.fromARGB(211, 255, 255, 255),))),
                    Row(
                      children: [
                        StatefulBuilder(
                          builder: (BuildContext context, setStateliked) {
                            return Row(
                              children: [
                                IconButton(onPressed: ()async{
                                  // String state= "";

                                 // state = await likePost(blodsid);
                                  
                                   setStateliked((){
                                    liked = !liked;
                                    liked?likesNum++:likesNum--;
                                    likePost(blodsid);
                                  });
                                  
                                }, 
                                icon: Icon(Icons.thumb_up,color:liked? Colors.blue:const Color.fromARGB(149, 255, 255, 255),),),
                                Text(likesNum.toString(),style:const TextStyle(color: Colors.white),),
                              ],
                            );
                          },
                        ),
                        
                        Row(
                          children: [
                            IconButton(onPressed: (){
                              setStateintaractive((){
                                commentOpen = !commentOpen;
                                commentsOpenBlogPage[index1] = commentOpen;
                              });
                            }, icon: Icon(Icons.comment,color:commenteD?Colors.blue:const Color.fromARGB(184, 255, 255, 255) ,)),
                            Text(AllComments.length.toString(),style:const TextStyle(color: Colors.white),),
                          ],
                        ),
                      ],
                    )
                  ],
                  ),
                ),
                Visibility(
              visible: commentOpen,
              child: StreamBuilder(
                stream: firestore.collection("posts").doc(blodsid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(),);
                  }
                  Map<String,dynamic> comAll = snapshot.data!["Comments"];
                  
                  return InkWell(
                    onTap: (){},
                    splashColor: Colors.transparent,
                    child: Container(
                      constraints:const BoxConstraints(minHeight: 70,maxHeight: 200),
                      child:comAll.isEmpty?const Text("No comments yet",style: TextStyle(color: Colors.white),) : ListView.builder(
                      shrinkWrap: true,
                      
                      itemCount: comAll.length,
                      itemBuilder: (BuildContext context, int index) {
                        List commentKeys = comAll.keys.toList();
                        String ownerOfComment = comAll[commentKeys[index]]["UserName"];
                        DateTime ttime = comAll[commentKeys[index]]["TimeStamp"].toDate();
                        String comContent = comAll[commentKeys[index]]["Comment"];
                        List LikesCom = comAll[commentKeys[index]]["Likes"];
                    
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding:const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                                                      
                              color: const Color.fromARGB(205, 14, 13, 13),
                              borderRadius: BorderRadius.circular(10)
                            
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [Text(ownerOfComment,style:const TextStyle(color: Colors.white),),
                                  const SizedBox(width: 10,),
                                  Text(period(ttime),style:const TextStyle(color: Colors.white),softWrap: true,)],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(comContent,style:const TextStyle(color: Colors.white),),
                                    IconButton(onPressed: (){}, icon: Icon(Icons.favorite
                                    ,color:LikesCom.contains(user.uid)?Colors.red:const Color.fromARGB(207, 172, 170, 170) ,
                                    ))
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                                                            ),
                    ),
                  );
                }
              ),)  

                ],
              );
            },
            
          ),
            
            ],
          );
    }
  );
}