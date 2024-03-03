import 'package:flutter/material.dart';
import 'package:hanout/screen/log_in.dart';
import 'package:hanout/widget/text_button.dart';
import 'package:hanout/auth.dart';
import 'package:hanout/widget/text_form_field.dart';


class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final auth _auth = auth();
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signUp,
                child: Text('Sign Up'),
              ),
              MyTextButton(
                buttonText: 'Log in',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Log_in()),
                  );
                },
              )
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
        var userCredential = await _auth.createUserWithEmailAndPassword(
          _email!,
          _password!,
        );
        String userUid = userCredential.user!.uid;
        await _auth.addUserToFirestore(userUid, _name!, _email!);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Log_in()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
