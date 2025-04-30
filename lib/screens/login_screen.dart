import 'dart:developer';
import 'package:chat/main.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/services/google_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isAnimate = true;
        });
      }
    });
  }

  Future<void> _handleGoogleBtn() async {
    final user = await GoogleService.signInWithGoogle();
    if (user != null && mounted) {
      log('\nUser: ${user.user}');
      log('\nUserAdditionalInfo: ${user.additionalUserInfo}');
      
      if (await DatabaseService.userExists(user.user!.uid)) {
        if (mounted) context.go('/home');
      } else {
        await DatabaseService.createUser();
        if (mounted) context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome to Div Chat"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * 0.15,
            width: mq.width * 0.5,
            right: _isAnimate ? mq.width * 0.25 : -mq.width * 0.5,
            duration: const Duration(seconds: 1),
            child: Image.asset('images/icon.png'),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            width: mq.width * 0.6,
            left: mq.width * 0.2,
            height: mq.height * 0.05,
            child: ElevatedButton.icon(
              onPressed: _handleGoogleBtn,
              icon: Image.asset('images/google.png'),
              label: const Text("Signin with Google"),
            ),
          ),
        ],
      ),
    );
  }
}
