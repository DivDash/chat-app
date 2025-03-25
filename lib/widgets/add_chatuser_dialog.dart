import 'dart:math';
import 'package:chat/services/database_service.dart';
import 'package:flutter/material.dart';
import '../helpers/toast_message.dart';

class AddChatUserDialog extends StatelessWidget {
  const AddChatUserDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        String email = '';
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            contentPadding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (email.isNotEmpty) {
                    Navigator.pop(context);
                    await DatabaseService.addChatUser(
                      email,
                      DatabaseService.user.uid,
                    ).then((value) {
                      if (!value) {
                        ToastMessage().toastMessage('User does not exist!');
                      }
                    });
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
      child: const Icon(Icons.add_comment),
    );
  }
}
