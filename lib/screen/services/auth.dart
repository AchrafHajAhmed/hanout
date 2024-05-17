import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String> uploadImage(File image, String path) async {
    final int maxFileSize = 5 * 1024 * 1024;
    if (image.lengthSync() > maxFileSize) {
      throw Exception("Le fichier est trop volumineux. La taille maximale est de 5 Mo.");
    }

    Reference storageReference = _storage.ref().child(path);
    UploadTask uploadTask = storageReference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> addUserToFirestore(String userId, String name, String email) async {
    await _firestore.collection('users').doc(userId).set({
      'uid': userId,
      'name': name,
      'email': email,
    });
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      await addUserToFirestore(
        userCredential.user!.uid,
        userCredential.user!.displayName ?? '',
        userCredential.user!.email ?? '',
      );
      return userCredential;
    }
    return null;
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<UserCredential?> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    if (loginResult.status == LoginStatus.success) {
      final AccessToken accessToken = loginResult.accessToken!;
      final AuthCredential credential = FacebookAuthProvider.credential(accessToken.token);
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      await addUserToFirestore(
        userCredential.user!.uid,
        userCredential.user!.displayName ?? 'Facebook User',
        userCredential.user!.email ?? '',
      );
      return userCredential;
    }
    return null;
  }

  Future<void> signOutFacebook() async {
    await FacebookAuth.instance.logOut();
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await addUserToFirestore(userCredential.user!.uid, '', email);
      return userCredential;
    } catch (e) {
      throw Exception('Échec de la création de l\'utilisateur: $e');
    }
  }

  Future<UserCredential> createMerchant(String name, String email, String phoneNumber, String fiscalNumber, String password, File idCardImage, File fiscalCardImage) async {
    UserCredential userCredential = await createUserWithEmailAndPassword(email, password);
    try {
      String idCardUrl = await uploadImage(idCardImage, 'id_cards/${userCredential.user!.uid}');
      String fiscalCardUrl = await uploadImage(fiscalCardImage, 'fiscal_cards/${userCredential.user!.uid}');
      await _firestore.collection('commercants').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phone': phoneNumber,
        'fiscalNumber': fiscalNumber,
        'idCardUrl': idCardUrl,
        'fiscalCardUrl': fiscalCardUrl,
        'status': false, // Ajout du champ status avec la valeur false par défaut
      });
      return userCredential;
    } catch (e) {
      await userCredential.user!.delete();
      throw Exception('Échec de la création du commerçant: $e');
    }
  }
}
