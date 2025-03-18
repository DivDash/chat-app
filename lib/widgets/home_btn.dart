import 'package:flutter/material.dart';

IconButton HomeButton(BuildContext context) {
    return IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        );
  }