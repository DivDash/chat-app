import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat_user.dart';
import '../models/message.dart';

class Api {
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for storing self user info
  static late ChatUser selfUser;

  static User get user => auth.currentUser!;

  //for check if user exist or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      log('user exists: ${data.docs.first.data()}');
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        selfUser = ChatUser.fromJson(user.data()! //as Map<String, dynamic>
        );
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for create a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        about: "Hey, I'm using Div Chat",
        name: user.displayName.toString(),
        createdAt: time,
        id: auth.currentUser!.uid,
        lastActive: time,
        isOnline: false,
        email: user.email.toString(),
        pushToken: '');
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //for getting id's of known users from a firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  //for getting all users from the firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nuserIds: $userIds');
    return firestore
        .collection('users')
        .where('id', whereIn: userIds)
        //.where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for adding an user to my user when first mesaage sent
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendFirstMessage(chatUser, msg, type));
  }

  //for updating user info
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': selfUser.name,
      'about': selfUser.about,
      'image': selfUser.image
    });
  }

  //for update profile picture
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split(',').last;
    log('Extension: $ext');
    //uploading image to firebase storage
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //putting file to the reference
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transfered: ${p0.bytesTransferred / 1000} KB');
    });

    //getting the download url of the uploaded image
    selfUser.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': selfUser.image});
  }

  ///***************** Chat Screen Related APIs *************/
  //for getting all conversations of a specific user from firestore database

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .snapshots();
  }

  // chats (collection) --> chatId (doc) --> messages (collection) --> message(doc)
  //for sending message to a specific user
  static Future<void> sendMessage(
    ChatUser ChatUser,
    String msg,
  ) async {
    //message sending time also used as message id
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to be sent
    final Message message = Message(
        fromId: user.uid,
        msg: msg,
        read: '',
        sent: time,
        told: ChatUser.id,
        type: Type.text);

    final ref = firestore
        .collection('chats/${getConversationID(ChatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }
}
