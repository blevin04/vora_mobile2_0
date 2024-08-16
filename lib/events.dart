import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vora_mobile/firebase_Resources/add_content.dart';
import 'package:vora_mobile/homepage.dart';
import 'package:vora_mobile/utils.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

final store = FirebaseStorage.instance.ref();
final firestore = FirebaseFirestore.instance;
Widget show =const Text(
  "Events",
  style: TextStyle(color: Colors.white),
);
var event_filter = [
  "all",
  "Registered",
  "not Registered",
  "From all clubs",
];
String event_value = "all";
bool events_vis = false;
TextEditingController _search_events = TextEditingController();
List<String> eventIds = List.empty(growable: true);
ValueNotifier<bool> Search_visible_ = ValueNotifier(false);
class _EventsState extends State<Events> {
  @override
  void initState() {
    super.initState();
    
  }

  Future<void> getevents([String filter = "null"]) async {
    eventIds.clear();
    await firestore
        .collection("Events")
        .where("EventDate", isLessThan: Timestamp.now())
        .get()
        .then((onValue) {
      for (var snaps in onValue.docs) {
        eventIds.add(snaps["Uid"]);
        //  print(snaps);
      }
    });
    // print(eventIds);
  }
  Future<Map<String,dynamic>> get_events(String eventId)async{
    Map<String,dynamic> even_m = Map();
    var comm_id;
    await firestore.collection("Events").doc(eventId).get().then((onValue){
      final title = <String,dynamic>{"Title":onValue.data()!["Title"]};
     comm_id = onValue.data()!["Community"];
      final date = <String,dynamic>{"EventDate":onValue.data()!["EventDate"]};
      even_m.addAll(title);
      even_m.addAll(date);
     
    });
    await firestore.collection("Communities").doc(comm_id).get().then((value){
      final comm_name = <String,dynamic>{"Club_Name":value.data()!["Name"]};
    even_m.addAll(comm_name);
    });

    await store.child("/communities/$comm_id/cover_picture").getData().then((value1){
      final c_images = <String,dynamic>{"Cover_Image":value1!};
      even_m.addAll(c_images);
    });
    await store.child("/events/$eventId/").list().then((onValue1)async{
      List<dynamic> imgs_ =List.empty(growable: true);
      
      for(var val in onValue1.items){
        var path = val.toString().split(":").last;
        path = path.split(")").first;
        path =path.split(":").last;
        path = path.split(" ").last;
       
         await store.child(path).getData().then((onValu){
          imgs_.add(onValu!);
        });
      }
      final img_paths = <String,dynamic>{"Images":imgs_};
      even_m.addAll(img_paths);
    });
    
    return even_m;
  }

  late ListResult imgdir;
  Future<void> getimgs(int index) async {
    imgdir = await store.child("/events/${eventIds[index]}/").list();
  }

  Future<Uint8List?> getlocalimg(String path) async {
    var snap = await store.child(path).getData();
    return snap;
  }

