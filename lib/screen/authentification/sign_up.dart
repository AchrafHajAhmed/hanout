import 'package:flutter/material.dart';
import 'package:hanout/screen/authentification/log_in.dart';
import 'package:hanout/widget/text_button.dart';
import 'package:hanout/screen/services/auth.dart';
import 'package:hanout/widget/text_form_field.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'package:hanout/screen/acceuil.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final Auth _auth = Auth();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email, _password, _name, _confirmPassword;
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool? isChecked = false;

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
              Image.asset('assets/eee.png'),
              MyTextFormField(
                labelText: 'Name',
                onSaved: (input) => _name = input,
                validator: (input) =>
                input == null || input.isEmpty ? 'Please enter a name' : null,
              ),
              MyTextFormField(
                labelText: 'Email',
                onSaved: (input) => _email = input,
                validator: (input) =>
                input == null || input.isEmpty ? 'Please enter an email' : null,
              ),
              MyTextFormField(
                controller: _passwordController,
                labelText: 'Password',
                onSaved: (input) => _password = input,
                validator: (input) => input == null || input.length < 6
                    ? 'Your password needs to be at least 6 characters'
                    : null,
                obscureText: true,
              ),
              MyTextFormField(
                labelText: 'Confirm Password',
                validator: (input) =>
                input != _passwordController.text ? 'Passwords do not match' : null,
                obscureText: true,
              ),
              Checkbox(value: isChecked,
                  activeColor: Colors.blueAccent,
                  tristate: true,
                  onChanged: (newBool){
                setState(() {
                  isChecked = newBool;
                });
                  }
              ),
              SizedBox(height: 20),
              MyElevatedButton(elevatedbutton: 'Sign Up', onPressed: SignUp ),
              MyTextButton(
                buttonText: 'Log in',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LogIn()),
                  );
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
      ),
    );
  }

  void SignUp() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        var userCredential = await _auth.createUserWithEmailAndPassword(
          _email!,
          _password!,
        );
        String userUid = userCredential.user!.uid;
        await _auth.addUserToFirestore(userUid, _name!, _email!);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LogIn()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
