
import 'package:chat/services/storage_service.dart';
import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';

IconButton VerticalDots(BuildContext context) {
    return IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfileScreen(user: StorageService.selfUser)));
            },
          );
  }
