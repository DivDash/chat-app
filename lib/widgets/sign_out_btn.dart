import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

FloatingActionButton SignOutBtn(BuildContext context) {
  return FloatingActionButton.extended(
    backgroundColor: Colors.redAccent,
    onPressed: () async {
      await AuthService.auth.signOut();
      await GoogleSignIn().signOut();
      if (context.mounted) {
        context.go('/login');
      }
    },
    icon: const Icon(Icons.logout),
    label: const Text("Logout"),
  );
}