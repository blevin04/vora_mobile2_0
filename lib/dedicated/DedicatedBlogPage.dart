import 'package:flutter/material.dart';

class Dedicatedblogpage extends StatelessWidget {
  const Dedicatedblogpage({super.key});


  @override
  Widget build(BuildContext context) {
    double scale = 0.98;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(onPressed: ()async=> Navigator.pop(context), 
        icon:const Icon(Icons.arrow_back,color: Colors.white,)),
        title:const Text("Blog Title",style: TextStyle(color: Colors.white),),
        
      ),
      body: 
      StatefulBuilder(
        builder: (BuildContext context, setState) {
         
          return  AnimatedScale(scale: scale, duration:const Duration(milliseconds: 1000),
          onEnd: (){
            if(scale == 1){
              scale = 0.95;
            }else{
              scale = 1;
            }
            setState((){});
          },
          curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(210, 91, 90, 90),
            borderRadius: BorderRadius.circular(10)
          ),
          height: 200),
      ));
        },
      ),
     
    );
  }
}