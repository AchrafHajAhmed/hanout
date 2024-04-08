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
        centerTitle: true,
        title: Image.asset('assets/logo.png',
          height: 50,),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              const Text (
                'Sign Up',
                style:  TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                  fontSize: 32.0,
                ),
              ),
              SizedBox(height: 20),
              MyTextFormField(
                hintText: 'Name',
                onSaved: (input) => _name = input,
                validator: (input) =>
                input == null || input.isEmpty ? 'Please enter a name' : null,
              ),
              SizedBox(height: 20),
              MyTextFormField(
                hintText: 'Email',
                onSaved: (input) => _email = input,
                validator: (input) =>
                input == null || input.isEmpty ? 'Please enter an email' : null,
              ),
              SizedBox(height: 20),
              MyTextFormField(
                controller: _passwordController,
                hintText: 'Password',
                onSaved: (input) => _password = input,
                validator: (input) => input == null || input.length < 6
                    ? 'Your password needs to be at least 6 characters'
                    : null,
                obscureText: true,
              ),
              SizedBox(height: 20),
              MyTextFormField(
                hintText: 'Confirm Password',
                validator: (input) =>
                input != _passwordController.text ? 'Passwords do not match' : null,
                obscureText: true,
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                  checkColor: Colors.white,
                  activeColor: Colors.black,
                ),
                const Expanded(
                  child: Text(
                    'Yes, I want to receive discounts, loyalty offers and other updates.',
                    style: TextStyle(
                    ),
                  ),
                ),
              ],
            ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    child: Image.asset('assets/logo.png', height: 50),
                  ),
                  const SizedBox(height: 25,),
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
              MyElevatedButton(
                buttonText: 'Sign Up',
                onPressed: () async {
                  SignUp();
                },
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Need An Account? '),
                    MyTextButton(
                      buttonText:'Sign In',
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                      },
                    ),])
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
