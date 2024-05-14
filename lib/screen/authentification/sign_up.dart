import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hanout/screen/authentification/log_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hanout/widget/text_button.dart';
import 'package:hanout/screen/services/auth.dart';
import 'package:hanout/widget/text_form_field.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'package:hanout/screen/acceuil.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final Auth _auth = Auth();
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _merchantFormKey = GlobalKey<FormState>();
  String? _userEmail, _userPassword, _userName, _userConfirmPassword;
  String? _merchantEmail, _merchantPassword, _merchantName, _merchantConfirmPassword, _merchantPhoneNumber, _merchantFiscalNumber;
  File? _idCardImage, _fiscalCardImage;
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _userConfirmPasswordController = TextEditingController();
  final TextEditingController _merchantPasswordController = TextEditingController();
  final TextEditingController _merchantConfirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool? isChecked = false;
  int _currentPage = 0;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _pageController.dispose();
    _userPasswordController.dispose();
    _userConfirmPasswordController.dispose();
    _merchantPasswordController.dispose();
    _merchantConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp(bool isMerchant) async {
    if (isMerchant ? _merchantFormKey.currentState!.validate() : _userFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        if (isMerchant && (_idCardImage == null || _fiscalCardImage == null)) {
          throw Exception('Veuillez sélectionner à la fois les images de la carte d\'identité et de la carte fiscale avant de vous inscrire.');
        }
        final userCredential = isMerchant ?
        await _auth.createMerchant(
            _merchantName!,
            _merchantEmail!,
            _merchantPhoneNumber!,
            _merchantFiscalNumber!,
            _merchantPassword!,
            _idCardImage!,
            _fiscalCardImage!
        ) :
        await _auth.createUserWithEmailAndPassword(_userEmail!, _userPassword!);
        if (userCredential != null) {
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Acceuil()));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('L\'inscription a échoué : $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> pickImages() async {
    File? tempFile;

    // Pick ID Card Image
    tempFile = await pickImage();
    if (tempFile != null) {
      setState(() => _idCardImage = tempFile);

      // Pick Fiscal Card Image
      tempFile = await pickImage();
      if (tempFile != null) {
        setState(() => _fiscalCardImage = tempFile);
      } else {
        print("La sélection de l'image de la carte fiscale a été annulée.");
      }
    } else {
      print("La sélection de l'image de la carte d'identité a été annulée.");
    }
  }

  Future<File?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Widget buildImagePreview(File? imageFile) {
    if (imageFile == null) {
      return Text("Aucune image sélectionnée.");
    } else {
      String fileName = imageFile.path.split('/').last;
      return Text(fileName, style: TextStyle(fontSize: 16, color: Colors.grey[600]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
      ),
      body: SafeArea (
      child : Column(
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
    ));
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
            MyTextFormField(
              hintText: 'Nom',
              onSaved: (input) => _userName = input,
              validator: (input) =>
              input == null || input.isEmpty ? 'Veuillez entrer un nom' : null,
            ),
            SizedBox(height: 20),
            MyTextFormField(
              hintText: 'Email',
              onSaved: (input) => _userEmail = input,
              validator: (input) =>
              input == null || input.isEmpty ? 'Veuillez entrer une adresse e-mail' : null,
            ),
            SizedBox(height: 20),
            MyTextFormField(
              controller: _userPasswordController,
              hintText: 'Mot de passe',
              onSaved: (input) => _userPassword = input,
              validator: (input) => input == null || input.length < 6
                  ? 'Votre mot de passe doit contenir au moins 6 caractères.'
                  : null,
              obscureText: true,
            ),
            SizedBox(height: 20),
            MyTextFormField(
              hintText: 'Confirmer le mot de passe',
              validator: (input) =>
              input != _userConfirmPasswordController.text ? 'Les mots de passe ne correspondent pas.' : null,
              obscureText: true,
            ),
            SizedBox(height: 5,),
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
                    'Oui, je souhaite recevoir des notifications.',
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

                    Text('Se connecter avec')),
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
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connexion avec Facebook annulée ou échouée')));
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
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connexion avec Google annulée ou échouée')));
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  child: Image.asset('assets/google.png', height: 50),
                ),
              ],
            ),
            SizedBox(height: 30,),
            MyElevatedButton(
              buttonText: 'S\'inscrire',
              onPressed: () => _handleSignUp(false),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Vous avez déjà un compte ?'),
                  MyTextButton(
                    buttonText:'Se connecter',
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                    },
                  ),])
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _merchantFormKey,
        child: Column(
          children: <Widget>[
            Text('Commerçant', style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 20),

            MyTextFormField(
              hintText: 'Nom',
              onSaved: (input) => _merchantName = input,
              validator: (input) => input != null && input.isNotEmpty ? null : 'Veuillez entrer un nom',
            ),
            SizedBox(height: 20),
            MyTextFormField(
              hintText: 'Email',
              onSaved: (input) => _merchantEmail = input,
              validator: (input) => input != null && input.isNotEmpty ? null : 'Veuillez entrer une adresse e-mail',
            ),
            SizedBox(height: 20),
            MyTextFormField(
              hintText: 'Numéro de téléphone',
              onSaved: (input) => _merchantPhoneNumber = input,
              validator: (input) {
                if (input == null || input.isEmpty) {
                  return 'Veuillez entrer un numéro de téléphone';
                }
                if (input.length != 8) {
                  return 'Le numéro de téléphone doit comporter 8 chiffres';
                }
                return null;
              },
              //inputFormatters: [],
            ),
            SizedBox(height: 20),

            MyTextFormField(
              hintText: 'Numéro fiscal',
              onSaved: (input) => _merchantFiscalNumber = input,
              validator: (input) => input != null && input.isNotEmpty ? null : 'Veuillez entrer un numéro fiscal',
            ),
            SizedBox(height: 20),

            MyTextFormField(
              controller: _merchantPasswordController,
              hintText: 'Mot de passe',
              obscureText: true,
              validator: (input) => input != null && input.length >= 6 ? null : 'Le mot de passe doit comporter au moins 6 caractères',
            ),
            SizedBox(height: 20),
            MyTextFormField(
              hintText: 'Confirmer le mot de passe',
              obscureText: true,
              validator: (input) => input == _merchantPasswordController.text ? null : 'Les mots de passe ne correspondent pas',
            ),
            SizedBox(height: 20),
            MyTextButton(buttonText: 'Télécharger les images de pièce d\'identité et de carte fiscale',
              onPressed: pickImages,
            ),
            SizedBox(height: 10,),
            buildImagePreview(_idCardImage),
            SizedBox(height: 5,),
            buildImagePreview(_fiscalCardImage),
            SizedBox(height: 20),
            MyElevatedButton(
              buttonText: 'S\'inscrire',
              onPressed: () => _handleSignUp(true),
            ),
            SizedBox(height: 20,),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Vous avez déjà un compte ?'),
                  MyTextButton(
                    buttonText:'Se connecter',
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                    },
                  ),])
          ],
        ),
      ),
    );
  }
}