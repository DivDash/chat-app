import 'dart:math';
import 'package:chat/services/database_service.dart';
import 'package:flutter/material.dart';
import '../helpers/toast_message.dart';

Future<dynamic> AddNewPersonDialog(BuildContext context, String email) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
            contentPadding: const EdgeInsets.only(
                left: 20, right: 20, top: 20, bottom: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(
                  Icons.person_add,
                  size: 28,
                ),
                Text("Enter Email"),
              ],
            ),
            content: TextFormField(
              maxLines: 1,
              onChanged: (value) => email = value,
              decoration: InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (email.isNotEmpty) {
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await DatabaseService.addChatUser(
                              email, DatabaseService.user.uid)
                          .then((value) {
                        if (!value) {
                          ToastMessage()
                              .toastMessage('User does not exist!, $e');
                        }
                      });
                    }
                  }
                },
                child: Text('Add'),
              ),
            ],
          ));
  }
