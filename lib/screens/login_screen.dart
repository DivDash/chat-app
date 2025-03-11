import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../API/api.dart';
import '../helper/dialogs.dart';
import '../main.dart';
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
    signInWithGoogle().then((user) async {
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');
        if ((await Api.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else {
          await Api.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
              // serverClientId:
              //     '230242789252-f9435ljrja4toate4qtpiq4b46o552m0.apps.googleusercontent.com'
                  )
          .signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await Api.auth.signInWithCredential(credential);
    } catch (e) {
      log('\nsignInWithGoogle: $e');
      Dialogs.showSnackbar(
          context, 'Something went wrong (check internet connection!)');
      return null;
    }
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
