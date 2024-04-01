import 'package:flutter/material.dart';
import 'package:hanout/screen/acceuil.dart';
import 'package:hanout/screen/authentification/sign_up.dart';
import 'package:hanout/screen/services/auth.dart';
import 'package:hanout/widget/text_form_field.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'package:hanout/widget/text_button.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Auth _auth = Auth();
  bool _isLoading = false;

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userCredential = await _auth.signInWithGoogle();
      if (userCredential != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Acceuil()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Sign-In cancelled')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing in with Google: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading) ...[
              Center(child: CircularProgressIndicator()),
            ],
            Image.asset('assets/eee.png'),
            MyTextFormField(
              labelText: 'Email',
              controller: emailController,
            ),
            MyTextFormField(
              labelText: 'Mot de passe',
              controller: passwordController,
              obscureText: true,
            ),
            MyTextButton(
              buttonText: 'Forget Your Password?',
              onPressed: () {
              },
            ),
            SizedBox(height: 20),
            Text('OR', textAlign: TextAlign.center),
            SizedBox(height: 20),
            MyElevatedButton(
              elevatedbutton: 'Log In',
              onPressed: () async {
                try {
                  await _auth.signInWithEmailAndPassword(
                    emailController.text,
                    passwordController.text,
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Acceuil()));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de connexion: $e')));
                }
              },
            ),
            MyTextButton(
              buttonText: 'Sign Up',
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUp()));
              },
            ),
            InkWell(
              onTap: _signInWithGoogle,
              child: Padding(
                padding: EdgeInsets.all(1.0),
                child: SizedBox(
                  width: 100,
                  height: 50,
                  child: Image.asset('assets/google.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
