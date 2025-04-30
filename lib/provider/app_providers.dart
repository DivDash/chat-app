import 'package:chat/models/chat_user.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StreamProvider<User?>((ref) {
  return AuthService.auth.authStateChanges();
});

final userProvider = StreamProvider<ChatUser?>((ref) {
  final authState = ref.watch(authProvider);
  
  return authState.when(
    data: (user) async* {
      if (user == null) {
        yield null;
      } else {
        final chatUser = await DatabaseService.fetchPersonalInfo();
        if (chatUser != null) {
          yield chatUser;
        } else {
          yield ChatUser(
            image: user.photoURL ?? '',
            name: user.displayName ?? '',
            email: user.email ?? '',
            about: 'Hey, I am using Chat App',
            createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
            id: user.uid,
            lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
            isOnline: true,
            pushToken: ''
          );
        }
      }
    },
    loading: () async* {
      yield null;
    },
    error: (_, __) async* {
      yield null;
    },
  );
}); 