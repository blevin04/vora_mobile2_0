import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vora_mobile/Accounts.dart';

import 'package:vora_mobile/blogs.dart';
import 'package:vora_mobile/utils.dart';

class Dedicatedblogpage extends StatelessWidget {
  final blogId;
  const Dedicatedblogpage({super.key,required this.blogId});


  @override
  Widget build(BuildContext context) {
    TextEditingController blogcommentcontroller = TextEditingController();
    String blogTitle = blogsdata[blogId]!["Title"];
   // String userFullName = blogsdata[blogId]!["UserName"];
    String userNick = blogsdata[blogId]!["NickName"];
    DateTime postTimes = blogsdata[blogId]!["PostTime"].toDate();
    String blogpostcontent = blogsdata[blogId]!["BlogPost"];
    List<dynamic> postImgs = blogsdata[blogId]!["Images"];
    Map<String,dynamic> postComments = blogsdata[blogId]!["Comments"];
    List PostLikes = blogsdata[blogId]!["Likes"];
    Uint8List postOwnerImage = blogsdata[blogId]!["UserDp"];
    bool commented = false;
    postComments.forEach((key, value) {
      if (value.containsValue(userData["nickname"])) {
        commented = true;
      }
    },);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(onPressed: ()async=> Navigator.pop(context), 
          icon:const Icon(Icons.arrow_back,color: Colors.white,)),
          title: Text(blogTitle,style:const TextStyle(color: Colors.white),),
          
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                child: Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: CircleAvatar(
                                                  backgroundImage: MemoryImage(postOwnerImage),
                                                ),
                          ),
                    Column(
                      
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("$userNick ",style:const TextStyle(
                      color: Colors.white
                    ),),
                    Text(period(postTimes),style: const TextStyle(color: Colors.white),)
                      ],
                    ),
                        ],
                      ),
                       
                    IconButton(onPressed: (){
                      String sharedmessage = "Author: $userNick \n Title: $blogTitle \n $blogpostcontent \n to view refernces and more posts download the vora mobile app or visit vora web. ";
                      Clipboard.setData(ClipboardData(text: sharedmessage));
                    }, 
                    icon:const Icon(Icons.share,color: Colors.white,))
                    ],
                  ),
                  // child: ListTile(
                  //   minTileHeight: 50,
                    
                  //   leading: CircleAvatar(
                  //     backgroundImage: MemoryImage(postOwnerImage),
                  //   ),
                  //   title: Text("$userFullName ",style:const TextStyle(
                  //     color: Colors.white
                  //   ),),
                  //   // trailing: Row(
                  //   //   children: [
                  //   //     Text(period(postTimes),style:const TextStyle(color: Colors.white),),
                  //   //     IconButton(onPressed: (){}, icon:
                  //   //     const Icon(Icons.share,color: Colors.white,))
                  //   //   ],
                  //   // ),
                  // ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(blogpostcontent,style:const TextStyle(color: Colors.white),),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height/2,
                child: ListView.builder(
                  itemCount: postImgs.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding:const EdgeInsets.all(10),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration: BoxDecoration(
                         color: const Color.fromARGB(117, 40, 39, 39),
                        borderRadius: BorderRadius.circular(10)
                      ),
                     
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Image(image: MemoryImage(postImgs[index])),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    child: TextButton(onPressed: (){}, 
                    child:const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Text("Attached resorces",style: TextStyle(color: Colors.white),),
                      Icon(Icons.exit_to_app,color: Colors.white,)
                    ],))
                    
                    ),
                    StatefulBuilder(
                      builder: (BuildContext context, setStateinter) {
                        return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Badge(
                        backgroundColor: Colors.transparent,
                        offset:const Offset(5, 25),
                        label: Text(PostLikes.length.toString()),
                        child: IconButton(onPressed: (){
                          likePost(blogId);
                          setStateinter((){
                            if (PostLikes.contains(user.uid)) {
                              PostLikes.remove(user.uid);
                            }else{
                              PostLikes.add(user.uid);
                            }
                            
                          });
                          
                        }, icon:
                          Icon(Icons.thumb_up,color: PostLikes.contains(user.uid)?Colors.blue:Colors.white,)
                          ),
                      ),
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Badge(
                            backgroundColor: Colors.transparent,
                            offset: const Offset(5, 25),
                            label: Text(postComments.length.toString()),
                            child: IconButton(onPressed: (){}, icon: 
                            Icon(Icons.comment,color: commented? Colors.blue:Colors.white,)
                            ),
                          ),
                        )
                    ],
                  );
                      },
                    ),
                ],
              ),
              Container(
                padding:const EdgeInsets.all(5),
                constraints: BoxConstraints(maxHeight: 90,maxWidth: MediaQuery.of(context).size.width),
               child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   SizedBox(
                    height: 50,
                    width: 200,
                     child: TextField(
                      expands: true,
                      maxLines: null,
                      minLines: null,
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
                                  controller: blogcommentcontroller,
                                    ),
                   ),
                          IconButton(onPressed: (){
                            commentpost(blogId, blogcommentcontroller.text);
                            
                          }, 
                          icon:const Icon(Icons.send,color: Colors.blue,)
                          
                          )
                 ],
               ),
              ),
              StreamBuilder(
                stream: firestore.collection("posts").doc(blogId).snapshots(),
                initialData: postComments,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                
                 
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center( child: CircularProgressIndicator(),);
                  }
                  if (snapshot.hasData) {
                      postComments = snapshot.data["Comments"];
                  }
                   List postCommentKeys = postComments.keys.toList();
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: postComments.length,
                    itemBuilder: (BuildContext context, int index) {
                      String comment = postComments[postCommentKeys[index]]["Comment"];
                      String postcomOwner = postComments[postCommentKeys[index]]["UserName"];
                      List postcommentLikes = postComments[postCommentKeys[index]]["Likes"];
                      DateTime postcommentTime = postComments[postCommentKeys[index]]["TimeStamp"].toDate();
                      return  Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(color: const Color.fromARGB(164, 65, 65, 66),borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Text(postcomOwner,style:const TextStyle(color: Colors.white,fontSize: 16),),
                                title: Text(period(postcommentTime),style:const TextStyle(color: Colors.white,fontSize: 10),),
                                trailing: Badge(
                                  backgroundColor: Colors.transparent,
                                  offset:const Offset(-5,20),
                                 // alignment: Alignment.bottomRight,
                                  label: Text(postcommentLikes.length.toString(),style:const TextStyle(color: Colors.white),),
                                  child: IconButton(onPressed: (){
                                    likecomment("posts", blogId, postCommentKeys[index]);
                  
                                  }, icon: Icon(Icons.favorite,color:postcommentLikes.contains(user.uid)?const Color.fromARGB(255, 255, 17, 0): Colors.white,size: 18,))),
                              ),
                              Container(
                                padding:const EdgeInsets.only(left: 10,bottom: 8,right: 10),
                                alignment: Alignment.bottomLeft,
                                child: Text(comment,style:const TextStyle(color: Colors.white),)),
                              
                            ],
                          ),
                        ),
                      )  ;
                    },
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