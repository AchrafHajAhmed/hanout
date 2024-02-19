import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screen/sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyA_EVOLj6vIZTJ8cThFfyk7gKl6MEWhOTU',
      appId: '1:933084221712:android:2683898f417ab0186a5595',
      messagingSenderId: '933084221712',
      projectId: 'hanout-a372e',
    ),
  );
  runApp(SignUpApp());
}

class SignUpApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignUpPage(),
    );
  }
}
