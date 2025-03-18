
import 'dart:developer';
import 'package:chat/main.dart';
import 'package:chat/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //   statusBarColor: Colors.transparent,
      //   systemNavigationBarColor: Colors.transparent,

        
      // ));
      setState(() {
        _isAnimate = true;
      });
      if (AuthService.auth.currentUser != null) {
        log('\nUser: ${AuthService.auth.currentUser}');
        log('\nUserAdditionalInfo: ${FirebaseAuth.instance.currentUser}');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
        
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Welcome to Chat App"),
        ),
        body: Stack(
          children: [
            AnimatedPositioned(
                top: mq.height * 0.15,
                width: mq.width * 0.5,
                right: _isAnimate ? mq.width * 0.25 : -mq.width * 0.5,
                duration: Duration(seconds: 3),
                child: Image.asset('images/icon.png')),
            
          ],
        ));
  }
}
