import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vora_mobile/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vora_mobile/utils.dart';

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

var img;
Future<Map<int,Map<String,dynamic>>> events_ ()async{
  Map<int,Map<String,dynamic>> master_m =Map();

  await firestore_.collection("users").doc(user.uid).get().then((onValue)async{
    var events_att = onValue.data()!["Events"];
    int number = 0;
    for(var even in events_att){
      Map<String,dynamic> local = Map();
      final evId = <String,dynamic>{"EventId":even};
      await firestore_.collection("Events").doc(even).get().then((onValue1){
        final evTitle = <String,dynamic>{"Title":onValue1.data()!["Title"]};
        final evDate = <String,dynamic>{"Date":onValue1.data()!["EventDate"]};
        local.addAll(evDate);
        local.addAll(evTitle);
        local.addAll(evId);
      });
      final adds = <int,Map<String,dynamic>>{number:local};
      master_m.addAll(adds);
      number++;
    }
  });


  return master_m;
}


Future<Map<int,Map<String,dynamic>>> clubs_ ()async{
  Map<int,Map<String,dynamic>> k_map = Map();
int c_nums= 0;
print("Starts");
await store.collection("users").doc(user.uid).get().then((onValue)async{
  var comms = onValue.data()!["Communities"];
  print(onValue.data()!.length);
  for(var com in comms){
    Map<String,dynamic> datas_ = Map();
    await store.collection("Communities").doc(com).get().then((onValue1){
      final name = <String,dynamic>{"Name":onValue1.data()!["Name"]};
      datas_.addAll(name);
    });
    await storage_1.child("/communities/$com/cover_picture").getData().then((onValue2){
      final imgs = <String,dynamic>{"Image":onValue2!};
      datas_.addAll(imgs);
    });
    final master = <int,Map<String,dynamic>>{c_nums:datas_};
    k_map.addAll(master);
c_nums++;
  }
});

return k_map;

}


