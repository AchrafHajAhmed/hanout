import 'package:flutter/material.dart';
import 'package:hanout/screen/acceuil.dart';
import 'package:hanout/screen/sign_up.dart';
import 'package:hanout/widget/text_form_field.dart';
import 'package:hanout/widget/text_button.dart';
import 'package:hanout/auth.dart';
import 'package:hanout/widget/elevated_button.dart';

class Log_in extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final auth _auth = auth();

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
            MyTextFormField(
              labelText: 'Email',
              controller: emailController,
            ),
            MyTextFormField(
              labelText: 'Mot de passe',
              controller: passwordController,
              obscureText: true,
            ),
            SizedBox(height: 20),
            MyElevatedButton(elevatedbutton: 'Log In', onPressed:
                () async {
                try {
                  await _auth.signInWithEmailAndPassword(
                    emailController.text,
                    passwordController.text,
                  );
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => acceuil()));
                } catch (e) {
                  print('Error signing in: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur de connexion')));
                }
              },
            ),
            MyTextButton(
              buttonText: 'Sign Up',
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignUp()));
              },
            )
          ],
        ),
      ),
    );
  }
}
