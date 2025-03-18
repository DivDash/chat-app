import 'package:chat/firebase_options.dart';
import 'package:chat/screens/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

late Size mq;

// Determine if we're in development mode
const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'production');

Future<void> setupFirebaseEmulators() async {
  if (flavor == 'development') {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    FirebaseDatabase.instance.useDatabaseEmulator('localhost', 9000);

    // Optional: Print debug information
    debugPrint('💻 Using Firebase Emulators');
  } else {
    debugPrint('🔥 Using Production Firebase');
  }
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform);

  await setupFirebaseEmulators();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen()
    );
  }
}