Future<Map<int,Map<String,dynamic>>> posts_ ()async{
Map<int,Map<String,dynamic>> datas = Map();
await store.collection("posts").where("UserId", isEqualTo: "TEvmjtmczycxde4b55uK4jJ7wz03"
).get().then((onValue)async{
  int num_ = 0;
  for(var val in onValue.docs){
    Map<String,dynamic> now = Map();
    await store.collection("posts").doc(val.id).get().then((onValue1){
      final post =<String,dynamic>{"post":onValue1.data()!["BlogPost"]};
      final postid = <String,dynamic>{"postId":onValue1.data()!["PostId"]};
      final time = <String,dynamic>{"PostTime":onValue1.data()!["PostTime"]};
      now.addAll(postid);
      now.addAll(post);
      now.addAll(time);
     
    });
    await storage_1.child("/posts/${val.id}/images").list().then((onValue2)async{
     String ok= onValue2.items.first.toString();
    ok = ok.split(":").last.split(")").first.replaceAll(" ", '');
     
      await storage_1.child(ok).getData().then((onValue3){
        final img = <String,dynamic>{"Image":onValue3!};
        if (img.isNotEmpty) {
          print("okkkk");
        }
        now.addAll(img);
      });
    });
    final now_ = <int,Map<String,dynamic>>{num_:now};
    datas.addAll(now_);
    num_++;
  }
});

return datas;
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
List<Widget> _screens = <Widget>[
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
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Homepage())),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          title: const Text(
            "My Profile",
            style: TextStyle(color: Colors.white),
          ),
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

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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
                                      
                                      p_controller.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                      setstate1((){});
                                    },child:Container(
                                      decoration:p_controller.positions.isNotEmpty? BoxDecoration(color: p_controller.page == 0? Colors.lightBlue:Colors.transparent,borderRadius: BorderRadius.circular(10)):null,
                                      child:const Padding(
                                        padding:  EdgeInsets.all(4.0),
                                        child:  Text("Posts",style: TextStyle(color: Colors.white),),
                                      )),),
                                  ),
                                  SizedBox(
                                    height: 40,
                                   
                                    child: TextButton(onPressed: ()async{
                                      
                                      p_controller.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                      setstate1((){});
                                    },child:Container(
                                       decoration:p_controller.positions.isNotEmpty? BoxDecoration(color: p_controller.page == 1? Colors.lightBlue:Colors.transparent,borderRadius: BorderRadius.circular(10)):null,
                                      child:const Padding(
                                        padding:  EdgeInsets.all(4.0),
                                        child:  Text("Clubs",style: TextStyle(color: Colors.white),),
                                      )),),
                                  ),
                                  SizedBox(
                                    height: 40,
                                 
                                    child: TextButton(onPressed: (){
                                      p_controller.animateToPage(2, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                      setstate1((){});
                                     
                                    },child:Container(
                                       decoration:p_controller.positions.isNotEmpty? BoxDecoration(color: p_controller.page == 2? Colors.lightBlue:Colors.transparent,borderRadius: BorderRadius.circular(10)):null,
                                      child:const Padding(
                                        padding:  EdgeInsets.all(4.0),
                                        child:  Text("Events",style: TextStyle(color: Colors.white),),
                                      )),),
                                  ),
                                  SizedBox(
                                    height: 40,
                                  
                                    child: TextButton(onPressed: (){
                                     p_controller.animateToPage(3, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                     setstate1((){});
                                    },child:Container(
                                       decoration:p_controller.positions.isNotEmpty? BoxDecoration(color: p_controller.page == 3? Colors.lightBlue:Colors.transparent,borderRadius: BorderRadius.circular(10)):null,
                                      child:const Padding(
                                        padding:  EdgeInsets.all(4.0),
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
    future: posts_(),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      
      if (snapshot.connectionState ==ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(),);
      }
      if (!snapshot.hasData) {
        return const Center(child: Text("No Posts Yet...",style: TextStyle(color: Colors.white),),);
      }
      return ListView.builder(
        shrinkWrap: true,
        physics:const AlwaysScrollableScrollPhysics(),
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context,index){
          Map<String,dynamic> postdata = snapshot.data[index];
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color.fromARGB(255, 100, 97, 97))),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(children: [
                  Text("On ${postdata["PostTime"].toDate().day}",style: TextStyle(color: Colors.white),),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(postdata["post"],style:TextStyle(color: Colors.white) ,),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        
                        children: [
                          Container(
                            
                            child:const Row(
                              children: [
                                  Icon(Icons.thumb_up_alt_rounded,color: Colors.white,),
                                   SizedBox(width: 10,),
                          Text("100",style: TextStyle(color: Colors.white),),
                              ],
                            ),
                          ),
                          Container(
                             
                      child:const Row(children: [    Icon(Icons.comment,color: Colors.white,),
                      const SizedBox(width: 10,),
                          Text("20",style: TextStyle(color: Colors.white),)],),
                          ),
                      ],
                      ),
                    ),
                  )
                ],),
              ),
            ),
          ),
        );
      });
    },
  );
}
Widget clubs(){
  return FutureBuilder(
    future: clubs_(),

    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(),);
      }
      if (!snapshot.hasData) {
        return const Center(child: Text("You are not a member of any club...",style: TextStyle(color: Colors.white),),);
      }
      
      return ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: snapshot.data!.length,
        itemBuilder: (context,index){
         Map<String,dynamic> all_data = snapshot.data![index];
         Uint8List c_image_ = all_data["Image"];
         String name_ = all_data["Name"];
         
        return Center(
          child: Padding(padding: EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: const Color.fromARGB(255, 53, 52, 52)),borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: MemoryImage(c_image_),
                  ),
                ),
               const SizedBox(width: 50,),
                Text(name_,style:const TextStyle(color: Colors.white),),
              const  Text("Number of events",style: TextStyle(color: Colors.white),)
              ],
            ),
          ),
          ),
        );
      });
    },
  );

}
Widget eventsattended(){
  return FutureBuilder(
    future: events_(),
    
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.connectionState ==ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(),);
      }
      if (!snapshot.hasData) {
        return const Center(child: Text("No Events Attended Yet...",style: TextStyle(color: Colors.white),),);
      }

      return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (context,index){
        Map<String,dynamic> all_events =  snapshot.data![index];
        String E_title= all_events["Title"];
        DateTime ttime = all_events["Date"].toDate();
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color.fromARGB(141, 0, 0, 0))
                ),
                child: Row(
                  children: [
                    Text(E_title,style:const TextStyle(color: Colors.white),),
                   const SizedBox(width: 30,),
                   Text(ttime.day.toString(),style:const TextStyle(color: Colors.white),)
                  ],
                ),
              ),
            ),
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