import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hanout/widget/text_button.dart';
import 'package:hanout/screen/services/auth.dart';
import 'package:hanout/widget/text_form_field.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hanout/screen/authentification/log_in.dart';
import 'package:hanout/screen/acceuil.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final Auth _auth = Auth();
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _merchantFormKey = GlobalKey<FormState>();

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _userEmailController = TextEditingController();
  TextEditingController _userPasswordController = TextEditingController();
  TextEditingController _userConfirmPasswordController = TextEditingController();
  TextEditingController _merchantNameController = TextEditingController();
  TextEditingController _merchantEmailController = TextEditingController();
  TextEditingController _merchantPhoneController = TextEditingController();
  TextEditingController _merchantFiscalController = TextEditingController();
  TextEditingController _merchantPasswordController = TextEditingController();
  TextEditingController _merchantConfirmPasswordController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _idCardImage;
  File? _fiscalCardImage;
  bool _isLoading = false;
  int _currentPage = 0; bool? isChecked = false;

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = false;
    });
    try {
      final userCredential = await _auth.signInWithGoogle();
      if (userCredential != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Acceuil()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connexion Google annulée')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la connexion avec Google : $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final pickedIdCardImage = await _picker.pickImage(source: ImageSource.gallery);
    final pickedFiscalCardImage = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _idCardImage = pickedIdCardImage != null ? File(pickedIdCardImage.path) : null;
      _fiscalCardImage = pickedFiscalCardImage != null ? File(pickedFiscalCardImage.path) : null;
    });
  }

  Future<void> _uploadImages(String userId) async {
    if (_idCardImage != null) {
      await FirebaseStorage.instance
          .ref('merchants/$userId/idCard.jpg')
          .putFile(_idCardImage!);
    }
    if (_fiscalCardImage != null) {
      await FirebaseStorage.instance
          .ref('merchants/$userId/fiscalCard.jpg')
          .putFile(_fiscalCardImage!);
    }
  }

  Future<void> _handleSignUp(bool isMerchant) async {
    final formState = isMerchant ? _merchantFormKey.currentState : _userFormKey.currentState;
    if (formState!.validate()) {
      formState.save();
      setState(() => _isLoading = true);
      try {
        final userCredential = isMerchant
            ? await _auth.createMerchant(
          _merchantNameController.text,
          _merchantEmailController.text,
          _merchantPhoneController.text,
          _merchantFiscalController.text,
          _merchantPasswordController.text,
          _idCardImage!,
          _fiscalCardImage!,
        )
            : await _auth.createUserWithEmailAndPassword(
          _userEmailController.text,
          _userPasswordController.text,
        );
        if (userCredential != null) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Inscription échouée : $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
      ),
      body: Column(
        children: [
          _buildPageIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildUserForm(),
                _buildMerchantForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: PageViewDotIndicator(
        currentItem: _currentPage,
        count: 2,
        unselectedColor: Colors.grey,
        selectedColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildUserForm() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _userFormKey,
          child: Column(
              children: <Widget>[
                Text('Utilisateur', style: Theme.of(context).textTheme.headline5),
                SizedBox(height: 20),
                MyTextFormField(
                  controller: _userNameController,
                  hintText: 'Nom',
                  validator: (input) => input != null && input.isNotEmpty ? null : 'Veuillez entrer un nom',
                ),
                SizedBox(height: 20),
                MyTextFormField(
                  controller: _userEmailController,
                  hintText: 'Email',
                  validator: (input) => input != null && input.isNotEmpty ? null : 'Veuillez entrer un email',
                ),
                SizedBox(height: 20),
                MyTextFormField(
                  controller: _userPasswordController,
                  hintText: 'Mot de passe',
                  obscureText: true,
                  validator: (input) => input != null && input.length >= 6 ? null : 'Le mot de passe doit contenir au moins 6 caractères',
                ),
                SizedBox(height: 20),
                MyTextFormField(
                  controller: _userConfirmPasswordController,
                  hintText: 'Confirmer le mot de passe',
                  obscureText: true,
                  validator: (input) => input != null && input == _userPasswordController.text ? null : 'Les mots de passe ne correspondent pas',
                ),
                SizedBox(height: 20),
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
                    SizedBox(height: 20,),
                    const Expanded(
                      child: Text(
                        'Oui, je veux recevoir des remises, des offres de fidélité et d\'autres mises à jour.',
                        style: TextStyle(
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Text('OU',
                    style: TextStyle(color: Color(0xFF757373),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w900,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center),
                SizedBox(height: 25),
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

                        Text('S\'inscrire avec')),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey,
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
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connexion Facebook annulée ou échouée')));
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
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connexion Google annulée ou échouée')));
                        }
                        setState(() {
                          _isLoading = false;
                        });
                      },
                      child: Image.asset('assets/google.png', height: 50),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                MyElevatedButton(
                  buttonText: 'S\'inscrire',
                  onPressed: () => _handleSignUp(false),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Vous avez déjà un compte?'),
                      MyTextButton(
                        buttonText:'Connexion',
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                        },
                      ),])
              ]),

        ));
  }

  Widget _buildMerchantForm() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child:SafeArea(child:  Form(
          key: _merchantFormKey,
          child: Column(
            children: <Widget>[
              Text('Commerçant', style: Theme.of(context).textTheme.headline5),
              SizedBox(height: 20),
              MyTextFormField(
                controller: _merchantNameController,
                hintText: 'Nom',
                validator: (input) => input != null && input.isNotEmpty ? null : 'Veuillez entrer un nom',
              ),
              SizedBox(height: 20),
              MyTextFormField(
                controller: _merchantEmailController,
                hintText: 'Email',
                validator: (input) => input != null && input.isNotEmpty ? null : 'Veuillez entrer un email',
              ),
              SizedBox(height: 20),
              MyTextFormField(
                controller: _merchantPhoneController,
                hintText: 'Numéro de téléphone',
                validator: (input) => input != null && input.isNotEmpty ? null : 'Veuillez entrer un numéro de téléphone',
                maxLength: 8,
              ),
              SizedBox(height: 20),
              MyTextFormField(
                controller: _merchantFiscalController,
                hintText: 'Numéro fiscal',
                validator: (input) => input != null && input.isNotEmpty ? null : 'Veuillez entrer un numéro fiscal',
              ),
              SizedBox(height: 20),
              MyTextFormField(
                controller: _merchantPasswordController,
                hintText: 'Mot de passe',
                obscureText: true,
                validator: (input) => input != null && input.length >= 6 ? null : 'Le mot de passe doit contenir au moins 6 caractères',
              ),
              SizedBox(height: 20),
              MyTextFormField(
                controller: _merchantConfirmPasswordController,
                hintText: 'Confirmer le mot de passe',
                obscureText: true,
                validator: (input) => input != null && input == _merchantPasswordController.text ? null : 'Les mots de passe ne correspondent pas',
              ),
              SizedBox(height: 20),
              MyTextButton(
                onPressed: _pickImages,
                buttonText:'Télécharger la carte d\'identité et la carte fiscale',
              ),
              _idCardImage != null ? Text(_idCardImage!.path.split('/').last) : SizedBox(),
              _fiscalCardImage != null ? Text(_fiscalCardImage!.path.split('/').last) : SizedBox(),
              SizedBox(height: 20),
              MyElevatedButton(
                buttonText: 'S\'inscrire',
                onPressed: () => _handleSignUp(true),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Vous avez déjà un compte?'),
                    MyTextButton(
                      buttonText:'Connexion',
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                      },
                    ),])
            ],
          ),
        ),
        ));
  }
}
