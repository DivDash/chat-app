import 'dart:developer';
import 'package:chat/main.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/services/google_service.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }
_handleGoogleBtn() {
    GoogleService.signInWithGoogle().then((user) async {
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');
        if ((await DatabaseService.userExists(user.user!.uid))) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else {
          await DatabaseService.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomeScreen()));
          });
        }
      }
    });
  }
 

  
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Welcome to Div Chat"),
        ),
        body: Stack(
          children: [
            AnimatedPositioned(
                top: mq.height * 0.15,
                width: mq.width * 0.5,
                right: _isAnimate ? mq.width * 0.25 : -mq.width * 0.5,
                duration: Duration(seconds: 1),
                child: Image.asset('images/icon.png')),
            Positioned(
                bottom: mq.height * 0.15,
                width: mq.width * 0.6,
                left: mq.width * 0.2,
                height: mq.height * 0.05,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _handleGoogleBtn();
                  },
                  icon: Image.asset(
                    'images/google.png',
                  ),
                  label: Text("Signin with Google"),
                ))
          ],
        ));
  }
}
