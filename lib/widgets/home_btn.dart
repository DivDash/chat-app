import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

IconButton HomeButton(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.home),
    onPressed: () => context.go('/home'),
  );
}