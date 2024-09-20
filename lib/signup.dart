// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:vora_mobile/firebase_Resources/auth_methods.dart';
import 'package:vora_mobile/login.dart';
import 'package:vora_mobile/utils.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

TextEditingController _email = TextEditingController();
TextEditingController _password = TextEditingController();
TextEditingController confirmpassword = TextEditingController();
TextEditingController _title = TextEditingController();
TextEditingController _name = TextEditingController();
TextEditingController _nickname = TextEditingController();

bool password_visible = true;
bool password_visible2 = true;

class _SignupState extends State<Signup> {

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    confirmpassword.dispose();
    _title.dispose();
    _name.dispose();
    _nickname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //   double _height = MediaQuery.of(context).size.height;
    double windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: DecoratedBox(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("lib/assets/sky.png"), fit: BoxFit.cover)),
        child: Center(
          child: Card(
            margin:const EdgeInsets.only(top: 50, bottom: 50),
            color: const Color.fromARGB(
              255,
              29,
              36,
              45,
            ),
            elevation: 8,
            // margin: EdgeInsets.all(80),
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              //height: _height - 200,
              alignment: Alignment.center,
              width: windowWidth - 100,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 20),
                      child: SvgPicture.asset(
                        'lib/assets/vora.svg',
                        semanticsLabel: 'VORA',
                        height: 40,
                        width: 60,
                      ),
                    ),
                    const Text(
                      "SIGN UP... ",
                      style: TextStyle(color: Colors.white),
                    ),
                    Container(
                      width: windowWidth - 120,
                      padding: const EdgeInsets.all(5),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: "Name ",
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 161, 159, 159))),
                        controller: _name,
                      ),
                    ),
                    Container(
                      width: windowWidth - 120,
                      padding: const EdgeInsets.all(5),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: "Nickname ",
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 161, 159, 159))),
                        controller: _nickname,
                      ),
                    ),
                    Container(
                      width: windowWidth - 120,
                      padding: const EdgeInsets.all(5),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: "Title ",
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 161, 159, 159))),
                        controller: _title,
                      ),
                    ),
                    Container(
                      width: windowWidth - 120,
                      padding: const EdgeInsets.all(5),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: "Email ",
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 161, 159, 159))),
                        controller: _email,
                      ),
                    ),
                    Container(
                      width: windowWidth - 120,
                      padding: const EdgeInsets.all(5),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        obscureText: password_visible,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    password_visible = !password_visible;
                                  });
                                },
                                icon: Icon(
                                  password_visible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color:
                                      const Color.fromARGB(255, 110, 108, 108),
                                )),
                            labelText: "Password",
                            labelStyle: const TextStyle(
                                color: Color.fromARGB(255, 161, 159, 159))),
                        controller: _password,
                      ),
                    ),
                    Container(
                      width: windowWidth - 120,
                      padding: const EdgeInsets.all(5),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        obscureText: password_visible2,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    password_visible2 = !password_visible2;
                                  });
                                },
                                icon: Icon(
                                  password_visible2
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color.fromARGB(255, 83, 82, 82),
                                )),
                            labelText: "Confirm Password",
                            labelStyle: const TextStyle(
                                color: Color.fromARGB(255, 161, 159, 159))),
                        controller: confirmpassword,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: InkWell(
                        onTap: () async {
                          String succes ="";
                          if (email.text.isNotEmpty &&
                              _password.text.isNotEmpty &&
                              _name.text.isNotEmpty &&
                                _title.text.isNotEmpty) {
                                  while(succes.isEmpty){
                                    showcircleprogress(context);
                                    succes = await AuthMethods().createAccount(
                              email: _email.text,
                              password: _password.text,
                              fullName: _name.text,
                              nickname: _nickname.text,
                              title: _title.text);
                                  }
                          }
                           
                          if (succes == 'success') {
                            dispose();
                            showsnackbar(context, 'Welcome');
                            Navigator.of(context).pop();
                            Navigator.pop(context);
                          } else {
                            showsnackbar(context, succes);
                            // print(succes);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(10)),
                          width: 150,
                          padding: const EdgeInsets.all(8),
                          child: const Text(
                            "SIGN UP",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const Login()));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8),
                          width: 150,
                          decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Text(
                            "LOG IN",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
