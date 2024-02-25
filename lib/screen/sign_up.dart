import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanout/screen/log_in.dart';


class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email, _password, _name, _confirmPassword;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (input) => input == null || input.isEmpty ? 'Please enter your name' : null,
                onSaved: (input) => _name = input,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextFormField(
                validator: (input) => input == null || input.isEmpty ? 'Please enter an email' : null,
                onSaved: (input) => _email = input,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                controller: _passwordController,
                validator: (input) => input == null || input.length < 6 ? 'Your password needs to be at least 6 characters' : null,
                onSaved: (input) => _password = input,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              TextFormField(
                validator: (input) => input != _passwordController.text ? 'Passwords do not match' : null,
                onSaved: (input) => _confirmPassword = input,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signUp,
                child: Text('Sign Up'),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Log_in()));
                },
                child: Text('Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signUp() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );

        String userUid = userCredential.user!.uid;

        await _firestore.collection('users').doc(userUid).set({
          'uid': userUid,
          'name': _name!,
          'email': _email!,
        });

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Log_in()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
