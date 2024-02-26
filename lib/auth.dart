import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }
  Future<UserCredential> createUserWithEmailAndPassword(String email,String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password
     );}
    Future<void> addUserToFirestore(String userId, String name,
        String email) async {
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'name': name,
        'email': email
      });
  }
}