
  import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/login_screen.dart';

FloatingActionButton SignOutBtn(BuildContext context) {
    return FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        onPressed: () async {
          await AuthService.auth.signOut().then((value) async {
            await GoogleSignIn().signOut().then((value) {
              //for hiding the current screen
              Navigator.pop(context);

              //for navigating to the home screen
              Navigator.pop(context);

              //replacing the current screen with the login screen
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => LoginScreen()));
            });
          });
        },
        icon: Icon(Icons.logout),
        label: Text("Logout"),
      );
  }