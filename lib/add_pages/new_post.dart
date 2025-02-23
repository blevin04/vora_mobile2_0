// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vora_mobile/dedicated/DedicatedBlogPage.dart';

import 'package:vora_mobile/firebase_Resources/add_content.dart';
import 'package:vora_mobile/utils.dart';

class NewPost extends StatefulWidget {
  const NewPost({super.key});

  @override
  State<NewPost> createState() => _NewPostState();
}

TextEditingController post = TextEditingController();
TextEditingController postTitleController = TextEditingController();
List<String> imgs = List.empty(growable: true);
String doc = '';

class _NewPostState extends State<NewPost> {
  @override
  // void dispose() {
  //   post.dispose();
  //   doc = '';
  //   imgs = List.empty(growable: true);
  //   super.dispose();
  // }

  @override
  void initState() {
    super.initState();
    post.clear();
    doc = '';
    imgs = List.empty(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    double windowWidth = MediaQuery.of(context).size.width;
    double windowheight = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
          255,
          29,
          36,
          45,
        ),
        leading: IconButton(
            onPressed: () async{
             Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Padding(
          padding: const EdgeInsets.only(left: 20.0,bottom: 15,top: 8),
          child: SvgPicture.asset(
              'lib/assets/vora.svg',
              semanticsLabel: 'VORA',
              height: 40,
              width: 60,
            ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  "New Blog Post",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
              
               
               Container(
                constraints:
                    BoxConstraints(maxHeight: windowheight / 1.5, minHeight: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color.fromARGB(255, 107, 105, 105))),
                child: TextField(
                  decoration:const InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: "Post Title"
                  ),
                  maxLines: null,
                  // expands: true,
                  style: const TextStyle(color: Colors.white),
                  controller: postTitleController,
                ),
              ),
               const SizedBox(height: 20,),
              
                Container(
                constraints:
                    BoxConstraints(maxHeight: windowheight / 1.5, minHeight: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color.fromARGB(255, 107, 105, 105))),
                child: TextField(
                  decoration:const InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: "Post Content"
                  ),
                  maxLines: null,
                  // expands: true,
                  style: const TextStyle(color: Colors.white),
                  controller: post,
                ),
              ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(10)),
                        child: IconButton(
                            onPressed: () async {
                               Permission.accessMediaLocation
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
                              FilePickerResult? result =
                                  (await FilePicker.platform.pickFiles(
                                      type: FileType.image,
                                      allowMultiple: true));

                              if (result != null) {
                                for (var i = 0; i < result.files.length; i++) {
                                  setState(() {
                                    imgs.add(result.files[i].path!);
                                  });
                                }
                              }
                              if (result == null) {
                                showsnackbar(context, 'no image chossen');
                              }
                            },
                            icon:const Icon(
                              Icons.add_a_photo_outlined,
                              color: Colors.white,
                            ))),
                    const SizedBox(
                      width: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          borderRadius: BorderRadius.circular(10)),
                      child: IconButton(
                          onPressed: () async {
                             Permission.accessMediaLocation
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
                            FilePickerResult? result =
                                (await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: [
                                      'pdf',
                                      'doc',
                                      'xls',
                                      "ppt",
                                      "txt",
                                      "pptx",
                                      "xlsx",
                                    ],
                                    allowMultiple: false));
                            if (result != null) {
                             
                              showsnackbar(context, "documents added");
                              setState(() {
                                 doc = result.files.single.path!;
                              });
                            }
                            if (result == null) {
                              showsnackbar(context, 'no image chossen');
                            }
                          },
                          icon: const Icon(
                            Icons.note_add_outlined,
                            color: Colors.white,
                          )),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Visibility(
                    visible: doc.isNotEmpty,
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 84, 83, 83),
                          ),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          doc.isNotEmpty
                              ? doc.split("/")[doc.split("/").length - 1]
                              : "",
                          style:const TextStyle(color: Colors.white),
                        ),
                      ),
                    )),
                const SizedBox(
                  height: 10,
                ),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  children: List.generate(imgs.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        alignment: Alignment.topRight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                              image: FileImage(File(imgs[index]))),
                        ),
                        child: IconButton(onPressed: (){
                          imgs.removeAt(index);
                          setState(() {
                            
                          });
                        }, icon:const Icon(Icons.delete_outline_outlined,color: Color.fromARGB(255, 143, 140, 140),)),
                      ),
                    );
                  }),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: InkWell(
                    onTap: () async {
                      if (post.text.isEmpty && postTitleController.text.isEmpty) {
                        showsnackbar(context, "Fill all boxes...");
                      } else {
                        List state = [];
                        while (state.isEmpty) {
                          showcircleprogress(context);
                          if (doc.isNotEmpty && imgs.isNotEmpty) {
                            state = await Addpost(
                                desc: post.text, images: imgs, docs: doc,
                                title: postTitleController.text);
                          }
                          if (doc.isEmpty && imgs.isEmpty) {
                            state = await Addpost(desc: post.text,title: postTitleController.text);
                          }
                          if (doc.isNotEmpty && imgs.isEmpty) {
                            state = await Addpost(desc: post.text, docs: doc,
                            title: postTitleController.text
                            );
                          }
                          if (imgs.isNotEmpty && doc.isEmpty) {
                            state =
                                await Addpost(desc: post.text, images: imgs,
                                title: postTitleController.text
                                );
                          }
                          print(state);
                        }
                        if (state[0] == "Success") {
                          postTitleController.clear();
                          post.clear();
                          doc = "";
                          imgs.clear();
                          Navigator.pop(context);
                         await Navigator.pushReplacement(context, 
                          (MaterialPageRoute(builder: (context)=> Dedicatedblogpage(blogId:state.last ,))));
                          }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      //margin: const EdgeInsets.all(5),
                      width: windowWidth / 2.2,
                      decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(10)),
                      child:const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.publish,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Publish",
                            style:
                                TextStyle(color: Colors.white, fontSize: 15),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
