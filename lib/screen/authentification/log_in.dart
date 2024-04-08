import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanout/screen/acceuil.dart';
import 'package:hanout/screen/authentification/sign_up.dart';
import 'package:hanout/widget/text_form_field.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'package:hanout/widget/text_button.dart';
import 'package:hanout/color.dart';
import 'package:hanout/screen/services/auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  final Auth _auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png',
          height: 50,),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              Center(child: CircularProgressIndicator()),
            ],
            SizedBox(height: 20),
            const Text (
              'Sign In',
              style:  TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w900,
                fontSize: 32.0,
              ),
            ),
            SizedBox(height: 20),
            MyTextFormField(
              hintText: 'Email',
              controller: emailController,
            ),

            SizedBox(height: 20),
            MyTextFormField(
              hintText: 'Mot de passe',
              controller: passwordController,
              obscureText: true,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: MyTextButton(
                buttonText: 'Forget Your Password?',
                onPressed: () {
                },
              ),
            ),
    Text('OR',
    style: TextStyle(color: Color(0xFF757373),
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w900,
    fontSize: 16.0,
    ),
    textAlign: TextAlign.center),
            SizedBox(height: 20),
            const Row(
              children: <Widget>[
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child:

                      Text('Sign In Using')),
                  Expanded(
                  child: Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 25,),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centre les boutons sur la ligne
              children: [
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isLoading = false;
                    });
                    final userCredential = await _auth.signInWithFacebook();
                    if (userCredential != null) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Acceuil()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Facebook Sign-In cancelled or failed')));
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  child: Image.asset('assets/facebook.png', height: 50),
                ),
                const SizedBox(width: 10,),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isLoading = false;
                    });
                    final userCredential = await _auth.signInWithGoogle();
                    if (userCredential != null) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Acceuil()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Sign-In cancelled or failed')));
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  child: Image.asset('assets/google.png', height: 50),
                ),
              ],
            ),
            SizedBox(height: 20),
            MyElevatedButton(
              buttonText: 'Log In',
              onPressed: () async {
                setState(() => _isLoading = false);
                try {
                  await _auth.signInWithEmailAndPassword(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Acceuil()));
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de connexion: ${e.message}')));
                } finally {
                  setState(() => _isLoading = false);
                }
              },
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Need An Account? '),
                  MyTextButton(
                    buttonText:'Sign Up',
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUp()));
                    },
                  ),])
          ],
        ),
      ),
    );
  }
}