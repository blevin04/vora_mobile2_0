import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart'hide CarouselController;

import 'package:table_calendar/table_calendar.dart';
import 'package:vora_mobile/add_pages/new_post.dart';


import 'package:vora_mobile/dedicated/DedicatedBlogPage.dart';
import 'package:vora_mobile/dedicated/dedicatedCommunityPage.dart';
import 'package:vora_mobile/dedicated/dedicatedEventPage.dart';
import 'package:vora_mobile/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vora_mobile/utils.dart';


TextEditingController name_change = TextEditingController();
TextEditingController nick_change = TextEditingController();
final storage =
    FirebaseStorage.instance.ref().child('/profile/${user.uid}/dp.png');
    final storage_1 = FirebaseStorage.instance.ref();
FirebaseFirestore store = FirebaseFirestore.instance;
User user = FirebaseAuth.instance.currentUser!;
var snap;

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}
String f_hint = '';
String n_hint = '';
var img;
Future<List<String>> getattendedEventsIds()async{
  List<String> eventsids = List.empty(growable: true);
  await firestore_.collection("users").doc(user.uid).get().then((evIds){
    for(var id in evIds.data()!["Events"]){
      eventsids.add(id);
    }
  });
  return eventsids;
}

Future<Map<int,Map<String,dynamic>>> events_ ()async{
  Map<int,Map<String,dynamic>> master_m =Map();

  await firestore_.collection("users").doc(user.uid).get().then((onValue)async{
    var events_att = onValue.data()!["Events"];
    int number = 0;
    for(var even in events_att){
      Map<String,dynamic> local = Map();
      final evId = <String,dynamic>{"EventId":even};
      await store.collection("Events").doc(even).get().then((onValue1){
        final evTitle = <String,dynamic>{"Title":onValue1.data()!["Title"]};
        final evDate = <String,dynamic>{"Date":onValue1.data()!["EventDate"]};
        
        local.addAll(evDate);
        local.addAll(evTitle);
        local.addAll(evId);
        
      });
      await storage_1.child("/events/$even/cover").getData().then((value){
        final imgdata = <String,dynamic>{"Cover":value!};
        local.addAll(imgdata);
      });
      final adds = <int,Map<String,dynamic>>{number:local};
      master_m.addAll(adds);
      number++;
    }
  });
  return master_m;
}
Future<List<String>> getMemberClubs()async{
  List<String> memberclubs = List.empty(growable: true);
  
  await firestore_.collection("users").doc(user.uid).get().then((value) {
    
    for(var club in value.data()!["Communities"]){
      memberclubs.add(club);
    }
  },);
  return memberclubs;
}


Future<List<String>> evIds()async{
  List<String> ids = List.empty(growable: true);
  await store.collection("users").doc(user.uid).get().then((onValue){
    ids = onValue.data()!["Communities"];
  });
  return ids;
}
Future<List<String>> getPostIds()async{
  List<String> ids = List.empty(growable: true);
  await store.collection("posts").where("UserId", isEqualTo: user.uid).get().then((pIds){
    for(var id in pIds.docs){
      ids.add(id.id);
    }
  });
  return ids;
}
Future<Map<String,dynamic>> postDatas(String PostId1)async{
  Map<String,dynamic> dataspost = {};
  await store.collection("posts").doc(PostId1).get().then((pdata){
    dataspost.addAll(pdata.data()!);
  });
  return dataspost;
}


class _AccountsState extends State<Accounts> {
  @override
  void initState() {
    super.initState();
    snap = store.collection("users").doc(user.uid).get();
    getImagelnk();
  }

