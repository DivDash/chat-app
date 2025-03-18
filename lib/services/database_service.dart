import 'dart:developer';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/chat_user.dart';
import '../models/message.dart';

class DatabaseService {
  DatabaseService._();


  //static final DatabaseService db = DatabaseService._();
  //for accesseing realtime database
  static final database = FirebaseDatabase.instance;

  //for getting user
  static User get user => AuthService.auth.currentUser!;

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // Helper function to fetch data from a reference
  static Future<DataSnapshot> fetchData(DatabaseReference ref) async {
    try {
      return await ref.get();
    } catch (e) {
      log('Error fetching data: $e');
      rethrow;
    }
  }

  // Helper function to log errors
  static void logError(String context, dynamic error) {
    log('Error in $context: $error');
  }

  static Future<bool> userExists(String userId) async {
    try {
      final snapshot = await fetchData(database.ref('users').child(userId));
      return snapshot.exists;
    } catch (e) {
      logError('userExists', e);
      return false;
    }
  }

  //for adding a chat user for our conversation
  static Future<bool> addChatUser(String email, String currentUserId) async {
    try {
      final data = await database
          .ref('users')
          .orderByChild('email')
          .equalTo(email)
          .get();
      log('Fetched data: ${data.value}');

      //check if user exists
      if (data.exists) {
        final userMap = data.value as Map<dynamic, dynamic>?;
        if (userMap != null) {
          final targetUserId = userMap.keys.first;
          //ensure we are not adding ourselves
          if (targetUserId != currentUserId) {
            log('User Exists with Id: $targetUserId');

            //   final userMap = data.value as Map<dynamic, dynamic>?;
            // final targetUserId = userMap!.keys.first;
            // if (data.children.isNotEmpty && data.children.first.key != user.uid) {
            //   database
            //       .ref('users')
            //       .child(currentUserId)
            //       .child('my_users')
            //       .child(targetUserId).set({});
            //   return true;
            // } else{return false;}

            //Add the target user to "my_users"
            await database
                .ref('users')
                .child(currentUserId)
                .child('my_users')
                .child(targetUserId)
                .set({});
            return true;
          }
        }
      }
    } catch (e) {
      log('Error in chatUser: $e');
    }
    return false;
  }

  //for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      final Message message = Message(
          fromId: user.uid,
          msg: msg,
          read: '',
          sent: time,
          told: chatUser.id,
          type: Type.text);

      final chatId = getConversationID(chatUser.id);
      await getChatRef(chatId)
          .child('messages')
          .child(time)
          .set(message.toJson());
      log(' Message Sent ${message.toJson()}');
    } catch (e) {
      log('Error in sending message: $e');
    }
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    try {
      final chatId = getConversationID(message.fromId);
      await getChatRef(chatId)
          .child('messages')
          .child(message.sent)
          .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
      log('Message: ${message.sent} read updated');
    } catch (e) {
      logError('updateMessageReadStatus', e);
    }
  }

  static Future<void> getSelfInfo() async {
    try {
      final snapshot = await fetchData(getUserRef(user.uid));
      if (snapshot.exists) {
        final data = snapshotToMap(snapshot)!;
        StorageService.selfUser = ChatUser.fromJson(data);
      } else {
        await createUser();
        await getSelfInfo();
      }
    } catch (e) {
      logError('getSelfInfo', e);
    }
  }

  static Future<void> createUser() async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      final chatUser = ChatUser(
          image: user.photoURL.toString(),
          about: "Hey, I'm using Div Chat",
          name: user.displayName.toString(),
          createdAt: time,
          id: user.uid,
          lastActive: time,
          isOnline: false,
          email: user.email.toString(),
          pushToken: '');

      await getUserRef(user.uid).set(chatUser.toJson());
      log('User created: ${chatUser.toJson()}');
    } catch (e) {
      logError('createUser', e);
    }
  }

  // Existing helper functions
  static DatabaseReference getChatRef(String chatId) =>
      database.ref('chats').child(chatId);
  static DatabaseReference getUserRef(String userId) =>
      database.ref('users').child(userId);
  static Map<String, dynamic>? snapshotToMap(DataSnapshot snapshot) {
    if (!snapshot.exists) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  // Existing stream functions
  static Stream<DatabaseEvent> getMessages(ChatUser chatUser) =>
      getChatRef(getConversationID(chatUser.id)).child('messages').onValue;
  static Stream<DatabaseEvent> getMyUsers() =>
      getUserRef(user.uid).child('my_users').onValue;
  static Stream<DatabaseEvent> getAllUsers(List<String> userIds) =>
      database.ref('users').orderByChild('id').onValue;
  static Stream<DatabaseEvent> getAllMessages(ChatUser user) =>
      database.ref('chats/${getConversationID(user.id)}/messages/').onValue;
}
