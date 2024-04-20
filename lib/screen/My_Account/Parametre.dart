import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'package:hanout/widget/text_form_field.dart';
import 'package:hanout/color.dart';

class Parametre extends StatefulWidget {
  @override
  _ParametreState createState() => _ParametreState();
}

class _ParametreState extends State<Parametre> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _errorMessage = '';


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
    ),

    body: ListView(
        children: [
          SizedBox(height: 20,),
          Container(
            width: screenWidth,
            height: 69,
            color: AppColors.primaryColor,
            child: Row(children: [
              SizedBox(width: 10),
              Icon(Icons.manage_accounts_outlined, color: Colors.white,
              size: 40,),
              SizedBox(width: 10),
              Text('Paramètre',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w900,
                fontSize: 24.0,
              ),),
            ],),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Nom'),
                  SizedBox(height: 10,),
                  MyTextFormField(
                    hintText: 'Nouveau Nom',
                    controller: _nameController,
                  ),
                  SizedBox(height: 20),
                  MyTextFormField(
                    hintText: 'Nouveau Email',
                    controller: _emailController,
                    validator: (value) => value!.isEmpty ? 'Veuillez entrer votre nouvel email' : null,
                  ),
                  SizedBox(height: 20),
                  MyTextFormField(
                    hintText: 'Nouveau mot de passe',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Veuillez entrer votre nouveau mot de passe' : null,
                  ),
                  SizedBox(height: 20),
                  MyTextFormField(
                    hintText: 'Confirmez le nouveau mot de passe',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) return 'Veuillez confirmer votre nouveau mot de passe';
                      if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  MyElevatedButton(
                    buttonText: 'Enregistrer',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateUser();
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (_passwordController.text.isNotEmpty) {
          await user.updatePassword(_passwordController.text);
        }
        if (_emailController.text.isNotEmpty) {
          await user.updateEmail(_emailController.text);
        }
        if (_nameController.text.isNotEmpty) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'name': _nameController.text,
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Paramètres mis à jour avec succès'),
        ));
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }
}
