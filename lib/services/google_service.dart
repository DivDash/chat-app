import 'dart:developer';
import 'package:chat/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../helpers/toast_message.dart';

class GoogleService {
  
  GoogleService._();
  
  static final GoogleService instance = GoogleService._();

  static Future<UserCredential?> signInWithGoogle() async {
    try {
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
      return await AuthService.auth.signInWithCredential(credential);
    } catch (e) {
      log('\nsignInWithGoogle: $e');
      ToastMessage().toastMessage('Something went wrong (check internet connection!)');
      return null;
    }
  }

}