  void getImagelnk() async {
    img = await storage.getData();
  }
final List<Widget> _screens = <Widget>[
postpage(),clubs(),eventsattended(),mycallender()

];
PageController p_controller = PageController();
  @override
  Widget build(BuildContext context) {
    // double _width = MediaQuery.of(context).size.width;
    // double _height = MediaQuery.of(context).size.height;

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
              onPressed: () =>Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          title: const Text(
            "My Profile",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(onPressed: (){
              showDialog(context: context, builder: (context){
                return Dialog(
                  backgroundColor: const Color.fromARGB(249, 27, 27, 27),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 200,minHeight: 100),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Full Name",style: TextStyle(color: Colors.white),),
                          TextField(

                            style:const TextStyle(color: Colors.white),
                            controller: name_change,
                            decoration: InputDecoration(
                              helperStyle:const TextStyle(color: Colors.white),
                              hintText: f_hint,
                              // label: Text("Nick Name"),
                              // labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255))
                            ),
                          ),
                         const Text("Nick Name",style: TextStyle(color: Colors.white)),
                          TextField(
                            style:const TextStyle(color:Colors.white),
                            decoration:  InputDecoration(
                              
                              hintText: n_hint
                              // helperText: "Nick Name",
                              // helperStyle: TextStyle(color: Colors.white),
                            ),
                            controller: nick_change,
                          ),
                        InkWell(
                          
                          borderRadius: BorderRadius.circular(10),
                          onTap: ()async{
                            String Status ='';
                            if (Status.isEmpty) {
                              showcircleprogress(context);
                            }
                            else{
                              
                            }
                            if (nick_change.text.isNotEmpty &&
                                name_change.text.isNotEmpty
                            ) {
                              
                              try {
                                await store.collection("users").doc(user.uid).
                               update({"fullName" : name_change.text,"nickname": nick_change.text});
                               Status = "Success";
                               Navigator.pop(context);
                               Navigator.pop(context);
                               showsnackbar(context, "Profile update successfull");
                               setState(() {
                                 
                               });
                              } catch (e) {
                                Status = e.toString();
                              }
                               
                            }else{
                              Status = "Failled";
                              nick_change.text.isEmpty?
                              showsnackbar(context, "nickname cannot be empty"):null;
                              name_change.text.isEmpty?showsnackbar(context, "Name cannot be empty"):null;
                              Navigator.pop(context);
                            }
                           
                           
                          },
                          child:Container(decoration: BoxDecoration(color: Colors.blue,borderRadius: BorderRadius.circular(10)),child:const Padding(
                            padding:  EdgeInsets.all(8.0),
                            child:  Text("Save",style: TextStyle(color: Colors.white),),
                          )),
                        )
                        ],
                      ),
                    ),
                  ),
                );
              });
            }, icon:const Icon(Icons.edit,color: Colors.white,))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
             const Padding(padding: EdgeInsets.all(10)),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 100,
                    child: FutureBuilder(
                    future: storage.getData(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      Uint8List data_ = Uint8List(2);
                      if (snapshot.hasData) {
                        Uint8List data = snapshot.data;
                        data_ = data;
                      }
                      if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                      return CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.white,
                        backgroundImage: snapshot.hasData
                            ? MemoryImage(data_)
                            : const AssetImage('lib/assets/dp.png'),
                      );
                    },
                  ),
                  ),IconButton(
                              color: Colors.black,
                              onPressed: () async {
                                await Permission.accessMediaLocation
                                    .onDeniedCallback(() async {
                                  Permission.accessMediaLocation.request();
                                  if (await Permission
                                      .accessMediaLocation.isDenied) {
                                    showsnackbar(context, "Permission denied");
                                  }
                                  if (await Permission
                                      .accessMediaLocation.isGranted) {
                                    showsnackbar(context, 'Granted');
                                  }
                                });
                                FilePickerResult? result = (await FilePicker
                                    .platform
                                    .pickFiles(type: FileType.image));
                                if (result != null) {
                                  storage.delete();
                                  storage
                                      .putFile(File(result.files.single.path!));
                                  setState(() {});
                                }
                                if (result == null) {
                                  showsnackbar(context, 'no image chossen');
                                }
                              },
                              icon: const Icon(
                                Icons.camera_alt_sharp,
                                color: Color.fromARGB(255, 147, 132, 132),
                                size: 25,
                              ))
                ],
              ),
              FutureBuilder(
                future: store.collection('users').doc(user.uid).get(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  Map<String, dynamic> data =
                      snapshot.data.data() as Map<String, dynamic>;
                    f_hint = data["fullName"] as String;
                    n_hint = data["nickname"] as String;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          data['fullName'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          data['nickname'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Divider(
                          indent: 30,
                          endIndent: 30,
                          color: Color.fromARGB(160, 69, 69, 69),
                        ),

                      ],
                    ),
                  );
                },
              ),
              StatefulBuilder(
                builder: (context,setstate1){
                  return Column(
                    children: [
                      Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    height: 40,
                                   
                                    child: TextButton(onPressed: ()async{
                                      
                                      p_controller.animateToPage(0, duration:const Duration(milliseconds: 500), curve: Curves.ease);
                                      setstate1((){});
                                    },child:Container(
                                      decoration:p_controller.positions.isNotEmpty? BoxDecoration(color:p_controller.page==0?const Color.fromARGB(233, 47, 46, 46):Colors.transparent,border: Border.all(color: p_controller.page==0? Colors.white:Colors.transparent),borderRadius: BorderRadius.circular(10)):null,
                                      child:const Padding(
                                        padding:  EdgeInsets.all(2.0),
                                        child:  Text("Posts",style: TextStyle(color: Colors.white),),
                                      )),),
                                  ),
                                  SizedBox(
                                    height: 40,
                                   
                                    child: TextButton(onPressed: ()async{
                                      
                                      p_controller.animateToPage(1, duration:const Duration(milliseconds: 500), curve: Curves.ease);
                                      setstate1((){});
                                    },child:Container(
                                       decoration:p_controller.positions.isNotEmpty? BoxDecoration(color:p_controller.page==1?const Color.fromARGB(233, 47, 46, 46):Colors.transparent,border: Border.all(color: p_controller.page==1? Colors.white:Colors.transparent),borderRadius: BorderRadius.circular(10)):null,
                                      child:const Padding(
                                        padding:  EdgeInsets.all(2.0),
                                        child:  Text("Clubs",style: TextStyle(color: Colors.white),),
                                      )),),
                                  ),
                                  SizedBox(
                                    height: 40,
                                 
                                    child: TextButton(onPressed: (){
                                      p_controller.animateToPage(2, duration:const Duration(milliseconds: 500), curve: Curves.ease);
                                      setstate1((){});
                                     
                                    },child:Container(
                                       decoration:p_controller.positions.isNotEmpty? BoxDecoration(color:p_controller.page==2?const Color.fromARGB(233, 47, 46, 46):Colors.transparent,border: Border.all(color: p_controller.page==2? Colors.white:Colors.transparent),borderRadius: BorderRadius.circular(10)):null,
                                      child:const Padding(
                                        padding:  EdgeInsets.all(2.0),
                                        child:  Text("Events",style: TextStyle(color: Colors.white),),
                                      )),),
                                  ),
                                  SizedBox(
                                    height: 40,
                                  
                                    child: TextButton(onPressed: (){
                                     p_controller.animateToPage(3, duration:const Duration(milliseconds: 500), curve: Curves.ease);
                                     setstate1((){});
                                    },child:Container(
                                       decoration:p_controller.positions.isNotEmpty? BoxDecoration(color:p_controller.page==3?const Color.fromARGB(233, 47, 46, 46):Colors.transparent,border: Border.all(color: p_controller.page==3? Colors.white:Colors.transparent),borderRadius: BorderRadius.circular(10)):null,
                                      child:const Padding(
                                        padding:  EdgeInsets.all(2.0),
                                        child:  Text("My Calender",style: TextStyle(color: Colors.white),),
                                      )),),
                                  ),
                                      
                                ],
                              ),
                              SizedBox(
               height:400,
                child: PageView(
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (value) {
                     p_controller.jumpToPage(value);
                     setstate1((){});
                  },
                  controller: p_controller,
                  children: _screens,
                )
              )
                    ],
                  );
                },
              
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget postpage(){
  return FutureBuilder(
    future: getPostIds(),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      
      if (snapshot.connectionState ==ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(),);
      }
      if (!snapshot.hasData) {
        return const Center(child: Text("No Posts Yet...",style: TextStyle(color: Colors.white),),);
      }
      if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }

      return snapshot.data.isEmpty?  Center(
        child: TextButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>const NewPost()));
        }, child:const Text("No Posts Yet.. \nCreate one now",style: TextStyle(color: Colors.white),),)
      ): ListView.builder(
        shrinkWrap: true,
        physics:const AlwaysScrollableScrollPhysics(),
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context,index){
          print("Posts ar ${snapshot.data!}");
          
          
        return blogsdata[snapshot.data[index]] == null?
        FutureBuilder(
          future: postDatas(snapshot.data[index]), 
          builder: (context,snapshot1){
            DateTime PsTime = snapshot1.data!["PostTime"].toDate();
            String Bpost = snapshot1.data!["BlogPost"];
            List Plikes = snapshot1.data!["Likes"];
            Int NumComments = snapshot1.data!["Comments"].length;
            return Center(
          child: InkWell(
            onTap: () => Navigator.push(context,MaterialPageRoute(builder:
             (context)=>const Dedicatedblogpage())),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color.fromARGB(255, 100, 97, 97))),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(children: [
                    Text(period(PsTime),style:const TextStyle(color: Colors.white),),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(Bpost,style:const TextStyle(color: Colors.white) ,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        
                        children: [
                          Row(
                            children: [
                               const Icon(Icons.thumb_up_alt_rounded,color: Colors.white,),
                                const SizedBox(width: 10,),
                                                      Text((Plikes.length - 1).toString(),style: TextStyle(color: Colors.white),),
                            ],
                          ),
                          Row(children: [  const  Icon(Icons.comment,color: Colors.white,),
                          const SizedBox(width: 10,),
                              Text(NumComments.toString(),style:const TextStyle(color: Colors.white),)],),
                      ],
                      ),
                    )
                  ],),
                ),
              ),
            ),
          ),
        );
          }):
          Builder(builder: (context){
            
          Map<String,dynamic> bData=  blogsdata[index]!;
          DateTime btime = bData["PostTime"].toDate();
          List likesT = bData["Likes"];
          int NumComments = bData["Comments"].length;
            return Center(
          child: InkWell(
            onTap: () => Navigator.push(context,MaterialPageRoute(builder:
             (context)=>const Dedicatedblogpage())),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color.fromARGB(255, 100, 97, 97))),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(children: [
                    Text(period(btime),style:const TextStyle(color: Colors.white),),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(bData["BlogPost"].toString(),style:const TextStyle(color: Colors.white) ,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        
                        children: [
                          Row(
                            children: [
                              const  Icon(Icons.thumb_up_alt_rounded,color: Colors.white,),
                               const  SizedBox(width: 10,),
                                                      Text((likesT.length - 1).toString(),style:const TextStyle(color: Colors.white),),
                            ],
                          ),
                          Row(children: [   const Icon(Icons.comment,color: Colors.white,),
                          const SizedBox(width: 10,),
                              Text(NumComments.toString(),style:const TextStyle(color: Colors.white),)],),
                      ],
                      ),
                    )
                  ],),
                ),
              ),
            ),
          ),
        );
          })
          
          ;
        
      });
    },
  );
}
Widget clubs(){
  return 
   FutureBuilder(
    future: getMemberClubs(),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(),);
      }
      if (!snapshot.hasData) {
        return const Center(child: Text("You are not a member of any club...",style: TextStyle(color: Colors.white),),);
      }
      if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
        
      return ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: snapshot.data!.length,
        itemBuilder: (context,index){
        return clubData[snapshot.data![index]] == null?
        FutureBuilder(
          future: getclubdatas(snapshot.data![index]),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            Uint8List c_image_ = snapshot.data["Image"];
            String Clubname = snapshot.data["Name"];
            List eventsNumber = snapshot.data["events"];
            return Center(
          child: Padding(padding:const EdgeInsets.all(5),
          child: InkWell(
            onTap: () => Navigator.push(context,MaterialPageRoute(builder:
             (context)=>  Dedicatedcommunitypage(clubId: snapshot.data[index],))),
            child: Container(
              height: 62,
              decoration: BoxDecoration(border: Border.all(color: const Color.fromARGB(255, 53, 52, 52)),borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: MemoryImage(c_image_),
                ),
              ),
              title: Text(Clubname,style:const TextStyle(color: Colors.white),),
              trailing: Text("${eventsNumber.length} events",style:const TextStyle(color: Colors.white),)
              
              ),
            ),
          ),
          ),
        );
          },
        ):Builder(builder: (context){
          Uint8List coverPic = clubData[snapshot.data[index]]!["Image"];
          String clubName = clubData[snapshot.data[index]]!["Name"];
          List eventsNumber = clubData[snapshot.data[index]]!["events"];
          return Center(
          child: Padding(padding:const EdgeInsets.all(5),
          child: InkWell(
            onTap: () => Navigator.push(context,MaterialPageRoute(builder:
             (context)=>  Dedicatedcommunitypage(clubId: snapshot.data[index],))),
            child: Container(
              height: 62,
              decoration: BoxDecoration(border: Border.all(color: const Color.fromARGB(255, 53, 52, 52)),borderRadius: BorderRadius.circular(10)),
              child:  ListTile(
                leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: MemoryImage(coverPic),
                ),
              ),
              title: Text(clubName,style:const TextStyle(color: Colors.white),),
              trailing: Text("${eventsNumber.length} events",style:const TextStyle(color: Colors.white),)
              
              ),
            ),
          ),
          ),
        );
        });
      });
    },
  );

}

