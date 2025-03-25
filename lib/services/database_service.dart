import 'dart:developer';
import 'package:chat/services/auth_service.dart';
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


   //for Login Screen => else (get user reference) to store the id of new user at firestore database => use in else condition in (users)
   static DatabaseReference getUserRef(String userId) =>
      database.ref('users').child(userId);

  // for Login Screen
  //if user exists 
   static Future<bool> userExists(String userId) async {
    try {
      final snapshot = await fetchData(database.ref('users').child(userId));
      return snapshot.exists;
    } catch (e) {
      logError('userExists', e);
      return false;
    }
  }

  //for login screen => else (if user does not exists) so {create a new user}
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



  //for Home Screen => Add ChatUser Dialog => for adding a person in my chatbox via email
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

  //for Home Screen => in stream builder (for get all my chat users from getuserref to get users reference from firestore databse 'users'
  // and store in my_users)
  static Stream<DatabaseEvent> getMyUsers() =>
      getUserRef(user.uid).child('my_users').onValue;

  //Home Screen => in 2nd stream builder ( for get all users from my_users and show in order by child id)
  static Stream<DatabaseEvent> getAllUsers(List<String> userIds) =>
      database.ref('users').orderByChild('id').onValue;





    //Chat Screen => for fetching all messages with specific user 
  static Stream<DatabaseEvent> getAllMessages(ChatUser user) =>
      database.ref('chats/${getConversationID(user.id)}/messages/').onValue;

    // for get the specific chat reference for chatscreen => message card (blue screen) 
              // for get the specific chat id
               static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
                 ? '${user.uid}_$id'
                 : '${id}_${user.uid}';

              //for get the chat reference
               static DatabaseReference getChatRef(String chatId) =>
                database.ref('chats').child(chatId);
  
    
    //chat screen => message card => blue message (other user opposite to me) for update the read status of message
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

   //chat screen => for send message button logic
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      final Message message = Message(
          fromId: user.uid,
          msg: msg,
          read: '',
          sent: time,
          told: chatUser.id,
          type: type);

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

// ProfileScreen => for get the user profile 

  static Future<ChatUser?> fetchPersonalInfo() async {
    try {
      final snapshot = await fetchData(getUserRef(user.uid));
      if (snapshot.exists) {
        final data = snapshotToMap(snapshot)!;
        return ChatUser.fromJson(data);
      }
    } catch (e) {
      logError('fetchPersonalInfo', e);
    }
    return null;
  }

  // Existing helper functions
  
  static Map<String, dynamic>? snapshotToMap(DataSnapshot snapshot) {
    if (!snapshot.exists) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  // Existing stream functions
  //for chat screen => for get all messages with specific user
  static Stream<DatabaseEvent> getMessages(ChatUser chatUser) =>
      getChatRef(getConversationID(chatUser.id)).child('messages').onValue;
  
  static Future<void> updateUserInfo(ChatUser updatedUser) async {
    try {
      await getUserRef(user.uid).update({
        'name': updatedUser.name,
        'about': updatedUser.about,
      });
    } catch (e) {
      logError('updateUserInfo', e);
      rethrow;
    }
  }
}
