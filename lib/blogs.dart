import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vora_mobile/events.dart';
import 'package:vora_mobile/homepage.dart';

final store3 = FirebaseStorage.instance.ref();
final firestore = FirebaseFirestore.instance;

class Blogs extends StatefulWidget {
  const Blogs({super.key});

  @override
  State<Blogs> createState() => _BlogsState();
}

Widget blog_show = Text("Blogs");
TextEditingController search_blogs = TextEditingController();
List<String> blogIds = List.empty(growable: true);
bool _blogs_visi = false;

Future<void> getblogsid() async {
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
}

late ListResult imgsdir;
Future<void> getpostimg(int index) async {
  imgsdir = await store3.child("/posts/${blogIds[index]}").list();
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
                setState(() {
                  events_vis = !events_vis;
                });
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
            Visibility(
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
            ),
            FutureBuilder(
              future: getblogsid(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: blogIds.length,
                    itemBuilder: (context, postnum) {
                      var name;
                      Duration posttime = Duration();
                      String name_ = '';
                      String nick_name = '';
                      firestore
                          .collection("posts")
                          .doc(blogIds[postnum])
                          .get()
                          .then((onval) {
                        name = onval.data()!["UserId"];
                        var then = onval.data()!["PostTime"].toDate();
                        posttime = then.difference(DateTime.now());
                        firestore
                            .collection("users")
                            .doc(name)
                            .get()
                            .then((onValue) {
                          name_ = onValue.data()!["fullName"];
                          nick_name = onValue.data()!["nickname"];
                        });
                      });
                      return Card(
                        child: FutureBuilder(
                          future: getpostimg(postnum),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
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
                                              "$name_ / $nick_name",
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      189, 255, 255, 255)),
                                            ),
                                            Text(
                                              "${posttime.inHours}/ ${posttime.inHours}",
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
                                Container(
                                  height: 100,
                                  child: Text("Post data....."),
                                ),
                              ],
                            );
                          },
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
