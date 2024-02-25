import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanout/screen/acceuil.dart';
import 'package:hanout/screen/sign_up.dart';
import 'package:hanout/widget/textfromfield.dart';
import 'package:hanout/widget/textbutton.dart';

class Log_in extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20), 
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  User? user = userCredential.user;
                  print('User signed in: $user');

                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => acceuil()));
                } catch (e) {
                  print('Error signing in: $e');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de connexion')));
                }
              },
              child: Text('Se connecter'),
            ),
            textbutton(buttonText: 'Sign Up',
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUp()));
      },
            )
          ],
        ),
      ),
    );
  }
}
