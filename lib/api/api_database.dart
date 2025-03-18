import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_user.dart';
import '../models/message.dart';

class ApiDatabase {
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accesseing realtime database
  static FirebaseDatabase database = FirebaseDatabase.instance;

  //for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for storing self user info
  static late ChatUser selfUser;

  static User get user => auth.currentUser!;

  //for check if user exist or not
  static Future<bool> userExists(userId) async {
    final snapshot = await database.ref('users').child(userId).get();
    return snapshot.exists;
    // return (await database
    // .ref('users')
    // .child(user.uid)
    // .get()
    // ).exists;
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
      if (userMap != null){  
      final targetUserId = userMap.keys.first;
      //ensure we are not adding ourselves
      if (targetUserId != currentUserId){
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
      } }}
      
      }
      catch (e) {
      log('Error in chatUser: $e');
    } 
    return false;
  }

  // Helper function to get chat reference
  static DatabaseReference getChatRef(String chatId) {
    return database.ref('chats').child(chatId);
  }

    //for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    try{
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
  } catch (e){
    log('Error in sending message: $e');
  }
  }

  //for getting messages
  static Stream<DatabaseEvent> getMessages(ChatUser chatUser) {
    final chatId = getConversationID(chatUser.id);
    return getChatRef(chatId)
        .child('messages')
        .onValue;
  }

 //update message read status
  static Future<void> updateMessageReadStatus(Message message) async {
    try{
    final chatId = getConversationID(message.fromId);
    await getChatRef(chatId)
        .child('messages')
        .child(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
        log('Message: ${message.sent} read updated');
  } catch (e){
    log('Error in updating message read status: $e');
  }
  }


  

  // Helper function to get user reference
  static DatabaseReference getUserRef(String userId) {
    return database.ref('users').child(userId);
  }


  // for create a new user
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
      log('Error creating User : $e');
      
    }}

// Helper function to convert DataSnapshot to Map
  static Map<String, dynamic>? snapshotToMap(DataSnapshot snapshot) {
    if (!snapshot.exists) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    try {
    final snapshot = await getUserRef(user.uid).get();
    
    if (snapshot.exists) {
      final data = snapshotToMap(snapshot)!;
      selfUser = ChatUser.fromJson(data);
    } else {
      await createUser();
      await getSelfInfo();
    }
  } catch (e){
    log('Error fetching self info: $e');
  }
  }

  
  //for getting my users
  static Stream<DatabaseEvent> getMyUsers() {
    return getUserRef(user.uid)
        .child('my_users')
        .onValue;
  }

  //for getting all users from database
  static Stream<DatabaseEvent> getAllUsers(List<String> userIds) {
    log('\nuserIds: $userIds');
    return database
        .ref('users')
        .orderByChild('id')
        //.equalTo(userIds)
        .onValue;
  }


  //for updating user info
  static Future<void> updateUserInfo() async {
    await getUserRef(user.uid).update({
      'name': selfUser.name,
      'about': selfUser.about,
      'image': selfUser.image
    });
  }

  //for update profile picture
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log('Extension: $ext');
    //uploading image to firebase storage
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //putting file to the reference
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} KB');
    });

    //getting the download url of the uploaded image
    selfUser.image = await ref.getDownloadURL();
    await getUserRef(user.uid).update({'image': selfUser.image});
  }

  ///***************** Chat Screen Related APIs *************/
  //for getting all conversations of a specific user from firestore database

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //for getting all messages of a specific conversation from firestore database
  static Stream<DatabaseEvent> getAllMessages(ChatUser user) {
    return database
        .ref('chats/${getConversationID(user.id)}/messages/')
        .onValue;
  }
}
