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
import 'package:flutter/services.dart';


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

  // Image picking
  final ImagePicker _picker = ImagePicker();
  File? _idCardImage;
  File? _fiscalCardImage;

  bool _isLoading = false;
  bool? isChecked = false;
  int _currentPage = 0;

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
        final userCredential = isMerchant ?
        await _auth.createMerchant(
          _merchantNameController.text,
          _merchantEmailController.text,
          _merchantPhoneController.text,
          _merchantFiscalController.text,
          _merchantPasswordController.text,
        ) :
        await _auth.createUserWithEmailAndPassword(_userEmailController.text, _userPasswordController.text);
        if (userCredential != null) {
          await _uploadImages(userCredential.user!.uid);

          await _auth.addImagesToMerchant(
            userCredential.user!.uid,
            _idCardImage != null ? 'idCard.jpg' : '',
            _fiscalCardImage != null ? 'fiscalCard.jpg' : '',
          );

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-Up failed: $e')));
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
              hintText: 'Name',
              validator: (input) => input != null && input.isNotEmpty ? null : 'Please enter a name',
            ),
            SizedBox(height: 20),
            MyTextFormField(
              controller: _userEmailController,
              hintText: 'Email',
              validator: (input) => input != null && input.isNotEmpty ? null : 'Please enter an email',
            ),
            SizedBox(height: 20),
            MyTextFormField(
              controller: _userPasswordController,
              hintText: 'Password',
              obscureText: true,
              validator: (input) => input != null && input.length >= 6 ? null : 'Password must be at least 6 characters',
            ),
            SizedBox(height: 20),
            MyTextFormField(
              controller: _userConfirmPasswordController,
              hintText: 'Confirm Password',
              obscureText: true,
              validator: (input) => input != null && input == _userPasswordController.text ? null : 'Passwords do not match',
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
                SizedBox(height: 20,),
                const Expanded(
                  child: Text(
                    'Yes, I want to receive discounts, loyalty offers and other updates.',
                    style: TextStyle(
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Text('OR',
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

                    Text('Sign Up Using')),
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
              buttonText: 'Sign Up',
              onPressed: () => _handleSignUp(false),
            ),
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
              controller: _merchantNameController,
              hintText: 'Name',
              validator: (input) => input != null && input.isNotEmpty ? null : 'Please enter a name',
            ),
            SizedBox(height: 20),
            MyTextFormField(
              controller: _merchantEmailController,
              hintText: 'Email',
              validator: (input) => input != null && input.isNotEmpty ? null : 'Please enter an email',
            ),
            SizedBox(height: 20),
            MyTextFormField(
              controller: _merchantPhoneController,
              hintText: 'Phone Number',
              validator: (input) {
                if (input == null || input.isEmpty) {
                  return 'Please enter a phone number';
                } else if (input.length != 8) {
                  return 'Phone number must be 8 digits';
                }
                return null;
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // Accepts only digits
                LengthLimitingTextInputFormatter(8), // Limits input to 8 characters
              ],
            ),
            SizedBox(height: 20),
            MyTextFormField(
              controller: _merchantFiscalController,
              hintText: 'Fiscal Number',
              validator: (input) => input != null && input.isNotEmpty ? null : 'Please enter a fiscal number',
            ),
            SizedBox(height: 20),
            MyTextFormField(
              controller: _merchantPasswordController,
              hintText: 'Password',
              obscureText: true,
              validator: (input) => input != null && input.length >= 6 ? null : 'Password must be at least 6 characters',
            ),
            SizedBox(height: 20),
            MyTextFormField(
              controller: _merchantConfirmPasswordController,
              hintText: 'Confirm Password',
              obscureText: true,
              validator: (input) => input != null && input == _merchantPasswordController.text ? null : 'Passwords do not match',
            ),
            SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MyTextButton(
              buttonText: 'Upload les photo de carte CIN et Matricule fiscale',
              onPressed: _pickImages,
            ),]),
            _idCardImage != null ? Text(_idCardImage!.path.split('/').last) : SizedBox(),
            _fiscalCardImage != null ? Text(_fiscalCardImage!.path.split('/').last) : SizedBox(),
            SizedBox(height: 20),
            MyElevatedButton(
              buttonText: 'Sign Up',
              onPressed: () => _handleSignUp(true),
            ),
            SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }

}

