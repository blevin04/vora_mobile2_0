import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
         backgroundColor: const Color.fromARGB(
          255,
          29,
          36,
          45,
        ),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, 
        icon:const Icon(Icons.arrow_back,color: Colors.white,)),
      ),
      body: SingleChildScrollView(
        
        child: Column(
          children: [
            Center(
             child:  SvgPicture.asset(
            'lib/assets/vora.svg',
            semanticsLabel: 'VORA',
            height: 60,
            width: 80,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child:  Text("Vora is an application based on the web app vora, the application is aimed at facilitating community engagements among students ",
              style: TextStyle(color: Colors.white),) ,
              ),
             const Center(
                child: Text("A karanjaJames Product",
                style: TextStyle(color: Colors.white),),
              ),
              const Center(
                child: Text("@2024",style: TextStyle(color: Colors.white),),
              )
          ],
        ),
      ),
    );
  }
}