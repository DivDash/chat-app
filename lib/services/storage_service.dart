import 'dart:developer';
import 'dart:io';

import 'package:chat/services/database_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_user.dart';

class StorageService {
  StorageService._();

  //for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for storing self user info
  static late ChatUser selfUser;

  //for updating user info
  static Future<void> updateUserInfo() async {
    await DatabaseService.getUserRef(DatabaseService.user.uid).update({
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
    final ref = storage
        .ref()
        .child('profile_pictures/${DatabaseService.user.uid}.$ext');

    //putting file to the reference
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} KB');
    });

    //getting the download url of the uploaded image
    selfUser.image = await ref.getDownloadURL();
    //await getUserRef(user.uid).update({'image': selfUser.image});
    await DatabaseService.getUserRef(DatabaseService.user.uid)
        .update({'image': selfUser.image});
  }
}