  @override
  Widget build(BuildContext context) {
    // double _width = MediaQuery.of(context).size.width;
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
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Homepage()));
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: const Text(
          "Events",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () {
                
                  events_vis = !events_vis;
               Search_visible_.value = !Search_visible_.value;
              },
              icon: const Icon(
                Icons.search_sharp,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ListenableBuilder(
                  listenable: Search_visible_,
                  builder: (context,child) {
                    return Visibility(
                        visible: events_vis,
                        child: SizedBox(
                          width: 150,
                          child: TextField(
                            controller: _search_events,
                            decoration: const InputDecoration(
                                label: Icon(
                              Icons.search,
                              color: Colors.white,
                            )),
                          ),
                        ));
                  }
                ),
                const SizedBox(
                  width: 50,
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  child: DropdownButton(
                    dropdownColor: const Color.fromARGB(
                      255,
                      29,
                      36,
                      45,
                    ),
                    // Initial Value
                    value: event_value,

                    // Down Arrow Icon
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),

                    // Array list of items
                    items: event_filter.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(
                          items,
                          style:const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        event_value = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const Divider(
              color: Color.fromARGB(
                255,
                29,
                36,
                45,
              ),
            ),
            FutureBuilder(
                future: getevents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: eventIds.length,
                      itemBuilder: (context, index2) {
                        
                        return 
                        FutureBuilder(
                          future: get_events(eventIds[index2]),
                          
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return  Center(child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(decoration: BoxDecoration(color: const Color.fromARGB(255, 99, 94, 94),borderRadius: BorderRadius.circular(12)),height: 200,
                                child:const Center(child: CircularProgressIndicator(color: Colors.blue,),),
                                ),
                              ),);
                            }
                            if (snapshot.connectionState == ConnectionState.none) {
                                    return const Center(child: Column(children: [Icon(Icons.wifi_off_rounded),Text("Offline...")],),);
                                  }
                            if (!snapshot.hasData) {
                              return const Center(child: Text("Unable to fetch Events...",style: TextStyle(color: Colors.white),),);
                            }
                            Uint8List C_image_comm = snapshot.data!["Cover_Image"];
                            String Event_title = snapshot.data!["Title"];
                            List<dynamic> event_imgs = snapshot.data!["Images"];
                            DateTime time = snapshot.data!["EventDate"].toDate();
                            String C_name = snapshot.data!["Club_Name"];
                            return Padding(
                            padding: const EdgeInsets.all(2),
                            child: Card(
                              color: const Color.fromARGB(86, 82, 81, 81),
                              elevation: 10,
                              child: InkWell(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                           Padding(
                                            padding:const EdgeInsets.all(5),
                                            child: CircleAvatar(
                                              backgroundImage: MemoryImage(C_image_comm)
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  Event_title,
                                                  style: const TextStyle(
                                                      color: Colors.blue,fontSize: 18),
                                                ),
                                                Text(
                                                  period(time),
                                                  style:const TextStyle(
                                                      color: Color.fromARGB(
                                                          174, 255, 255, 255)),
                                                )
                                              ],
                                            ),
                                          ),
                                         const   SizedBox(width: 30,),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text("by $C_name ",style: TextStyle(color: Colors.white,fontSize: 12),),
                                          ),
                                          const SizedBox(width: 50,),
                                          TextButton(onPressed: (){
                                            showDialog(context: context, builder: (context){
                                              return Dialog(
                                                alignment: Alignment.center,
                                                elevation: 10,
                                                child: Container(height: 150,width: 100,
                                                decoration: BoxDecoration(color: Color.fromARGB(255, 19, 18, 18),borderRadius: BorderRadius.circular(15)),
                                                child:Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    Padding(padding: EdgeInsets.all(10),child: 
                                                    Text("RSVP to $Event_title by $C_name ",style: TextStyle(color: Color.fromARGB(188, 215, 212, 212)),),),
                                                    Padding(padding: EdgeInsets.all(10),
                                                    child:Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        TextButton(onPressed: ()async{
                                                        String state = await  rsvp(eventId: eventIds[index2]);
                                                        if (state == "Success") {
                                                          showsnackbar(context, "Successfully rsvp'd to $Event_title");
                                                        }else{print(state);}
                                                        Navigator.pop(context);
                                                        }, child: Text("YES",style: TextStyle(color: const Color.fromARGB(144, 255, 255, 255)),)),
                                                        TextButton(onPressed: (){
                                                          Navigator.pop(context);
                                                        }, child: Text("Cancel",style: TextStyle(color:  Color.fromARGB(144, 255, 255, 255)),))
                                                      ],
                                                    ) ,)
                                                  ],
                                                ) ,
                                                ),
                                              );
                                            });
                                          }, child: Container(decoration: BoxDecoration(color: Colors.blue,
                                          borderRadius: BorderRadius.circular(8)
                                          ),
                                          child:const Padding(
                                            padding:  EdgeInsets.all(8.0),
                                            child: Text("RSVP",style: TextStyle(color: Colors.white,fontSize: 16,fontStyle: FontStyle.italic,),),
                                          ),
                                          )
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 250,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: event_imgs.length,
                                          itemBuilder: (context, imgno) {
                                           Uint8List E_img = event_imgs[imgno];
                                                return Container(
                                                  padding:
                                                    const  EdgeInsets.all(5),
                                                 child: Image(image: MemoryImage(E_img)),
                                                );
                                             
                                           
                                          }),
                                    ),
                                    Container(
                                      height: 50,
                                      child: Row(
                                        children: [
                                          //like button
                                          IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.thumb_up_alt_outlined,
                                                color: Color.fromARGB(
                                                    255, 108, 105, 105),
                                              ))
                                          //comment field
                                          ,
                                          IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.comment,
                                                color: Color.fromARGB(
                                                    255, 99, 95, 95),
                                              ))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomLeft,
                                      child: const Text(
                                        "About the event .....",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ));
                          },
                        );
                        
                      });
                })
          ],
        ),
      ),
    ));
  }
}
