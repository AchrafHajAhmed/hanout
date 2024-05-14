import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screen/splash_screen.dart';
import 'package:hanout/Commercants/Commercants_no_verifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyA_EVOLj6vIZTJ8cThFfyk7gKl6MEWhOTU',
      appId: '1:933084221712:android:2683898f417ab0186a5595',
      messagingSenderId: '933084221712',
      projectId: 'hanout-a372e',
        storageBucket: 'hanout-a372e.appspot.com',
    ),
  );
  runApp(splashscreenApp());
}


class splashscreenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hanout',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

