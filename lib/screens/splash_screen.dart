import 'dart:developer';
import 'package:chat/main.dart';
import 'package:chat/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isAnimate = true;
        });
        
        if (AuthService.auth.currentUser != null) {
          log('\nUser: ${AuthService.auth.currentUser}');
          log('\nUserAdditionalInfo: ${FirebaseAuth.instance.currentUser}');
          context.go('/home');
        } else {
          context.go('/login');
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
          title: const Text("Welcome to Chat App"),
        ),
        body: Stack(
          children: [
            AnimatedPositioned(
                top: mq.height * 0.15,
                width: mq.width * 0.5,
                right: isAnimate ? mq.width * 0.25 : -mq.width * 0.5,
                duration: const Duration(seconds: 3),
                child: Image.asset('images/icon.png')),
          ],
        ));
  }
}