Widget eventsattended(){

  return FutureBuilder(
    future: getattendedEventsIds(),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.connectionState ==ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(),);
      }
      if (!snapshot.hasData) {
        return const Center(child: Text("No Events Attended Yet...",style: TextStyle(color: Colors.white),),);
      }
      if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
      
      return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (context,index){
        
          return eventData[snapshot.data[index]] == null?
          FutureBuilder(
            future: geteventsData(snapshot.data[index]),
            builder: (BuildContext context, AsyncSnapshot snapshot1) {
              if (snapshot1.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(),);
              }
              Uint8List coverimg = snapshot1.data["Cover_Image"];
              String eventTitle = snapshot1.data["Title"];
              DateTime eventDate = snapshot1.data["EventDate"].toDate();
              int likesTotal = snapshot1.data["Likes"].length;
              int commentNumber = snapshot1.data["Comments"].length;
               String aboutEvent = snapshot1.data["Description"];
               bool liked1 = snapshot1.data["Liked"];
              return Center(
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: 
              (context)=>  Dedicatedeventpage(eventId:snapshot.data[index]))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color:const Color.fromARGB(233, 47, 46, 46),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color.fromARGB(141, 0, 0, 0))
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(radius: 40, 
                        backgroundImage:MemoryImage(coverimg)), 
                        onTap: (){},
                        
                        title: Text(eventTitle,style:const TextStyle(color: Colors.white),),
                        trailing:Text(period(eventDate),style:const TextStyle(color: Colors.white),) ,
                        ),
                      ),
                        Text(aboutEvent,style:const TextStyle(color: Colors.white),softWrap: true,),
                      Center(child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        StatefulBuilder(
                          builder: (BuildContext context, setStateLike) {
                            
                            return Row(
                              children: [
                                IconButton(onPressed: ()async{
                                  String  States = "";
                                       setStateLike((){
                                       
                                            if (liked1) {
                                            likesTotal-1;
                                          }else{likesTotal+1;}
                                           liked1=!liked1;
                                       });
                                       States =await likeEvent(snapshot.data[index]);
                                       if (States=="Success") {
                                         showsnackbar(context, "nice");
                                       }
                                }, 
                                icon: Icon(Icons.thumb_up,
                                
                                color:liked1?Colors.blue:
                                const Color.fromARGB(205, 255, 255, 255),)),
                                  Text((likesTotal).toString(),style:const TextStyle(color: Colors.white),)
                              ],
                            );
                          },
                        ),
                        StatefulBuilder(
                          builder: (BuildContext context, setStateComment) {
                            return Row(
                              children: [
                                IconButton(onPressed: (){}, 
                                icon: const Icon(Icons.comment,
                                color: Color.fromARGB(139, 225, 222, 222),)),
                                Text(commentNumber.toString(),style:const TextStyle(color: Colors.white),)
                              ],
                            );
                          },
                        ),
                      ],),)
                    ],
                  ),
                ),
              ),
            ),
          );
            },
          ):
          Builder(
            builder: (context) {
               Uint8List coverimg = eventData[snapshot.data[index]]!["Cover_Image"];
              String eventTitle =eventData[snapshot.data[index]]!["Title"];
              DateTime eventDate = eventData[snapshot.data[index]]!["EventDate"].toDate();
              int likesTotal = eventData[snapshot.data[index]]!["Likes"].length;
              int commentNumber = eventData[snapshot.data[index]]!["Comments"].length;
              bool liked1 = eventData[snapshot.data[index]]!["Liked"];
              String aboutEvent = eventData[snapshot.data[index]]!["Description"];
             // bool commented = eventData[snapshot.data[index]]!["Commented"];
              return Center(
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: 
                  (context)=>  Dedicatedeventpage(eventId:snapshot.data[index]))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color:const Color.fromARGB(233, 47, 46, 46),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color.fromARGB(141, 0, 0, 0))
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: CircleAvatar(radius: 40, 
                            backgroundImage:MemoryImage(coverimg)), 
                            onTap: (){},
                            
                            title: Text(eventTitle,style:const TextStyle(color: Colors.white),),
                            trailing:Text(period(eventDate),style:const TextStyle(color: Colors.white),) ,
                            ),
                          ),
                          Text(aboutEvent,style:const TextStyle(color: Colors.white),softWrap: true,),

                          Center(child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                            StatefulBuilder(
                              builder: (BuildContext context, setStateLike) {
                                
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      IconButton(onPressed: ()async{
                                      String  States = "";
                                       setStateLike((){
                                       
                                            if (liked1) {
                                            likesTotal-1;
                                          }else{likesTotal+1;}
                                           liked1=!liked1;
                                       });
                                       States =await likeEvent(snapshot.data[index]);
                                      if (States=="Success") {
                                        showsnackbar(context, "nice");
                                      }
                                      //  if (States == "Success") {
                                      //   print(States);
                                      //    setStateLike((){
                                      //     liked1 = !liked1;
                                      
                                      //    });
                                      //  }
                                      }, 
                                      icon: Icon(Icons.thumb_up,
                                      
                                      color:liked1?Colors.blue:
                                      const Color.fromARGB(205, 255, 255, 255),)),
                                        Text((likesTotal).toString(),style:const TextStyle(color: Colors.white),)
                                    ],
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  IconButton(onPressed: (){}, 
                                  icon:const  Icon(Icons.comment,
                                  color: Color.fromARGB(218, 225, 222, 222),)),
                                  Text(commentNumber.toString(),style:const TextStyle(color: Colors.white),)
                                ],
                              ),
                            ),
                          ],),)
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          );
          
      });
    },
  );
}
Widget mycallender(){
  return TableCalendar(
    focusedDay: DateTime.now(), 
    firstDay: DateTime(2020), 
    lastDay: DateTime(2040),
    headerStyle:const HeaderStyle(
      titleTextStyle: TextStyle(color: Colors.white)
    ),
    calendarStyle:const CalendarStyle(
      withinRangeTextStyle: TextStyle(color: Colors.white),
      weekNumberTextStyle: TextStyle(color: Colors.white),
      defaultTextStyle: TextStyle(color: Colors.white)
    ),
    );
}