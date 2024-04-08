import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> addUserToFirestore(String userId, String name, String email) async {
    await _firestore.collection('users').doc(userId).set({
      'uid': userId,
      'name': name,
      'email': email,
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

        await addUserToFirestore(
          userCredential.user!.uid,
          userCredential.user!.displayName ?? '',
          userCredential.user!.email ?? '',
        );

        return userCredential;
      }
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status == LoginStatus.success) {
        final AccessToken accessToken = loginResult.accessToken!;
        final AuthCredential facebookCredential = FacebookAuthProvider.credential(accessToken.token);
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(facebookCredential);

        await addUserToFirestore(
          userCredential.user!.uid,
          userCredential.user!.displayName ?? 'Facebook User',
          userCredential.user!.email ?? '',
        );

        return userCredential;
      } else {
        print("Erreur de connexion Facebook: ${loginResult.status}");
        return null;
      }
    } catch (error) {
      print("Erreur d'authentification Facebook: $error");
      return null;
    }
  }

  Future<void> signOutFacebook() async {
    await FacebookAuth.instance.logOut();
    await _firebaseAuth.signOut();
  }
}

