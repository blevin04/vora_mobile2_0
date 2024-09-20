// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vora_mobile/firebase_Resources/auth_methods.dart';
import 'package:vora_mobile/signup.dart';
import 'package:vora_mobile/utils.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

TextEditingController email = TextEditingController();
TextEditingController password = TextEditingController();
bool _password_visible = true;

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    double windowwidth = MediaQuery.of(context).size.width;
    double windowheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: DecoratedBox(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("lib/assets/sky.png"), fit: BoxFit.cover)),
        child: SingleChildScrollView(
          child: Center(
            child: Card(
              margin:
                  EdgeInsets.only(top: windowheight / 3.5, bottom: windowheight / 4.8),
              color: const Color.fromARGB(
                255,
                29,
                36,
                45,
              ),
              child: SizedBox(
                height: windowheight / 2.1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 15),
                      child: SvgPicture.asset(
                        'lib/assets/vora.svg',
                        semanticsLabel: 'VORA',
                        height: 50,
                        width: 70,
                      ),
                    ),
                    const Text(
                      "Log In",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      width: windowwidth - 120,
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent)),
                      child: TextField(
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 161, 159, 159))),
                        controller: email,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: windowwidth - 120,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent)),
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        obscureText: _password_visible,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _password_visible = !_password_visible;
                                });
                              },
                              icon: Icon(
                                _password_visible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color.fromARGB(255, 116, 115, 115),
                              ),
                            ),
                            labelText: "password",
                            labelStyle:const TextStyle(
                                color: Color.fromARGB(255, 161, 159, 159))),
                        controller: password,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        String success ="";
                        if (email.text.isNotEmpty &&
                       password.text.isNotEmpty ) {
                        while(success.isEmpty){
                          showcircleprogress(context);
                          success = await AuthMethods()
                            .signIn(email: email.text, password: password.text);
                        }
                           
                        }
                        

                        if (success == "sucess") {
                          email.dispose();
                          password.dispose();
                          showsnackbar(context, "Welcome");
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 150,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 29, 82, 107),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Text(
                          "LOG IN",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const Signup())),
                      child: Container(
                        alignment: Alignment.center,
                        width: 150,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 32, 77, 97),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
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
